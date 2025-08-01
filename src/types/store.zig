//! The store of solved types
//! Contains both Slot & Descriptor stores

const std = @import("std");
const base = @import("base");
const collections = @import("collections");
const serialization = @import("serialization");
const types = @import("types.zig");

const Allocator = std.mem.Allocator;
const Desc = types.Descriptor;
const Var = types.Var;
const Content = types.Content;
const Rank = types.Rank;
const Mark = types.Mark;
const RecordField = types.RecordField;
const TagUnion = types.TagUnion;
const Tag = types.Tag;
const VarSafeList = Var.SafeList;
const RecordFieldSafeMultiList = RecordField.SafeMultiList;
const TagSafeMultiList = Tag.SafeMultiList;
const Descriptor = types.Descriptor;
const TypeIdent = types.TypeIdent;
const Alias = types.Alias;
const FlatType = types.FlatType;
const NominalType = types.NominalType;
const Record = types.Record;
const Num = types.Num;

const SERIALIZATION_ALIGNMENT = serialization.SERIALIZATION_ALIGNMENT;

/// A variable & its descriptor info
pub const ResolvedVarDesc = struct { var_: Var, desc_idx: DescStore.Idx, desc: Desc };

/// Two variables & descs
pub const ResolvedVarDescs = struct { a: ResolvedVarDesc, b: ResolvedVarDesc };

/// Reperents either type data *or* a symlink to another type variable
pub const Slot = union(enum) {
    root: DescStore.Idx,
    redirect: Var,

    /// Calculate the size needed to serialize this Slot
    pub fn serializedSize(self: *const Slot) usize {
        _ = self;
        return @sizeOf(u8) + @sizeOf(u32); // tag + data
    }

    /// Serialize this Slot into the provided buffer
    pub fn serializeInto(self: *const Slot, buffer: []u8) ![]u8 {
        if (buffer.len < self.serializedSize()) return error.BufferTooSmall;

        switch (self.*) {
            .root => |idx| {
                buffer[0] = 0; // tag for root
                std.mem.writeInt(u32, buffer[1..5], @intFromEnum(idx), .little);
            },
            .redirect => |var_| {
                buffer[0] = 1; // tag for redirect
                std.mem.writeInt(u32, buffer[1..5], @intFromEnum(var_), .little);
            },
        }

        return buffer[0..self.serializedSize()];
    }

    /// Deserialize a Slot from the provided buffer
    pub fn deserializeFrom(buffer: []const u8) !Slot {
        if (buffer.len < @sizeOf(u8) + @sizeOf(u32)) return error.BufferTooSmall;

        const tag = buffer[0];
        const data = std.mem.readInt(u32, buffer[1..5], .little);

        switch (tag) {
            0 => return Slot{ .root = @enumFromInt(data) },
            1 => return Slot{ .redirect = @enumFromInt(data) },
            else => return error.InvalidTag,
        }
    }
};

