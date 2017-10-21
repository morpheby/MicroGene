//
//  Matching.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public protocol Matching {
    func match(value: AnyStorable, at path: Path, in storage: Storing) -> Bool

    // TODO: Remove double functions when Swift generics work the way they are supposed to
    func register<T>(_ matchableType: T.Type, onMatch matchClosure: @escaping (T) -> ()) where T: Matchable
    func registerUntyped(_ matchableType: Matchable.Type, onMatch matchClosure: @escaping (Matchable) -> ())
}
