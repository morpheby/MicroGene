//
//  flatten.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/15/17.
//

import Foundation

extension Sequence where Element: Sequence {
    func flatten() -> [Element.Element] {
        return self.flatMap { x in x }
    }
}

extension Sequence {
    func flatten<T>() -> [T] where Element == Optional<T> {
        return self.flatMap { x in x }
    }
}