/// The store of all type variables and their descriptors
///
/// Each type variables (`Var`) points to a Slot.
/// A Slot either redirects to a different slot or contains type `Content`
///
/// Var maps to a SlotStore.Idx internally
pub const Store = struct {
    const Self = @This();

    gpa: Allocator,

    /// Type variable storage
    slots: SlotStore,
    descs: DescStore,

    /// Storage for compound type parts
    /// TODO: Consolidate all var lists into 1
    vars: VarSafeList,
    record_fields: RecordFieldSafeMultiList,
    tags: TagSafeMultiList,

    /// Init the unification table
    pub fn init(gpa: Allocator) std.mem.Allocator.Error!Self {
        // TODO: eventually use herusitics here to determine sensible defaults
        return try Self.initCapacity(gpa, 1024, 512);
    }

    /// Init the unification table
    pub fn initCapacity(gpa: Allocator, root_capacity: usize, child_capacity: usize) std.mem.Allocator.Error!Self {
        return .{
            .gpa = gpa,

            // slots & descriptors
            .descs = try DescStore.init(gpa, root_capacity),
            .slots = try SlotStore.init(gpa, root_capacity),

            // everything else
            .vars = try VarSafeList.initCapacity(gpa, child_capacity),
            .record_fields = try RecordFieldSafeMultiList.initCapacity(gpa, child_capacity),
            .tags = try TagSafeMultiList.initCapacity(gpa, child_capacity),
        };
    }

    /// Ensure that slots & descriptor arrays have at least the provided capacity
    pub fn ensureTotalCapacity(self: *Self, capacity: usize) Allocator.Error!void {
        try self.descs.backing.ensureTotalCapacity(self.gpa, capacity);
        try self.slots.backing.items.ensureTotalCapacity(self.gpa, capacity);
    }

    /// Deinit the unification table
    pub fn deinit(self: *Self) void {
        // slots & descriptors
        self.descs.deinit(self.gpa);
        self.slots.deinit(self.gpa);

        // everything else
        self.vars.deinit(self.gpa);
        self.record_fields.deinit(self.gpa);
        self.tags.deinit(self.gpa);
    }

    /// Return the number of type variables in the store.
    pub fn len(self: *const Self) usize {
        return self.slots.backing.len();
    }

    // fresh variables //

    /// Create a new unbound, flexible type variable without a name
    /// Used in canonicalization when creating type slots
    pub fn fresh(self: *Self) std.mem.Allocator.Error!Var {
        return try self.freshFromContent(Content{ .flex_var = null });
    }

    /// Create a new variable with the provided desc
    /// Used in tests
    pub fn freshFromContent(self: *Self, content: Content) std.mem.Allocator.Error!Var {
        const desc_idx = try self.descs.insert(self.gpa, .{ .content = content, .rank = Rank.top_level, .mark = Mark.none });
        const slot_idx = try self.slots.insert(self.gpa, .{ .root = desc_idx });
        return Self.slotIdxToVar(slot_idx);
    }

    /// Create a variable redirecting to the provided var
    /// Used in tests
    pub fn freshRedirect(self: *Self, var_: Var) std.mem.Allocator.Error!Var {
        const slot_idx = try self.slots.insert(self.gpa, .{ .redirect = var_ });
        return Self.slotIdxToVar(slot_idx);
    }

    /// Create a new variable with the given descriptor
    pub fn register(self: *Self, desc: Desc) std.mem.Allocator.Error!Var {
        const desc_idx = try self.descs.insert(self.gpa, desc);
        const slot_idx = try self.slots.insert(self.gpa, .{ .root = desc_idx });
        return Self.slotIdxToVar(slot_idx);
    }

    // setting variables //

    /// Set a type variable to the provided content
    pub fn setVarContent(self: *Self, target_var: Var, content: Content) Allocator.Error!void {
        std.debug.assert(@intFromEnum(target_var) < self.len());
        const resolved = self.resolveVar(target_var);
        var desc = resolved.desc;
        desc.content = content;
        self.descs.set(resolved.desc_idx, desc);
    }

    /// Set a type variable to redirect to the provided redirect
    pub fn setVarRedirect(self: *Self, target_var: Var, redirect_to: Var) Allocator.Error!void {
        std.debug.assert(@intFromEnum(target_var) < self.len());
        std.debug.assert(@intFromEnum(redirect_to) < self.len());
        const slot_idx = Self.varToSlotIdx(target_var);
        self.slots.set(slot_idx, .{ .redirect = redirect_to });
    }

    // make builtin types //

    pub fn mkBool(self: *Self, gpa: Allocator, idents: *base.Ident.Store, ext_var: Var) std.mem.Allocator.Error!Content {
        const true_ident = try idents.insert(gpa, base.Ident.for_text("True"));
        const false_ident = try idents.insert(gpa, base.Ident.for_text("False"));

        const true_tag = try self.mkTag(true_ident, &[_]Var{});
        const false_tag = try self.mkTag(false_ident, &[_]Var{});
        return try self.mkTagUnion(&[_]Tag{ true_tag, false_tag }, ext_var);
    }

    // make content types //

    /// Make a tag union data type
    /// Does not insert content into the types store
    pub fn mkTagUnion(self: *Self, tags: []const Tag, ext_var: Var) std.mem.Allocator.Error!Content {
        const tags_range = try self.appendTags(tags);
        const tag_union = TagUnion{ .tags = tags_range, .ext = ext_var };
        return Content{ .structure = .{ .tag_union = tag_union } };
    }

    /// Make a tag data type
    /// Does not insert content into the types store
    pub fn mkTag(self: *Self, name: base.Ident.Idx, args: []const Var) std.mem.Allocator.Error!Tag {
        const args_range = try self.appendVars(args);
        return Tag{ .name = name, .args = args_range };
    }

    /// Make alias data type
    /// Does not insert content into the types store
    pub fn mkAlias(self: *Self, ident: TypeIdent, backing_var: Var, args: []const Var) std.mem.Allocator.Error!Content {
        const backing_idx = try self.appendVar(backing_var);
        var span = try self.appendVars(args);

        // Adjust args span to include backing  var
        span.start = backing_idx;
        span.count = span.count + 1;

        return Content{
            .alias = Alias{
                .ident = ident,
                .vars = .{ .nonempty = span },
            },
        };
    }

    /// Make nominal data type
    /// Does not insert content into the types store
    pub fn mkNominal(
        self: *Self,
        ident: TypeIdent,
        backing_var: Var,
        args: []const Var,
        origin_module: base.Ident.Idx,
    ) std.mem.Allocator.Error!Content {
        const backing_idx = try self.appendVar(backing_var);
        var span = try self.appendVars(args);

        // Adjust args span to include backing  var
        span.start = backing_idx;
        span.count = span.count + 1;

        return Content{ .structure = FlatType{
            .nominal_type = NominalType{
                .ident = ident,
                .vars = .{ .nonempty = span },
                .origin_module = origin_module,
            },
        } };
    }

    // Make a function data type with unbound effectfulness
    // Does not insert content into the types store.
    pub fn mkFuncUnbound(self: *Self, args: []const Var, ret: Var) std.mem.Allocator.Error!Content {
        const args_range = try self.appendVars(args);

        // Check if any arguments need instantiation
        var needs_inst = false;
        for (args) |arg| {
            if (self.needsInstantiation(arg)) {
                needs_inst = true;
                break;
            }
        }

        // Also check the return type
        if (!needs_inst) {
            needs_inst = self.needsInstantiation(ret);
        }

        return Content{ .structure = .{ .fn_unbound = .{
            .args = args_range,
            .ret = ret,
            .needs_instantiation = needs_inst,
        } } };
    }

    // Make a pure function data type (as opposed to an effectful or unbound function)
    // Does not insert content into the types store.
    pub fn mkFuncPure(self: *Self, args: []const Var, ret: Var) std.mem.Allocator.Error!Content {
        const args_range = try self.appendVars(args);

        // Check if any arguments need instantiation
        var needs_inst = false;
        for (args) |arg| {
            if (self.needsInstantiation(arg)) {
                needs_inst = true;
                break;
            }
        }

        // Also check the return type
        if (!needs_inst) {
            needs_inst = self.needsInstantiation(ret);
        }

        return Content{ .structure = .{ .fn_pure = .{ .args = args_range, .ret = ret, .needs_instantiation = needs_inst } } };
    }

    // Make an effectful function data type (as opposed to a pure or unbound function)
    // Does not insert content into the types store.
    pub fn mkFuncEffectful(self: *Self, args: []const Var, ret: Var) std.mem.Allocator.Error!Content {
        const args_range = try self.appendVars(args);

        // Check if any arguments need instantiation
        var needs_inst = false;
        for (args) |arg| {
            if (self.needsInstantiation(arg)) {
                needs_inst = true;
                break;
            }
        }

        // Also check the return type
        if (!needs_inst) {
            needs_inst = self.needsInstantiation(ret);
        }

        return Content{ .structure = .{ .fn_effectful = .{ .args = args_range, .ret = ret, .needs_instantiation = needs_inst } } };
    }

    // Helper to check if a type variable needs instantiation
    pub fn needsInstantiation(self: *const Self, var_: Var) bool {
        const resolved = self.resolveVar(var_);
        return self.needsInstantiationContent(resolved.desc.content);
    }

    pub fn needsInstantiationContent(self: *const Self, content: Content) bool {
        return switch (content) {
            .flex_var => true, // Flexible variables need instantiation
            .rigid_var => true, // Rigid variables need instantiation when used outside their defining scope
            .alias => true, // Aliases may contain type variables, so assume they need instantiation
            .structure => |flat_type| self.needsInstantiationFlatType(flat_type),
            .err => false,
        };
    }

    pub fn needsInstantiationFlatType(self: *const Self, flat_type: FlatType) bool {
        return switch (flat_type) {
            .str => false,
            .box => |box_var| self.needsInstantiation(box_var),
            .list => |list_var| self.needsInstantiation(list_var),
            .list_unbound => false,
            .tuple => |tuple| blk: {
                const elems_slice = self.sliceVars(tuple.elems);
                for (elems_slice) |elem_var| {
                    if (self.needsInstantiation(elem_var)) break :blk true;
                }
                break :blk false;
            },
            .num => |num| switch (num) {
                .num_poly => |poly| self.needsInstantiation(poly.var_),
                .int_poly => |poly| self.needsInstantiation(poly.var_),
                .frac_poly => |poly| self.needsInstantiation(poly.var_),
                else => false, // Concrete numeric types don't need instantiation
            },
            .nominal_type => false, // Nominal types are concrete
            .fn_pure => |func| func.needs_instantiation,
            .fn_effectful => |func| func.needs_instantiation,
            .fn_unbound => |func| func.needs_instantiation,
            .record => |record| self.needsInstantiationRecord(record),
            .record_unbound => |fields| self.needsInstantiationRecordFields(fields),
            .record_poly => |poly| self.needsInstantiation(poly.var_) or self.needsInstantiationRecord(poly.record),
            .empty_record => false,
            .tag_union => |tag_union| self.needsInstantiationTagUnion(tag_union),
            .empty_tag_union => false,
        };
    }

    pub fn needsInstantiationRecord(self: *const Self, record: Record) bool {
        const fields_slice = self.getRecordFieldsSlice(record.fields);
        for (fields_slice.items(.var_)) |type_var| {
            if (self.needsInstantiation(type_var)) return true;
        }
        return self.needsInstantiation(record.ext);
    }

    pub fn needsInstantiationRecordFields(self: *const Self, fields: RecordField.SafeMultiList.Range) bool {
        const fields_slice = self.getRecordFieldsSlice(fields);
        for (fields_slice.items(.var_)) |type_var| {
            if (self.needsInstantiation(type_var)) return true;
        }
        return false;
    }

    pub fn needsInstantiationTagUnion(self: *const Self, tag_union: TagUnion) bool {
        const tags_slice = self.getTagsSlice(tag_union.tags);
        for (tags_slice.items(.args)) |tag_args| {
            const args_slice = self.sliceVars(tag_args);
            for (args_slice) |arg_var| {
                if (self.needsInstantiation(arg_var)) return true;
            }
        }
        return self.needsInstantiation(tag_union.ext);
    }

    // sub list setters //

    /// Append a var to the backing list, returning the idx
    pub fn appendVar(self: *Self, v: Var) std.mem.Allocator.Error!VarSafeList.Idx {
        return try self.vars.append(self.gpa, v);
    }

    /// Append a var to the backing list, returning the idx
    pub fn appendVars(self: *Self, s: []const Var) std.mem.Allocator.Error!VarSafeList.Range {
        return try self.vars.appendSlice(self.gpa, s);
    }

    /// Append a record field to the backing list, returning the idx
    pub fn appendRecordField(self: *Self, field: RecordField) std.mem.Allocator.Error!RecordFieldSafeMultiList.Idx {
        return try self.record_fields.append(self.gpa, field);
    }

    /// Append a slice of record fields to the backing list, returning the range
    pub fn appendRecordFields(self: *Self, slice: []const RecordField) std.mem.Allocator.Error!RecordFieldSafeMultiList.Range {
        return try self.record_fields.appendSlice(self.gpa, slice);
    }

    /// Append a tag to the backing list, returning the idx
    pub fn appendTag(self: *Self, tag: Tag) Allocator.Error!TagSafeMultiList.Idx {
        return try self.tags.append(self.gpa, tag);
    }

    /// Append a slice of tags to the backing list, returning the range
    pub fn appendTags(self: *Self, slice: []const Tag) std.mem.Allocator.Error!TagSafeMultiList.Range {
        return try self.tags.appendSlice(self.gpa, slice);
    }

    // sub list getters //

    /// Given a range, get a slice of vars from the backing array
    pub fn sliceVars(self: *const Self, range: VarSafeList.Range) []Var {
        return self.vars.sliceRange(range);
    }

    /// Given a range, get a slice of record fields from the backing array
    pub fn getRecordFieldsSlice(self: *const Self, range: RecordFieldSafeMultiList.Range) RecordFieldSafeMultiList.Slice {
        return self.record_fields.sliceRange(range);
    }

    /// Given a range, get a slice of tags from the backing array
    pub fn getTagsSlice(self: *const Self, range: TagSafeMultiList.Range) TagSafeMultiList.Slice {
        return self.tags.sliceRange(range);
    }

    // helpers - alias types //

    // Alias types contain a span of variables. In this span, the 1st element
    // is the backing variable, and the remainder are the arguments

    /// Get the backing var for this alias type
    pub fn getAliasBackingVar(self: *const Self, alias: Alias) Var {
        std.debug.assert(alias.vars.nonempty.count > 0);
        return self.vars.get(alias.vars.nonempty.start).*;
    }

    /// Get the arg vars for this alias type
    pub fn sliceAliasArgs(self: *const Self, alias: Alias) []Var {
        std.debug.assert(alias.vars.nonempty.count > 0);
        const slice = self.vars.sliceRange(alias.vars.nonempty);
        return slice[1..];
    }

    /// Get the an iterator arg vars for this alias type
    pub fn iterAliasArgs(self: *const Self, alias: Alias) VarSafeList.Iterator {
        std.debug.assert(alias.vars.nonempty.count > 0);
        var span = alias.vars.nonempty;
        span.dropFirstElem();
        return self.vars.iterRange(span);
    }

    // helpers - nominal types //

    // Nominal types contain a span of variables. In this span, the 1st element
    // is the backing variable, and the remainder are the arguments

    /// Get the backing var for this nominal type
    pub fn getNominalBackingVar(self: *const Self, nominal: NominalType) Var {
        std.debug.assert(nominal.vars.nonempty.count > 0);
        return self.vars.get(nominal.vars.nonempty.start).*;
    }

    /// Get the arg vars for this nominal type
    pub fn sliceNominalArgs(self: *const Self, nominal: NominalType) []Var {
        std.debug.assert(nominal.vars.nonempty.count > 0);
        const slice = self.vars.sliceRange(nominal.vars.nonempty);
        return slice[1..];
    }

    /// Get the an iterator arg vars for this nominal type
    pub fn iterNominalArgs(self: *const Self, nominal: NominalType) VarSafeList.Iterator {
        std.debug.assert(nominal.vars.nonempty.count > 0);
        var span = nominal.vars.nonempty;
        span.dropFirstElem();
        return self.vars.iterRange(span);
    }

    // mark & rank //

    /// Set the mark for a descriptor
    pub fn setDescMark(self: *Self, desc_idx: DescStore.Idx, mark: Mark) void {
        var desc = self.descs.get(desc_idx);
        desc.mark = mark;
        self.descs.set(desc_idx, desc);
    }

    // resolvers //

    /// Given a type var, follow all redirects until finding the root descriptor
    ///
    /// Will mutate the DescStore in place to compress the path
    pub fn resolveVarAndCompressPath(self: *Self, initial_var: Var) ResolvedVarDesc {
        // Resolve the variable
        const redirected = self.resolveVar(initial_var);
        const redirected_root_var = redirected.var_;

        // then follow the chain again, but compressing each to the root
        if (initial_var != redirected_root_var) {
            var compressed_slot_idx = Self.varToSlotIdx(initial_var);
            var compressed_slot: Slot = self.slots.get(compressed_slot_idx);
            while (true) {
                switch (compressed_slot) {
                    .redirect => |next_redirect_var| {
                        self.slots.set(compressed_slot_idx, Slot{ .redirect = redirected_root_var });
                        compressed_slot_idx = Self.varToSlotIdx(next_redirect_var);
                        compressed_slot = self.slots.get(compressed_slot_idx);
                    },
                    .root => |_| break,
                }
            }
        }

        // Compress the path
        return redirected;
    }

    /// Given a type var, follow all redirects until finding the root descriptor
    pub fn resolveVar(self: *const Self, initial_var: Var) ResolvedVarDesc {
        var redirected_slot_idx = Self.varToSlotIdx(initial_var);
        var redirected_slot: Slot = self.slots.get(redirected_slot_idx);

        while (true) {
            switch (redirected_slot) {
                .redirect => |next_redirect_var| {
                    redirected_slot_idx = Self.varToSlotIdx(next_redirect_var);
                    redirected_slot = self.slots.get(redirected_slot_idx);
                },
                .root => |desc_idx| {
                    const redirected_root_var = Self.slotIdxToVar(redirected_slot_idx);
                    const desc = self.descs.get(desc_idx);
                    return .{
                        .var_ = redirected_root_var,
                        .desc_idx = desc_idx,
                        .desc = desc,
                    };
                },
            }
        }
        const redirected_root_var = Self.slotIdxToVar(redirected_slot_idx);

        // TODO: refactor to remove panic?
        switch (redirected_slot) {
            .redirect => |_| @panic("redirected slot was still redirect after following chain"),
            .root => |desc_idx| {
                const desc = self.descs.get(desc_idx);
                return .{
                    .var_ = redirected_root_var,
                    .desc_idx = desc_idx,
                    .desc = desc,
                };
            },
        }
    }

    // equivalence //

    /// The result of checking for equivalence
    pub const VarEquivResult = union(enum) { equiv, not_equiv: ResolvedVarDescs };

    /// Check if two variables are equivalent
    /// This will follow all redirects and compress the path
    ///
    /// If the vars are *not equivalent, then return the resolved vars & descs
    pub fn checkVarsEquiv(self: *Self, a_var: Var, b_var: Var) VarEquivResult {
        const a = self.resolveVarAndCompressPath(a_var);
        const b = self.resolveVarAndCompressPath(b_var);
        if (a.desc_idx == b.desc_idx) {
            return .equiv;
        } else {
            return .{ .not_equiv = .{ .a = a, .b = b } };
        }
    }

    // union //

    /// Link the variables & updated the content in the unification table
    /// * update b to to the new desc value
    /// * redirect a -> b
    ///
    // NOTE: The elm & the roc compiler this step differently
    // * The elm compiler sets b to redirect to a
    // * The roc compiler sets a to redirect to b
    pub fn union_(self: *Self, a_var: Var, b_var: Var, new_desc: Desc) void {
        const b_data = self.resolveVarAndCompressPath(b_var);

        // Update b to be the new desc
        self.descs.set(b_data.desc_idx, new_desc);

        // Update a to point to b
        self.slots.set(Self.varToSlotIdx(a_var), .{ .redirect = b_var });
    }

    // test helpers //

    /// Get the slot for the provided var
    /// Used in tests
    /// If you're reaching for this in non-test code, you probably want
    /// resolveVar or resolveVarAndCompressPath instead
    pub fn getSlot(self: *Self, var_: Var) Slot {
        return self.slots.get(Self.varToSlotIdx(var_));
    }

    /// Get the descriptor for the provided idx
    /// Used in tests
    pub fn getDesc(self: *Self, desc_idx: DescStore.Idx) Desc {
        return self.descs.get(desc_idx);
    }

    const Error = error{VarNotRoot};

    /// Set a root var to be the specified content
    /// Used in tests
    pub fn setRootVarContent(self: *Self, var_: Var, content: Content) error{VarNotRoot}!void {
        const slot = self.slots.get(Self.varToSlotIdx(var_));
        switch (slot) {
            .root => |desc_idx| {
                var desc = self.descs.get(desc_idx);
                desc.content = content;
                self.descs.set(desc_idx, desc);
            },
            .redirect => {
                return error.VarNotRoot;
            },
        }
    }

    // helpers //

    pub fn varToSlotIdx(var_: Var) SlotStore.Idx {
        return @enumFromInt(@intFromEnum(var_));
    }

    fn slotIdxToVar(slot_idx: SlotStore.Idx) Var {
        return @enumFromInt(@intFromEnum(slot_idx));
    }

    // serialization //

    /// Calculate the size needed to serialize this Store
    pub fn serializedSize(self: *const Self) usize {
        const slots_size = self.slots.serializedSize();
        const descs_size = self.descs.serializedSize();
        const record_fields_size = self.record_fields.serializedSize();
        const tags_size = self.tags.serializedSize();
        const vars_size = self.vars.serializedSize();

        // Add alignment padding for each component
        var total_size: usize = @sizeOf(u32) * 5; // size headers
        total_size = std.mem.alignForward(usize, total_size, SERIALIZATION_ALIGNMENT);

        total_size += slots_size;
        total_size = std.mem.alignForward(usize, total_size, SERIALIZATION_ALIGNMENT);

        total_size += descs_size;
        total_size = std.mem.alignForward(usize, total_size, SERIALIZATION_ALIGNMENT);

        total_size += record_fields_size;
        total_size = std.mem.alignForward(usize, total_size, SERIALIZATION_ALIGNMENT);

        total_size += tags_size;
        total_size = std.mem.alignForward(usize, total_size, SERIALIZATION_ALIGNMENT);

        total_size += vars_size;
        total_size = std.mem.alignForward(usize, total_size, SERIALIZATION_ALIGNMENT);

        // Align to SERIALIZATION_ALIGNMENT to maintain alignment for subsequent data
        return std.mem.alignForward(usize, total_size, SERIALIZATION_ALIGNMENT);
    }

    /// Serialize this Store into the provided buffer
    pub fn serializeInto(self: *const Self, buffer: []u8, allocator: Allocator) ![]u8 {
        const size = self.serializedSize();
        if (buffer.len < size) return error.BufferTooSmall;

        var offset: usize = 0;
        _ = allocator;

        // Write sizes
        const slots_size = self.slots.serializedSize();
        @as(*u32, @ptrCast(@alignCast(buffer.ptr + offset))).* = @intCast(slots_size);
        offset += @sizeOf(u32);

        const descs_size = self.descs.serializedSize();
        @as(*u32, @ptrCast(@alignCast(buffer.ptr + offset))).* = @intCast(descs_size);
        offset += @sizeOf(u32);

        const record_fields_size = self.record_fields.serializedSize();
        @as(*u32, @ptrCast(@alignCast(buffer.ptr + offset))).* = @intCast(record_fields_size);
        offset += @sizeOf(u32);

        const tags_size = self.tags.serializedSize();
        @as(*u32, @ptrCast(@alignCast(buffer.ptr + offset))).* = @intCast(tags_size);
        offset += @sizeOf(u32);

        const vars_size = self.vars.serializedSize();
        @as(*u32, @ptrCast(@alignCast(buffer.ptr + offset))).* = @intCast(vars_size);
        offset += @sizeOf(u32);

        // Serialize data
        offset = std.mem.alignForward(usize, offset, SERIALIZATION_ALIGNMENT);
        const slots_buffer = @as([]align(SERIALIZATION_ALIGNMENT) u8, @alignCast(buffer[offset .. offset + slots_size]));
        const slots_slice = try self.slots.serializeInto(slots_buffer);
        offset += slots_slice.len;

        const descs_slice = try self.descs.serializeInto(buffer[offset..]);
        offset += descs_slice.len;

        offset = std.mem.alignForward(usize, offset, SERIALIZATION_ALIGNMENT);
        const record_fields_buffer = @as([]align(SERIALIZATION_ALIGNMENT) u8, @alignCast(buffer[offset .. offset + record_fields_size]));
        const record_fields_slice = try self.record_fields.serializeInto(record_fields_buffer);
        offset += record_fields_slice.len;

        offset = std.mem.alignForward(usize, offset, SERIALIZATION_ALIGNMENT);
        const tags_buffer = @as([]align(SERIALIZATION_ALIGNMENT) u8, @alignCast(buffer[offset .. offset + tags_size]));
        const tags_slice = try self.tags.serializeInto(tags_buffer);
        offset += tags_slice.len;

        offset = std.mem.alignForward(usize, offset, SERIALIZATION_ALIGNMENT);
        const vars_buffer = @as([]align(SERIALIZATION_ALIGNMENT) u8, @alignCast(buffer[offset .. offset + vars_size]));
        const vars_slice = try self.vars.serializeInto(vars_buffer);
        offset += vars_slice.len;

        // Zero out any padding bytes
        if (offset < size) {
            @memset(buffer[offset..size], 0);
        }

        return buffer[0..size];
    }

    /// Deserialize a Store from the provided buffer
    pub fn deserializeFrom(buffer: []const u8, allocator: Allocator) !Self {
        if (buffer.len < @sizeOf(u32) * 5) return error.BufferTooSmall;

        var offset: usize = 0;

        // Read sizes
        const slots_size = @as(*const u32, @ptrCast(@alignCast(buffer.ptr + offset))).*;
        offset += @sizeOf(u32);

        const descs_size = @as(*const u32, @ptrCast(@alignCast(buffer.ptr + offset))).*;
        offset += @sizeOf(u32);

        const record_fields_size = @as(*const u32, @ptrCast(@alignCast(buffer.ptr + offset))).*;
        offset += @sizeOf(u32);

        const tags_size = @as(*const u32, @ptrCast(@alignCast(buffer.ptr + offset))).*;
        offset += @sizeOf(u32);

        const vars_size = @as(*const u32, @ptrCast(@alignCast(buffer.ptr + offset))).*;
        offset += @sizeOf(u32);

        // Deserialize data
        offset = std.mem.alignForward(usize, offset, SERIALIZATION_ALIGNMENT);
        const slots_buffer = @as([]align(SERIALIZATION_ALIGNMENT) const u8, @alignCast(buffer[offset .. offset + slots_size]));
        const slots = try SlotStore.deserializeFrom(slots_buffer, allocator);
        offset += slots_size;

        const descs_buffer = buffer[offset .. offset + descs_size];
        const descs = try DescStore.deserializeFrom(descs_buffer, allocator);
        offset += descs_size;

        offset = std.mem.alignForward(usize, offset, SERIALIZATION_ALIGNMENT);
        const record_fields_buffer = @as([]align(SERIALIZATION_ALIGNMENT) const u8, @alignCast(buffer[offset .. offset + record_fields_size]));
        const record_fields = try RecordFieldSafeMultiList.deserializeFrom(record_fields_buffer, allocator);
        offset += record_fields_size;

        offset = std.mem.alignForward(usize, offset, SERIALIZATION_ALIGNMENT);
        const tags_buffer = @as([]align(SERIALIZATION_ALIGNMENT) const u8, @alignCast(buffer[offset .. offset + tags_size]));
        const tags = try TagSafeMultiList.deserializeFrom(tags_buffer, allocator);
        offset += tags_size;

        offset = std.mem.alignForward(usize, offset, SERIALIZATION_ALIGNMENT);
        const vars_buffer = @as([]align(SERIALIZATION_ALIGNMENT) const u8, @alignCast(buffer[offset .. offset + vars_size]));
        const vars = try VarSafeList.deserializeFrom(vars_buffer, allocator);
        offset += vars_size;

        return Self{
            .gpa = allocator,
            .slots = slots,
            .descs = descs,
            .record_fields = record_fields,
            .tags = tags,
            .vars = vars,
        };
    }
};

