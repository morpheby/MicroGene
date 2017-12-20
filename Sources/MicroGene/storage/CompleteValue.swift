//
//  CompleteValue.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 20.12.2017.
//

import Foundation

public protocol AnyCompleteValue {
    var state: StorableState { get set }
    var anyValue: AnyStorable { get }

    func typed<T>() -> CompleteValue<T>?
}

public struct AnyCompleteValueConcrete {
    public var state: StorableState
    public var value: AnyStorable
}

extension AnyCompleteValueConcrete: AnyCompleteValue {
    public var anyValue: AnyStorable {
        get { return self.value }
    }

    public func typed<U>() -> CompleteValue<U>? {
        guard let typedValue = value as? U else { return nil }
        return CompleteValue<U>(state: self.state, value: typedValue)
    }
}

public struct CompleteValue<T: AnyStorable> {
    public var state: StorableState
    public var value: T

    public init(state: StorableState, value: T) {
        self.state = state
        self.value = value
    }

    public init(_ value: T) {
        self.init(state: StorableState(), value: value)
    }
}

extension CompleteValue: AnyCompleteValue {
    public var anyValue: AnyStorable {
        get { return self.value }
    }

    public func typed<U>() -> CompleteValue<U>? {
        guard let typedValue = value as? U else { return nil }
        return CompleteValue<U>(state: self.state, value: typedValue)
    }
}
