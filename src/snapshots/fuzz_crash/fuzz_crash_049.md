# META
~~~ini
description=fuzz crash
type=file
~~~
# SOURCE
~~~roc
# Thnt!
app [main!] { pf: platform "c" }

import pf.Stdout exposing [line!, e!]

import Stdot
		exposing [ #tem
		] # Cose

import pkg.S exposing [func as fry, Custom.*]

import �����s Gooe
import
	Ba
Map(a, b) : List(a), (a ->c) -> List(b)
MapML( # Cere
	a, # Anre
	b,
) # Ag
	: # Aon
		List( #rg
		),
		(a -> b) -> # row
			List(			b	) #

Foo : (Bar, Baz)

line : ( # Cpen
	Bar, #
	Baz, #\
) # Co
Some(a) : { foo : Ok(a), bar : g }
Ml(a) : { # d
	bar : Som# Afld
}

Soine(a) : { #d
	bar : Som
} #
Maya) : [ #
] #se

Func(a) : Maybe(a), a ->    e(a)

ane = |num| if num 2 else 5

add_one : U64 -> U64
add_one = |num| {
	other = 1
	if num {
		dbg # bug
() #r
		0
	} else {
		dbg 123
		other
	}
}

match_time = |
	a, #rg
	b,
|  As
	match a {lue | Red => {
			x x
		}
		Blue		=> 1
		"foo" => # ent
00
		"foo" | "bar" => 20[1, 2, 3, .. as rest] # Aftet
			=> ment


		[1, 2 | 5, 3, .. as rest] => 123
		[
ist
		] => 123
		3.14 => 314
		3.14 | 6.28 => 314
		(((((((((1, 2, 3) => 123
		(1, 2 | 5, 3) => 123
		{ foo: 1, bar: 2, ..rest } => 12->add(34)
		{ # Afrd open
			foo #
				: #ue
					1, # Aftd field
			bar: 2,
			..} => 12
		{ foo: 1, bar: 2 | 7 } => 12
		{
			foo: 1,
			} => 12
		Ok(123) => 121000
	}

expect # Commeneyword
	blah == 1 # Commnt
(main! : List(String) -> Result({}, _)
main! = |_| { # Yeah Ie
	world = "World"
	var number = 123
	expect blah == 1
	tag = Blue
	return # Comd
		tag

	# Jusnt!

	...
	match_t       (pe�son, updated]

persodbg # bug
			42, # Aft expr
	)
	crash "Unreachtement
	tag_with = Ok(number)
world}"
	list = [
		add_one(
			dbg # Afin list
e[, # afarg
		),	456, # ee
	]
	for n in list {
	line!("Adding ${n} to ${number}")
		number = number + m�	}
	record = { foo: 123, bar: "Hello", baz: tag, qux: Ok(world), punned }
	tuple = (123, "World", tag, Ok(world), (nested, tuple), [1, 2, 3])
	m_tuple = (
		123,
		"World",
		tag1,
		Ok(world), # Thisnt
		(nested, tuple),
		[1, 2, 3],
	)
	bsult = Err(foo) ?? 12 > 5 * 5 or 13 + 2 < 5 and 10 - 1 >= 16 or 12 <= 3 Err(foo) ?? 12 > 5 * 5 or 13 + / 5
	stale = some_fn(arg1)?.statod()?.ned()?.recd?
	Stdoline!(
		"How about ${ #
			Num.toStr(number) # on expr
		} as a",
	)
} # Commenl decl

empty : {}
empty = {}

tuple : Value((a, b, c))

expect {
	foo = 1 # Thio
	blah = 1
	blah == foo
}
~~~
# EXPECTED
ASCII CONTROL CHARACTER - :0:0:0:0
OVER CLOSED BRACE - :0:0:0:0
ASCII CONTROL CHARACTER - :0:0:0:0
ASCII CONTROL CHARACTER - :0:0:0:0
ASCII CONTROL CHARACTER - :0:0:0:0
ASCII CONTROL CHARACTER - :0:0:0:0
ASCII CONTROL CHARACTER - :0:0:0:0
LEADING ZERO - :0:0:0:0
MISMATCHED BRACE - :0:0:0:0
MISMATCHED BRACE - :0:0:0:0
MISMATCHED BRACE - :0:0:0:0
UNCLOSED STRING - :0:0:0:0
MISMATCHED BRACE - :0:0:0:0
UNCLOSED STRING - :0:0:0:0
MISMATCHED BRACE - :0:0:0:0
MISMATCHED BRACE - :0:0:0:0
MISMATCHED BRACE - :0:0:0:0
# PROBLEMS
**ASCII CONTROL CHARACTER**
ASCII control characters are not allowed in Roc source code.

**OVER CLOSED BRACE**
There are too many closing braces here.

**ASCII CONTROL CHARACTER**
ASCII control characters are not allowed in Roc source code.

**ASCII CONTROL CHARACTER**
ASCII control characters are not allowed in Roc source code.

**ASCII CONTROL CHARACTER**
ASCII control characters are not allowed in Roc source code.

**ASCII CONTROL CHARACTER**
ASCII control characters are not allowed in Roc source code.

**ASCII CONTROL CHARACTER**
ASCII control characters are not allowed in Roc source code.

**LEADING ZERO**
Numbers cannot have leading zeros.

**MISMATCHED BRACE**
This brace does not match the corresponding opening brace.

**MISMATCHED BRACE**
This brace does not match the corresponding opening brace.

**MISMATCHED BRACE**
This brace does not match the corresponding opening brace.

**UNCLOSED STRING**
This string is missing a closing quote.

**MISMATCHED BRACE**
This brace does not match the corresponding opening brace.

**UNCLOSED STRING**
This string is missing a closing quote.

**MISMATCHED BRACE**
This brace does not match the corresponding opening brace.

**MISMATCHED BRACE**
This brace does not match the corresponding opening brace.

**MISMATCHED BRACE**
This brace does not match the corresponding opening brace.

# TOKENS
~~~zig
KwApp(2:1-2:4),OpenSquare(2:5-2:6),LowerIdent(2:6-2:11),CloseSquare(2:11-2:12),OpenCurly(2:13-2:14),LowerIdent(2:15-2:17),OpColon(2:17-2:18),KwPlatform(2:19-2:27),StringStart(2:28-2:29),StringPart(2:29-2:30),StringEnd(2:30-2:31),CloseCurly(2:32-2:33),
KwImport(4:1-4:7),LowerIdent(4:8-4:10),NoSpaceDotUpperIdent(4:10-4:17),KwExposing(4:18-4:26),OpenSquare(4:27-4:28),LowerIdent(4:28-4:33),Comma(4:33-4:34),LowerIdent(4:35-4:37),CloseSquare(4:37-4:38),
KwImport(6:1-6:7),UpperIdent(6:8-6:13),
KwExposing(7:3-7:11),OpenSquare(7:12-7:13),
CloseSquare(8:3-8:4),
KwImport(10:1-10:7),LowerIdent(10:8-10:11),NoSpaceDotUpperIdent(10:11-10:13),KwExposing(10:14-10:22),OpenSquare(10:23-10:24),LowerIdent(10:24-10:28),KwAs(10:29-10:31),LowerIdent(10:32-10:35),Comma(10:35-10:36),UpperIdent(10:37-10:43),DotStar(10:43-10:45),CloseSquare(10:45-10:46),
KwImport(12:1-12:7),MalformedUnicodeIdent(12:8-12:24),UpperIdent(12:25-12:29),
KwImport(13:1-13:7),
UpperIdent(14:2-14:4),
UpperIdent(15:1-15:4),NoSpaceOpenRound(15:4-15:5),LowerIdent(15:5-15:6),Comma(15:6-15:7),LowerIdent(15:8-15:9),CloseRound(15:9-15:10),OpColon(15:11-15:12),UpperIdent(15:13-15:17),NoSpaceOpenRound(15:17-15:18),LowerIdent(15:18-15:19),CloseRound(15:19-15:20),Comma(15:20-15:21),OpenRound(15:22-15:23),LowerIdent(15:23-15:24),OpArrow(15:25-15:27),LowerIdent(15:28-15:29),CloseRound(15:29-15:30),OpArrow(15:31-15:33),UpperIdent(15:34-15:38),NoSpaceOpenRound(15:38-15:39),LowerIdent(15:39-15:40),CloseRound(15:40-15:41),
UpperIdent(16:1-16:6),NoSpaceOpenRound(16:6-16:7),
LowerIdent(17:2-17:3),Comma(17:3-17:4),
LowerIdent(18:2-18:3),Comma(18:3-18:4),
CloseRound(19:1-19:2),
OpColon(20:2-20:3),
UpperIdent(21:3-21:7),NoSpaceOpenRound(21:7-21:8),
CloseRound(22:3-22:4),Comma(22:4-22:5),
OpenRound(23:3-23:4),LowerIdent(23:4-23:5),OpArrow(23:6-23:8),LowerIdent(23:9-23:10),CloseRound(23:10-23:11),OpArrow(23:12-23:14),
UpperIdent(24:4-24:8),NoSpaceOpenRound(24:8-24:9),LowerIdent(24:12-24:13),CloseRound(24:14-24:15),
UpperIdent(26:1-26:4),OpColon(26:5-26:6),OpenRound(26:7-26:8),UpperIdent(26:8-26:11),Comma(26:11-26:12),UpperIdent(26:13-26:16),CloseRound(26:16-26:17),
LowerIdent(28:1-28:5),OpColon(28:6-28:7),OpenRound(28:8-28:9),
UpperIdent(29:2-29:5),Comma(29:5-29:6),
UpperIdent(30:2-30:5),Comma(30:5-30:6),
CloseRound(31:1-31:2),
UpperIdent(32:1-32:5),NoSpaceOpenRound(32:5-32:6),LowerIdent(32:6-32:7),CloseRound(32:7-32:8),OpColon(32:9-32:10),OpenCurly(32:11-32:12),LowerIdent(32:13-32:16),OpColon(32:17-32:18),UpperIdent(32:19-32:21),NoSpaceOpenRound(32:21-32:22),LowerIdent(32:22-32:23),CloseRound(32:23-32:24),Comma(32:24-32:25),LowerIdent(32:26-32:29),OpColon(32:30-32:31),LowerIdent(32:32-32:33),CloseCurly(32:34-32:35),
UpperIdent(33:1-33:3),NoSpaceOpenRound(33:3-33:4),LowerIdent(33:4-33:5),CloseRound(33:5-33:6),OpColon(33:7-33:8),OpenCurly(33:9-33:10),
LowerIdent(34:2-34:5),OpColon(34:6-34:7),UpperIdent(34:8-34:11),
CloseCurly(35:1-35:2),
UpperIdent(37:1-37:6),NoSpaceOpenRound(37:6-37:7),LowerIdent(37:7-37:8),CloseRound(37:8-37:9),OpColon(37:10-37:11),OpenCurly(37:12-37:13),
LowerIdent(38:2-38:5),OpColon(38:6-38:7),UpperIdent(38:8-38:11),
CloseCurly(39:1-39:2),
UpperIdent(40:1-40:5),OpColon(40:7-40:8),OpenSquare(40:9-40:10),
CloseSquare(41:1-41:2),
UpperIdent(43:1-43:5),NoSpaceOpenRound(43:5-43:6),LowerIdent(43:6-43:7),CloseRound(43:7-43:8),OpColon(43:9-43:10),UpperIdent(43:11-43:16),NoSpaceOpenRound(43:16-43:17),LowerIdent(43:17-43:18),CloseRound(43:18-43:19),Comma(43:19-43:20),LowerIdent(43:21-43:22),OpArrow(43:23-43:25),LowerIdent(43:30-43:31),NoSpaceOpenRound(43:31-43:32),LowerIdent(43:32-43:33),CloseRound(43:33-43:34),
LowerIdent(45:1-45:4),OpAssign(45:5-45:6),OpBar(45:7-45:8),LowerIdent(45:8-45:11),OpBar(45:11-45:12),KwIf(45:13-45:15),LowerIdent(45:16-45:19),Int(45:20-45:21),KwElse(45:22-45:26),Int(45:27-45:28),
LowerIdent(47:1-47:8),OpColon(47:9-47:10),UpperIdent(47:11-47:14),OpArrow(47:15-47:17),UpperIdent(47:18-47:21),
LowerIdent(48:1-48:8),OpAssign(48:9-48:10),OpBar(48:11-48:12),LowerIdent(48:12-48:15),OpBar(48:15-48:16),OpenCurly(48:17-48:18),
LowerIdent(49:2-49:7),OpAssign(49:8-49:9),Int(49:10-49:11),
KwIf(50:2-50:4),LowerIdent(50:5-50:8),OpenCurly(50:9-50:10),
KwDbg(51:3-51:6),
OpenRound(52:1-52:2),CloseRound(52:2-52:3),
Int(53:3-53:4),
CloseCurly(54:2-54:3),KwElse(54:4-54:8),OpenCurly(54:9-54:10),
KwDbg(55:3-55:6),Int(55:7-55:10),
LowerIdent(56:3-56:8),
CloseCurly(57:2-57:3),
CloseCurly(58:1-58:2),
LowerIdent(60:1-60:11),OpAssign(60:12-60:13),OpBar(60:14-60:15),
LowerIdent(61:2-61:3),Comma(61:3-61:4),
LowerIdent(62:2-62:3),Comma(62:3-62:4),
OpBar(63:1-63:2),UpperIdent(63:5-63:7),
KwMatch(64:2-64:7),LowerIdent(64:8-64:9),OpenCurly(64:10-64:11),LowerIdent(64:11-64:14),OpBar(64:15-64:16),UpperIdent(64:17-64:20),OpFatArrow(64:21-64:23),OpenCurly(64:24-64:25),
LowerIdent(65:4-65:5),LowerIdent(65:6-65:7),
CloseCurly(66:3-66:4),
UpperIdent(67:3-67:7),OpFatArrow(67:9-67:11),Int(67:12-67:13),
StringStart(68:3-68:4),StringPart(68:4-68:7),StringEnd(68:7-68:8),OpFatArrow(68:9-68:11),
Int(69:1-69:3),
StringStart(70:3-70:4),StringPart(70:4-70:7),StringEnd(70:7-70:8),OpBar(70:9-70:10),StringStart(70:11-70:12),StringPart(70:12-70:15),StringEnd(70:15-70:16),OpFatArrow(70:17-70:19),Int(70:20-70:22),OpenSquare(70:22-70:23),Int(70:23-70:24),Comma(70:24-70:25),Int(70:26-70:27),Comma(70:27-70:28),Int(70:29-70:30),Comma(70:30-70:31),DoubleDot(70:32-70:34),KwAs(70:35-70:37),LowerIdent(70:38-70:42),CloseSquare(70:42-70:43),
OpFatArrow(71:4-71:6),LowerIdent(71:7-71:11),
OpenSquare(74:3-74:4),Int(74:4-74:5),Comma(74:5-74:6),Int(74:7-74:8),OpBar(74:9-74:10),Int(74:11-74:12),Comma(74:12-74:13),Int(74:14-74:15),Comma(74:15-74:16),DoubleDot(74:17-74:19),KwAs(74:20-74:22),LowerIdent(74:23-74:27),CloseSquare(74:27-74:28),OpFatArrow(74:29-74:31),Int(74:32-74:35),
OpenSquare(75:3-75:4),
LowerIdent(76:1-76:4),
CloseSquare(77:3-77:4),OpFatArrow(77:5-77:7),Int(77:8-77:11),
Float(78:3-78:7),OpFatArrow(78:8-78:10),Int(78:11-78:14),
Float(79:3-79:7),OpBar(79:8-79:9),Float(79:10-79:14),OpFatArrow(79:15-79:17),Int(79:18-79:21),
OpenRound(80:3-80:4),NoSpaceOpenRound(80:4-80:5),NoSpaceOpenRound(80:5-80:6),NoSpaceOpenRound(80:6-80:7),NoSpaceOpenRound(80:7-80:8),NoSpaceOpenRound(80:8-80:9),NoSpaceOpenRound(80:9-80:10),NoSpaceOpenRound(80:10-80:11),NoSpaceOpenRound(80:11-80:12),Int(80:12-80:13),Comma(80:13-80:14),Int(80:15-80:16),Comma(80:16-80:17),Int(80:18-80:19),CloseRound(80:19-80:20),OpFatArrow(80:21-80:23),Int(80:24-80:27),
OpenRound(81:3-81:4),Int(81:4-81:5),Comma(81:5-81:6),Int(81:7-81:8),OpBar(81:9-81:10),Int(81:11-81:12),Comma(81:12-81:13),Int(81:14-81:15),CloseRound(81:15-81:16),OpFatArrow(81:17-81:19),Int(81:20-81:23),
OpenCurly(82:3-82:4),LowerIdent(82:5-82:8),OpColon(82:8-82:9),Int(82:10-82:11),Comma(82:11-82:12),LowerIdent(82:13-82:16),OpColon(82:16-82:17),Int(82:18-82:19),Comma(82:19-82:20),DoubleDot(82:21-82:23),LowerIdent(82:23-82:27),CloseCurly(82:28-82:29),OpFatArrow(82:30-82:32),Int(82:33-82:35),OpArrow(82:35-82:37),LowerIdent(82:37-82:40),NoSpaceOpenRound(82:40-82:41),Int(82:41-82:43),CloseRound(82:43-82:44),
OpenCurly(83:3-83:4),
LowerIdent(84:4-84:7),
OpColon(85:5-85:6),
Int(86:6-86:7),Comma(86:7-86:8),
LowerIdent(87:4-87:7),OpColon(87:7-87:8),Int(87:9-87:10),Comma(87:10-87:11),
DoubleDot(88:4-88:6),CloseCurly(88:6-88:7),OpFatArrow(88:8-88:10),Int(88:11-88:13),
OpenCurly(89:3-89:4),LowerIdent(89:5-89:8),OpColon(89:8-89:9),Int(89:10-89:11),Comma(89:11-89:12),LowerIdent(89:13-89:16),OpColon(89:16-89:17),Int(89:18-89:19),OpBar(89:20-89:21),Int(89:22-89:23),CloseCurly(89:24-89:25),OpFatArrow(89:26-89:28),Int(89:29-89:31),
OpenCurly(90:3-90:4),
LowerIdent(91:4-91:7),OpColon(91:7-91:8),Int(91:9-91:10),Comma(91:10-91:11),
CloseCurly(92:4-92:5),OpFatArrow(92:6-92:8),Int(92:9-92:11),
UpperIdent(93:3-93:5),NoSpaceOpenRound(93:5-93:6),Int(93:6-93:9),CloseRound(93:9-93:10),OpFatArrow(93:11-93:13),Int(93:14-93:20),
CloseRound(94:2-94:3),
KwExpect(96:1-96:7),
LowerIdent(97:2-97:6),OpEquals(97:7-97:9),Int(97:10-97:11),
OpenRound(98:1-98:2),LowerIdent(98:2-98:7),OpColon(98:8-98:9),UpperIdent(98:10-98:14),NoSpaceOpenRound(98:14-98:15),UpperIdent(98:15-98:21),CloseRound(98:21-98:22),OpArrow(98:23-98:25),UpperIdent(98:26-98:32),NoSpaceOpenRound(98:32-98:33),OpenCurly(98:33-98:34),CloseCurly(98:34-98:35),Comma(98:35-98:36),Underscore(98:37-98:38),CloseRound(98:38-98:39),
LowerIdent(99:1-99:6),OpAssign(99:7-99:8),OpBar(99:9-99:10),Underscore(99:10-99:11),OpBar(99:11-99:12),OpenCurly(99:13-99:14),
LowerIdent(100:2-100:7),OpAssign(100:8-100:9),StringStart(100:10-100:11),StringPart(100:11-100:16),StringEnd(100:16-100:17),
KwVar(101:2-101:5),LowerIdent(101:6-101:12),OpAssign(101:13-101:14),Int(101:15-101:18),
KwExpect(102:2-102:8),LowerIdent(102:9-102:13),OpEquals(102:14-102:16),Int(102:17-102:18),
LowerIdent(103:2-103:5),OpAssign(103:6-103:7),UpperIdent(103:8-103:12),
KwReturn(104:2-104:8),
LowerIdent(105:3-105:6),
TripleDot(109:2-109:5),
LowerIdent(110:2-110:9),OpenRound(110:16-110:17),MalformedUnicodeIdent(110:17-110:25),Comma(110:25-110:26),LowerIdent(110:27-110:34),CloseRound(110:34-110:35),
LowerIdent(112:1-112:9),
Int(113:4-113:6),Comma(113:6-113:7),
CloseCurly(114:2-114:3),
KwCrash(115:2-115:7),StringStart(115:8-115:9),StringPart(115:9-115:22),StringEnd(115:22-115:22),
LowerIdent(116:2-116:10),OpAssign(116:11-116:12),UpperIdent(116:13-116:15),NoSpaceOpenRound(116:15-116:16),LowerIdent(116:16-116:22),CloseRound(116:22-116:23),
LowerIdent(117:1-117:6),CloseRound(117:6-117:7),StringStart(117:7-117:8),StringPart(117:8-117:8),StringEnd(117:8-117:8),
LowerIdent(118:2-118:6),OpAssign(118:7-118:8),OpenSquare(118:9-118:10),
LowerIdent(119:3-119:10),NoSpaceOpenRound(119:10-119:11),
KwDbg(120:4-120:7),
LowerIdent(121:1-121:2),OpenSquare(121:2-121:3),Comma(121:3-121:4),
CloseSquare(122:3-122:4),Comma(122:4-122:5),Int(122:6-122:9),Comma(122:9-122:10),
CloseRound(123:2-123:3),
KwFor(124:2-124:5),LowerIdent(124:6-124:7),KwIn(124:8-124:10),LowerIdent(124:11-124:15),OpenCurly(124:16-124:17),
LowerIdent(125:2-125:7),NoSpaceOpenRound(125:7-125:8),StringStart(125:8-125:9),StringPart(125:9-125:16),OpenStringInterpolation(125:16-125:18),LowerIdent(125:18-125:19),CloseStringInterpolation(125:19-125:20),StringPart(125:20-125:24),OpenStringInterpolation(125:24-125:26),LowerIdent(125:26-125:32),CloseStringInterpolation(125:32-125:33),StringPart(125:33-125:33),StringEnd(125:33-125:34),CloseRound(125:34-125:35),
LowerIdent(126:3-126:9),OpAssign(126:10-126:11),LowerIdent(126:12-126:18),OpPlus(126:19-126:20),MalformedUnicodeIdent(126:21-126:25),CloseCurly(126:26-126:27),
LowerIdent(127:2-127:8),OpAssign(127:9-127:10),OpenCurly(127:11-127:12),LowerIdent(127:13-127:16),OpColon(127:16-127:17),Int(127:18-127:21),Comma(127:21-127:22),LowerIdent(127:23-127:26),OpColon(127:26-127:27),StringStart(127:28-127:29),StringPart(127:29-127:34),StringEnd(127:34-127:35),Comma(127:35-127:36),LowerIdent(127:37-127:40),OpColon(127:40-127:41),LowerIdent(127:42-127:45),Comma(127:45-127:46),LowerIdent(127:47-127:50),OpColon(127:50-127:51),UpperIdent(127:52-127:54),NoSpaceOpenRound(127:54-127:55),LowerIdent(127:55-127:60),CloseRound(127:60-127:61),Comma(127:61-127:62),LowerIdent(127:63-127:69),CloseCurly(127:70-127:71),
LowerIdent(128:2-128:7),OpAssign(128:8-128:9),OpenRound(128:10-128:11),Int(128:11-128:14),Comma(128:14-128:15),StringStart(128:16-128:17),StringPart(128:17-128:22),StringEnd(128:22-128:23),Comma(128:23-128:24),LowerIdent(128:25-128:28),Comma(128:28-128:29),UpperIdent(128:30-128:32),NoSpaceOpenRound(128:32-128:33),LowerIdent(128:33-128:38),CloseRound(128:38-128:39),Comma(128:39-128:40),OpenRound(128:41-128:42),LowerIdent(128:42-128:48),Comma(128:48-128:49),LowerIdent(128:50-128:55),CloseRound(128:55-128:56),Comma(128:56-128:57),OpenSquare(128:58-128:59),Int(128:59-128:60),Comma(128:60-128:61),Int(128:62-128:63),Comma(128:63-128:64),Int(128:65-128:66),CloseSquare(128:66-128:67),CloseRound(128:67-128:68),
LowerIdent(129:2-129:9),OpAssign(129:10-129:11),OpenRound(129:12-129:13),
Int(130:3-130:6),Comma(130:6-130:7),
StringStart(131:3-131:4),StringPart(131:4-131:9),StringEnd(131:9-131:10),Comma(131:10-131:11),
LowerIdent(132:3-132:7),Comma(132:7-132:8),
UpperIdent(133:3-133:5),NoSpaceOpenRound(133:5-133:6),LowerIdent(133:6-133:11),CloseRound(133:11-133:12),Comma(133:12-133:13),
OpenRound(134:3-134:4),LowerIdent(134:4-134:10),Comma(134:10-134:11),LowerIdent(134:12-134:17),CloseRound(134:17-134:18),Comma(134:18-134:19),
OpenSquare(135:3-135:4),Int(135:4-135:5),Comma(135:5-135:6),Int(135:7-135:8),Comma(135:8-135:9),Int(135:10-135:11),CloseSquare(135:11-135:12),Comma(135:12-135:13),
CloseRound(136:2-136:3),
LowerIdent(137:2-137:7),OpAssign(137:8-137:9),UpperIdent(137:10-137:13),NoSpaceOpenRound(137:13-137:14),LowerIdent(137:14-137:17),CloseRound(137:17-137:18),OpDoubleQuestion(137:19-137:21),Int(137:22-137:24),OpGreaterThan(137:25-137:26),Int(137:27-137:28),OpStar(137:29-137:30),Int(137:31-137:32),OpOr(137:33-137:35),Int(137:36-137:38),OpPlus(137:39-137:40),Int(137:41-137:42),OpLessThan(137:43-137:44),Int(137:45-137:46),OpAnd(137:47-137:50),Int(137:51-137:53),OpBinaryMinus(137:54-137:55),Int(137:56-137:57),OpGreaterThanOrEq(137:58-137:60),Int(137:61-137:63),OpOr(137:64-137:66),Int(137:67-137:69),OpLessThanOrEq(137:70-137:72),Int(137:73-137:74),UpperIdent(137:75-137:78),NoSpaceOpenRound(137:78-137:79),LowerIdent(137:79-137:82),CloseRound(137:82-137:83),OpDoubleQuestion(137:84-137:86),Int(137:87-137:89),OpGreaterThan(137:90-137:91),Int(137:92-137:93),OpStar(137:94-137:95),Int(137:96-137:97),OpOr(137:98-137:100),Int(137:101-137:103),OpPlus(137:104-137:105),OpSlash(137:106-137:107),Int(137:108-137:109),
LowerIdent(138:2-138:7),OpAssign(138:8-138:9),LowerIdent(138:10-138:17),NoSpaceOpenRound(138:17-138:18),LowerIdent(138:18-138:22),CloseRound(138:22-138:23),NoSpaceOpQuestion(138:23-138:24),NoSpaceDotLowerIdent(138:24-138:31),NoSpaceOpenRound(138:31-138:32),CloseRound(138:32-138:33),NoSpaceOpQuestion(138:33-138:34),NoSpaceDotLowerIdent(138:34-138:38),NoSpaceOpenRound(138:38-138:39),CloseRound(138:39-138:40),NoSpaceOpQuestion(138:40-138:41),NoSpaceDotLowerIdent(138:41-138:46),NoSpaceOpQuestion(138:46-138:47),
UpperIdent(139:2-139:11),NoSpaceOpenRound(139:11-139:12),
StringStart(140:3-140:4),StringPart(140:4-140:14),OpenStringInterpolation(140:14-140:16),
UpperIdent(141:4-141:7),NoSpaceDotLowerIdent(141:7-141:13),NoSpaceOpenRound(141:13-141:14),LowerIdent(141:14-141:20),CloseRound(141:20-141:21),
CloseStringInterpolation(142:3-142:4),StringPart(142:4-142:9),StringEnd(142:9-142:10),Comma(142:10-142:11),
CloseRound(143:2-143:3),
CloseSquare(144:1-144:2),
LowerIdent(146:1-146:6),OpColon(146:7-146:8),OpenCurly(146:9-146:10),CloseCurly(146:10-146:11),
LowerIdent(147:1-147:6),OpAssign(147:7-147:8),OpenCurly(147:9-147:10),CloseCurly(147:10-147:11),
LowerIdent(149:1-149:6),OpColon(149:7-149:8),UpperIdent(149:9-149:14),NoSpaceOpenRound(149:14-149:15),NoSpaceOpenRound(149:15-149:16),LowerIdent(149:16-149:17),Comma(149:17-149:18),LowerIdent(149:19-149:20),Comma(149:20-149:21),LowerIdent(149:22-149:23),CloseRound(149:23-149:24),CloseRound(149:24-149:25),
KwExpect(151:1-151:7),OpenCurly(151:8-151:9),
LowerIdent(152:2-152:5),OpAssign(152:6-152:7),Int(152:8-152:9),
LowerIdent(153:2-153:6),OpAssign(153:7-153:8),Int(153:9-153:10),
LowerIdent(154:2-154:6),OpEquals(154:7-154:9),LowerIdent(154:10-154:13),
CloseCurly(155:1-155:2),EndOfFile(155:2-155:2),
~~~
# PARSE
~~~clojure
(file @2.1-155.2
	(app @2.1-2.33
		(provides @2.5-2.12
			(exposed-lower-ident @2.6-2.11
				(text "main!")))
		(record-field @2.15-2.31 (name "pf")
			(e-string @2.28-2.31
				(e-string-part @2.29-2.30 (raw "c"))))
		(packages @2.13-2.33
			(record-field @2.15-2.31 (name "pf")
				(e-string @2.28-2.31
					(e-string-part @2.29-2.30 (raw "c"))))))
	(statements
		(s-import @4.1-4.38 (raw "pf.Stdout")
			(exposing
				(exposed-lower-ident @4.28-4.33
					(text "line!"))
				(exposed-lower-ident @4.35-4.37
					(text "e!"))))
		(s-import @6.1-8.4 (raw "Stdot"))
		(s-import @10.1-10.46 (raw "pkg.S")
			(exposing
				(exposed-lower-ident @10.24-10.35
					(text "func")
					(as "fry"))
				(exposed-upper-ident-star @10.37-10.45 (text "Custom"))))))
~~~
# FORMATTED
~~~roc
# Thnt!
app [main!] { pf: platform "c" }

import pf.Stdout exposing [line!, e!]

import Stdot # Cose

import pkg.S exposing [func as fry, Custom.*]


~~~
# CANONICALIZE
~~~clojure
(can-ir
	(s-import @4.1-4.38 (module "pf.Stdout") (qualifier "pf")
		(exposes
			(exposed (name "line!") (wildcard false))
			(exposed (name "e!") (wildcard false))))
	(s-import @6.1-8.4 (module "Stdot")
		(exposes))
	(s-import @10.1-10.46 (module "pkg.S") (qualifier "pkg")
		(exposes
			(exposed (name "func") (alias "fry") (wildcard false))
			(exposed (name "Custom") (wildcard true)))))
~~~
# TYPES
~~~clojure
(inferred-types
	(defs)
	(expressions))
~~~
