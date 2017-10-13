//
//  Path.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public struct Path {
    var storable: StorableId
    var innermostCompartment: CompartmentIndex
}

public protocol PathRepresentable {
    var fullPath: Path? { get }
}

internal struct PathPartial: PathRepresentable {
    var storable: StorableId?
    var innermostCompartment: CompartmentIndex?

    var fullPath: Path? {
        guard let s = storable,
        let i = innermostCompartment else { return nil }

        return Path(storable: s, innermostCompartment: i)
    }
}

public func || (lhv: CompartmentIndex, rhv: CompartmentId) -> PathRepresentable {
    let compartment = CompartmentIndex(id: rhv, parent: lhv)

    return PathPartial(storable: nil, innermostCompartment: compartment)
}

public func || (lhv: CompartmentIndex, rhv: StorableId) -> Path {
    return Path(storable: rhv, innermostCompartment: lhv)
}

public func || (lhv: CompartmentId, rhv: CompartmentId) -> PathRepresentable {
    let topCompartment = CompartmentIndex(id: lhv)
    let innerCompartment = CompartmentIndex(id: rhv, parent: topCompartment)

    return PathPartial(storable: nil, innermostCompartment: innerCompartment)
}

public func || (lhv: CompartmentId, rhv: StorableId) -> Path {
    let topCompartment = CompartmentIndex(id: lhv)

    return Path(storable: rhv, innermostCompartment: topCompartment)
}

public func || (lhv: PathRepresentable, rhv: CompartmentId) -> PathRepresentable {
    guard let partial = lhv as? PathPartial else { preconditionFailure("Incompatible PathRepresentable type") }

    let compartment: CompartmentIndex
    if let inner =  partial.innermostCompartment {
        compartment = CompartmentIndex(id: rhv, parent: inner)
    } else {
        compartment = CompartmentIndex(id: rhv)
    }

    return PathPartial(storable: nil, innermostCompartment: compartment)
}

public func || (lhv: PathRepresentable, rhv: StorableId) -> Path {
    guard let partial = lhv as? PathPartial else { preconditionFailure("Incompatible PathRepresentable type") }

    guard let compartment = partial.innermostCompartment else { preconditionFailure("Path should have compartment before being closed") }

    return Path(storable: rhv, innermostCompartment: compartment)
}


