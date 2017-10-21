//
//  Executable.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation

public protocol Executable {
    func execute() -> [AnyOutput]
}

public protocol AnyOutput {
    var path: Path { get }
    var universalValue: AnyStorable { get }
}

public struct Output<T> where T: AnyStorable {
    public var path: Path
    public var value: T

    public init(value: T, to path: Path) {
        self.path = path
        self.value = value
    }
}

extension Output: AnyOutput {
    public var universalValue: AnyStorable {
        return self.value as AnyStorable
    }
}