/// Represents a store of slots
const SlotStore = struct {
    const Self = @This();

    backing: collections.SafeList(Slot),

    fn init(gpa: Allocator, capacity: usize) std.mem.Allocator.Error!Self {
        return .{ .backing = try collections.SafeList(Slot).initCapacity(gpa, capacity) };
    }

    fn deinit(self: *Self, gpa: Allocator) void {
        self.backing.deinit(gpa);
    }

    /// Insert a new slot into the store
    fn insert(self: *Self, gpa: Allocator, typ: Slot) std.mem.Allocator.Error!Idx {
        const safe_idx = try self.backing.append(gpa, typ);
        return @enumFromInt(@intFromEnum(safe_idx));
    }

    /// Insert a value into the store
    fn appendAssumeCapacity(self: *Self, gpa: Allocator, typ: Slot) std.mem.Allocator.Error!Idx {
        const safe_idx = try self.backing.append(gpa, typ);
        return @enumFromInt(@intFromEnum(safe_idx));
    }

    /// Set a value in the store
    pub fn set(self: *Self, idx: Idx, val: Slot) void {
        self.backing.set(@enumFromInt(@intFromEnum(idx)), val);
    }

    /// Get a value from the store
    fn get(self: *const Self, idx: Idx) Slot {
        return self.backing.get(@enumFromInt(@intFromEnum(idx))).*;
    }

    /// Calculate the size needed to serialize this SlotStore
    pub fn serializedSize(self: *const Self) usize {
        return self.backing.serializedSize();
    }

    /// Serialize this SlotStore into the provided buffer
    pub fn serializeInto(self: *const Self, buffer: []align(SERIALIZATION_ALIGNMENT) u8) ![]align(SERIALIZATION_ALIGNMENT) const u8 {
        return self.backing.serializeInto(buffer);
    }

    /// Deserialize a SlotStore from the provided buffer
    pub fn deserializeFrom(buffer: []align(SERIALIZATION_ALIGNMENT) const u8, allocator: Allocator) !Self {
        const backing = try collections.SafeList(Slot).deserializeFrom(buffer, allocator);
        return Self{ .backing = backing };
    }

    /// A type-safe index into the store
    const Idx = enum(u32) { _ };
};

