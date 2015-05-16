//
//  HList.swift
//  swiftz
//
//  Created by Maxwell Swadling on 19/06/2014.
//  Copyright (c) 2014 Maxwell Swadling. All rights reserved.
//

import Darwin

// A HList can be thought of like a tuple, but with list-like operations on the types.

public protocol HList {
	typealias Head
	typealias Tail

	static var isNil : Bool { get }
	static var length : Int { get }
}

public struct HCons<H, T : HList> : HList {
	public typealias Head = H
	public typealias Tail = T

	public let head : H
	public let tail : T

	public init(h : H, t : T) {
		head = h
		tail = t
	}

	public static var isNil : Bool {
		return false
	}

	public static func makeNil() -> HCons<H, T> {
		return undefined() // impossible
	}

	public static func makeCons(h : Head, t : Tail) -> HCons<H, T> {
		return HCons<H, T>(h : h, t : t)
	}

	public static var length : Int {
		return (1 + Tail.length)
	}
}

public struct HNil : HList {
	public typealias Head = Nothing
	public typealias Tail = Nothing

	public init() {}

	public static var isNil : Bool {
		return true
	}

	public static func makeNil() -> HNil {
		return HNil()
	}
}

/// `HAppend` is a type-level append of two `HList`s.  They are instantiated with the type of the
/// first list (XS), the type of the second list (YS) and the type of the result (XYS).  When 
/// constructed, `HAppend` provides a safe append operation that yields the appropriate HList for 
/// the given types.
public struct HAppend<XS, YS, XYS> {
	public let append : (XS, YS) -> XYS

	private init(_ append : (XS, YS) -> XYS) {
		self.append = append
	}

	/// Creates an HAppend that appends Nil to a List.
	public static func makeAppend<L : HList>() -> HAppend<HNil, L, L> {
		return HAppend<HNil, L, L> { (_, l) in return l }
	}

	/// Creates an HAppend that appends two non-HNil HLists.
	public static func makeAppend<T, A : HList, B : HList, C : HList>(h : HAppend<A, B, C>) -> HAppend<HCons<T, A>, B, HCons<T, C>> {
		return HAppend<HCons<T, A>, B, HCons<T, C>> { (c, l) in
			return HCons(h: c.head, t: h.append(c.tail, l))
		}
	}
}
	}
}

// TODO : map and reverse
/// Uncomment if Swift decides to allow tuple patterns.
///// HCons<HCons<...>> Matcher (Induction Step):  If we've hit this overloading, we should have a cons
///// node, or at least something that matches HCons<HNil>
//public func ~=<H : HList where H.Head : Equatable, H.Tail : HList, H.Tail.Head : Equatable, H.Tail.Tail : HList>(pattern : H, predicate : (H.Head, H.Tail)) -> Bool {
//	if H.isNil {
//		return false
//	}
//
//	if let p = (pattern as? HCons<H.Head, H.Tail>), let ps = (p.tail as? HCons<H.Tail.Head, H.Tail.Tail>), let pt = (predicate.1 as? HCons<H.Tail.Head, H.Tail.Tail>) {
//		return (p.head == predicate.0) && (pt ~= (ps.head, ps.tail))
//	} else if let p = (pattern as? HCons<H.Head, H.Tail>), let ps = (p.tail as? HNil) {
//		return (p.head == predicate.0)
//	}
//	return error("Pattern match on HList expected HCons<HSCons<...>> or HCons<HNil> but got neither.")
//}
//
///// HCons<HNil> or HNil Matcher
//public func ~=<H : HList where H.Head : Equatable, H.Tail : HList>(pattern : H, predicate : (H.Head, H.Tail)) -> Bool {
//	if H.isNil {
//		return false
//	}
//	if let p = (pattern as? HCons<H.Head, H.Tail>) {
//		return (p.head == predicate.0)
//	} else 	if let p = (pattern as? HNil) {
//		return false
//	}
//	return error("Pattern match on HList expected HCons<HNil> or HNil but got neither.")
//}
//
///// HNil matcher.
//public func ~=<H : HList>(pattern : H, predicate : ()) -> Bool {
//	return H.isNil
//}
