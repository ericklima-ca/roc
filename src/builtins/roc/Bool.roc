module [Bool, Eq, true, false, not, is_eq, is_not_eq]

## Defines a type that can be compared for total equality.
##
## Total equality means that all values of the type can be compared to each
## other, and two values `a`, `b` are identical if and only if `is_eq(a, b)` is
## `Bool.true`.
##
## Not all types support total equality. For example, [`F32`](Num#F32) and [`F64`](Num#F64) can
## be a `NaN` ([Not a Number](https://en.wikipedia.org/wiki/NaN)), and the
## [IEEE-754](https://en.wikipedia.org/wiki/IEEE_754) floating point standard
## specifies that two `NaN`s are not equal.
Eq(a) : a
    where
        ## Returns `Bool.true` if the input values are equal. This is
        ## equivalent to the logic
        ## [XNOR](https://en.wikipedia.org/wiki/Logical_equality) gate. The infix
        ## operator `==` can be used as shorthand for `Bool.is_eq`.
        ##
        ## **Note** that when `is_eq` is determined by the Roc compiler, values are
        ## compared using structural equality. The rules for this are as follows:
        ##
        ## 1. Tags are equal if their name and also contents are equal.
        ## 2. Records are equal if their fields are equal.
        ## 3. The collections [Str], [List], [Dict], and [Set] are equal iff they
        ## are the same length and their elements are equal.
        ## 4. [Num] values are equal if their numbers are equal. However, if both
        ## inputs are *NaN* then `is_eq` returns `Bool.false`. Refer to `Num.is_nan`
        ## for more detail.
        ## 5. Functions cannot be compared for structural equality, therefore Roc
        ## cannot derive `is_eq` for types that contain functions.
        a.is_eq(a) -> Bool,

## Represents the boolean true and false using an nominal type.
## `Bool` implements the `Eq` ability.
Bool := [True, False]

## The boolean true value.
true : Bool
true = Bool.True

## The boolean false value.
false : Bool
false = Bool.False

## Satisfies the interface of `Eq`
is_eq : Bool, Bool -> Bool
is_eq = |b1, b2| match (b1, b2) {
    (Bool.True, Bool.True) => true
    (Bool.False, Bool.False) => true
    _ => false
}

## Returns `Bool.false` when given `Bool.true`, and vice versa. This is
## equivalent to the logic [NOT](https://en.wikipedia.org/wiki/Negation)
## gate. The operator `!` can also be used as shorthand for `Bool.not`.
## ```roc
## expect Bool.not(Bool.false) == Bool.true
## expect Bool.false != Bool.true
## ```
not : Bool -> Bool
not = |b| match b {
    Bool.True => false
    Bool.False => true
}

## This will call the function `Bool.is_eq` on the inputs, and then `Bool.not`
## on the result. The is equivalent to the logic
## [XOR](https://en.wikipedia.org/wiki/Exclusive_or) gate. The infix operator
## `!=` can also be used as shorthand for `Bool.is_not_eq`.
##
## **Note** that `is_not_eq` does not accept arguments whose types contain
## functions.
## ```roc
## expect Bool.is_not_eq(Bool.false, Bool.true) == Bool.true
## expect (Bool.false != Bool.false) == Bool.false
## expect "Apples" != "Oranges"
## ```
is_not_eq : a, a -> Bool where a.Eq
is_not_eq = |a, b| not(a.is_eq(b))