/// Represents a store of descriptors
///
/// Indexes into the list are typesafe
const DescStore = struct {
    const Self = @This();

    backing: std.MultiArrayList(Desc),

    /// Init & allocated memory
    fn init(gpa: Allocator, capacity: usize) std.mem.Allocator.Error!Self {
        var arr = std.MultiArrayList(Desc){};
        try arr.ensureUnusedCapacity(gpa, capacity);
        return .{ .backing = arr };
    }

    /// Deinit & free allocated memory
    pub fn deinit(self: *Self, gpa: Allocator) void {
        self.backing.deinit(gpa);
    }

    /// Insert a value into the store
    fn insert(self: *Self, gpa: Allocator, typ: Desc) std.mem.Allocator.Error!Idx {
        const idx: Idx = @enumFromInt(self.backing.len);
        try self.backing.append(gpa, typ);
        return idx;
    }

    /// Set a value in the store
    fn set(self: *Self, idx: Idx, val: Desc) void {
        self.backing.set(@intFromEnum(idx), val);
    }

    /// Get a value from the store
    fn get(self: *const Self, idx: Idx) Desc {
        return self.backing.get(@intFromEnum(idx));
    }

    /// Calculate the size needed to serialize this DescStore
    pub fn serializedSize(self: *const Self) usize {
        const raw_size = @sizeOf(u32) + (self.backing.len * (@sizeOf(Content) + 1 + 4));
        // Align to SERIALIZATION_ALIGNMENT to maintain alignment for subsequent data
        return std.mem.alignForward(usize, raw_size, SERIALIZATION_ALIGNMENT);
    }

    /// Serialize this DescStore into the provided buffer
    pub fn serializeInto(self: *const Self, buffer: []u8) ![]u8 {
        const size = self.serializedSize();
        if (buffer.len < size) return error.BufferTooSmall;

        // Write count
        std.mem.writeInt(u32, buffer[0..4], @intCast(self.backing.len), .little);

        var offset: usize = @sizeOf(u32);

        // Write data
        if (self.backing.len > 0) {
            const slice = self.backing.slice();
            for (slice.items(.content), slice.items(.rank), slice.items(.mark)) |content, rank, mark| {
                // Serialize each field individually to avoid padding
                @memcpy(buffer[offset .. offset + @sizeOf(Content)], std.mem.asBytes(&content));
                offset += @sizeOf(Content);

                buffer[offset] = @intFromEnum(rank);
                offset += 1;

                std.mem.writeInt(u32, buffer[offset .. offset + 4][0..4], @intFromEnum(mark), .little);
                offset += 4;
            }
        }

        // Zero out any padding bytes
        if (offset < size) {
            @memset(buffer[offset..size], 0);
        }

        return buffer[0..size];
    }

    /// Deserialize a DescStore from the provided buffer
    pub fn deserializeFrom(buffer: []const u8, allocator: Allocator) !Self {
        if (buffer.len < @sizeOf(u32)) return error.BufferTooSmall;

        const count = std.mem.readInt(u32, buffer[0..4], .little);
        const expected_size = @sizeOf(u32) + (count * (@sizeOf(Content) + 1 + 4));

        if (buffer.len < expected_size) return error.BufferTooSmall;

        var result = try Self.init(allocator, count);

        if (count > 0) {
            var offset: usize = @sizeOf(u32);
            for (0..count) |_| {
                const item_size = @sizeOf(Content) + 1 + 4;
                if (offset + item_size > buffer.len) return error.BufferTooSmall;

                // Deserialize each field individually
                const content = std.mem.bytesAsValue(Content, buffer[offset .. offset + @sizeOf(Content)]).*;
                offset += @sizeOf(Content);

                const rank: Rank = @enumFromInt(buffer[offset]);
                offset += 1;

                const mark: Mark = @enumFromInt(std.mem.readInt(u32, buffer[offset .. offset + 4][0..4], .little));
                offset += 4;

                const desc = Desc{ .content = content, .rank = rank, .mark = mark };
                _ = try result.insert(allocator, desc);
            }
        }

        return result;
    }

    /// A type-safe index into the store
    /// This type is made public below
    const Idx = enum(u32) { _ };
};

