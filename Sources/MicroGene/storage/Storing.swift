//
//  Storing.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public protocol Storing {
    func put(data: AnyStorable, to: Path)

    func put(values: [AnyStorable], to: Path)

    func take<T>(from: Path) -> T? where T: AnyStorable

    // TODO: Remove double functions when Swift generics work the way they are supposed to
    func takeAll<T>(from: Path) -> [T] where T: AnyStorable
    func takeAllUntyped(from: Path) -> [AnyStorable]
}
