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
    var state: StorableState { get }
    var path: Path { get }
    var universalValue: AnyStorable { get }
}

public struct Output<T> where T: AnyStorable {
    public var path: Path
    public var state: StorableState
    public var value: T

    public init(value: T, to path: Path) {
        self.init(value: value, with: StorableState(), to: path)
    }

    public init(value: T, with state: StorableState, to path: Path) {
        self.state = state
        self.value = value
        self.path = path
    }
}

extension Output: AnyOutput {
    public var universalValue: AnyStorable {
        return self.value as AnyStorable
    }
}