/// An index into the desc store
pub const DescStoreIdx = DescStore.Idx;

// path compression

test "resolveVarAndCompressPath - flattens redirect chain to flex_var" {
    const gpa = std.testing.allocator;

    var store = try Store.init(gpa);
    defer store.deinit();

    const c = try store.fresh();
    const b = try store.freshRedirect(c);
    const a = try store.freshRedirect(b);

    const result = store.resolveVarAndCompressPath(a);
    try std.testing.expectEqual(Content{ .flex_var = null }, result.desc.content);
    try std.testing.expectEqual(c, result.var_);
    try std.testing.expectEqual(Slot{ .redirect = c }, store.getSlot(a));
    try std.testing.expectEqual(Slot{ .redirect = c }, store.getSlot(b));
}

test "resolveVarAndCompressPath - no-op on already root" {
    const gpa = std.testing.allocator;

    var store = try Store.init(gpa);
    defer store.deinit();

    const num_flex = try store.fresh();
    const requirements = Num.IntRequirements{
        .sign_needed = false,
        .bits_needed = 0,
    };
    const num = Content{ .structure = .{ .num = .{ .num_poly = .{ .var_ = num_flex, .requirements = requirements } } } };
    const num_var = try store.freshFromContent(num);

    const result = store.resolveVarAndCompressPath(num_var);

    try std.testing.expectEqual(num, result.desc.content);
    try std.testing.expectEqual(num_var, result.var_);
    // try std.testing.expectEqual(store.getSlot(num_var), Slot{ .root = num_desc_idx });
}

