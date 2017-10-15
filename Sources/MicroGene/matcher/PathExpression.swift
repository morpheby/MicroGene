//
//  PathExpression.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public enum StorableExpression {
    case any
    case id(StorableId)
}

public enum CompartmentIdExpression {
    case any
    case id(CompartmentId)
}

public enum CompartmentPartialExpression {
    indirect case node(CompartmentIdExpression, parent: CompartmentPartialExpression)
    case root(CompartmentIdExpression)
}

public enum CompartmentRepeatingExpression {
    case repeating(CompartmentPartialExpression)
}

public enum CompartmentExpression {
    indirect case node(CompartmentIdExpression, parent: CompartmentExpression)
    indirect case repeating(expression: CompartmentPartialExpression, parent: CompartmentExpression)
    case root(CompartmentIndex)
}

public enum PathExpression {
    indirect case or(PathExpression, PathExpression)
    case single(storable: StorableExpression, compartment: CompartmentExpression)
}

extension CompartmentId {
    public static prefix func ! (_ value: CompartmentId) -> CompartmentIdExpression {
        return .id(value)
    }
}

extension StorableId {
    public static prefix func ! (_ value: StorableId) -> StorableExpression {
        return .id(value)
    }
}

extension CompartmentIndex {
    public static prefix func ! (_ value: CompartmentIndex) -> CompartmentExpression {
        return .root(value)
    }
}

extension CompartmentIdExpression {
    public static prefix func / (_ value: CompartmentIdExpression) -> CompartmentExpression {
        return .node(value, parent: .root(.root))
    }

    public static prefix func ~/ (_ value: CompartmentIdExpression) -> CompartmentPartialExpression {
        return .root(value)
    }
}

extension Path {
    public static prefix func ! (_ value: Path) -> PathExpression {
        return .single(storable: .id(value.storable), compartment: .root(value.compartment))
    }
}

extension CompartmentExpression {
    public static func / (lhv: CompartmentExpression, rhv: CompartmentIdExpression) -> CompartmentExpression {
        return .node(rhv, parent: lhv)
    }

    public static func / (lhv: CompartmentExpression, rhv: CompartmentRepeatingExpression) -> CompartmentExpression {
        guard case let .repeating(value) = rhv else { fatalError("Unsupported enum (somehow)") }
        return .repeating(expression: value, parent: lhv)
    }

    public static func / (lhv: CompartmentExpression, rhv: StorableExpression) -> PathExpression {
        return .single(storable: rhv, compartment: lhv)
    }
}

extension CompartmentRepeatingExpression {
    public static prefix func / (_ value: CompartmentRepeatingExpression) -> CompartmentExpression {
        guard case let .repeating(v) = value else { fatalError("Unsupported enum (somehow)") }
        return .repeating(expression: v, parent: .root(.root))
    }
}

extension CompartmentPartialExpression {
    public static func / (lhv: CompartmentPartialExpression, rhv: CompartmentIdExpression) -> CompartmentPartialExpression {
        return .node(rhv, parent: lhv)
    }
}

extension PathExpression {
    public static func || (lhv: PathExpression, rhv: PathExpression) -> PathExpression {
        return .or(lhv, rhv)
    }
}