test "resolveVarAndCompressPath - flattens redirect chain to structure" {
    const gpa = std.testing.allocator;

    var store = try Store.init(gpa);
    defer store.deinit();

    const num_flex = try store.fresh();
    const requirements = Num.IntRequirements{
        .sign_needed = false,
        .bits_needed = 0,
    };
    const num = Content{ .structure = .{ .num = .{ .num_poly = .{ .var_ = num_flex, .requirements = requirements } } } };
    const c = try store.freshFromContent(num);
    const b = try store.freshRedirect(c);
    const a = try store.freshRedirect(b);

    const result = store.resolveVarAndCompressPath(a);
    try std.testing.expectEqual(num, result.desc.content);
    try std.testing.expectEqual(c, result.var_);
    try std.testing.expectEqual(Slot{ .redirect = c }, store.getSlot(a));
    try std.testing.expectEqual(Slot{ .redirect = c }, store.getSlot(b));
}

test "Slot serialization comprehensive" {
    const gpa = std.testing.allocator;

    // Test various slot types including edge cases
    const slot1 = Slot{ .root = @enumFromInt(0) }; // minimum value
    const slot2 = Slot{ .root = @enumFromInt(0xFFFFFFFF) }; // maximum value
    const slot3 = Slot{ .redirect = @enumFromInt(0) }; // minimum redirect
    const slot4 = Slot{ .redirect = @enumFromInt(0xFFFFFFFF) }; // maximum redirect

    // Test serialization using the testing framework
    try serialization.testing.testSerialization(Slot, &slot1, gpa);
    try serialization.testing.testSerialization(Slot, &slot2, gpa);
    try serialization.testing.testSerialization(Slot, &slot3, gpa);
    try serialization.testing.testSerialization(Slot, &slot4, gpa);
}

test "DescStore serialization comprehensive" {
    const gpa = std.testing.allocator;

    var store = try DescStore.init(gpa, 8);
    defer store.deinit(gpa);

    // Add various descriptor types including edge cases
    const desc1 = Descriptor{
        .content = Content{ .flex_var = null },
        .rank = Rank.generalized,
        .mark = Mark.none,
    };

    const desc2 = Descriptor{
        .content = Content{ .flex_var = @bitCast(@as(u32, 0)) },
        .rank = Rank.top_level,
        .mark = Mark.visited,
    };

    const desc3 = Descriptor{
        .content = Content{ .flex_var = @bitCast(@as(u32, 0xFFFFFFFF)) },
        .rank = Rank.top_level,
        .mark = Mark.visited,
    };

    _ = try store.insert(gpa, desc1);
    _ = try store.insert(gpa, desc2);
    _ = try store.insert(gpa, desc3);

    // Test serialization
    try serialization.testing.testSerialization(DescStore, &store, gpa);
}

test "DescStore empty store serialization" {
    const gpa = std.testing.allocator;

    var empty_store = try DescStore.init(gpa, 0);
    defer empty_store.deinit(gpa);

    try serialization.testing.testSerialization(DescStore, &empty_store, gpa);
}
