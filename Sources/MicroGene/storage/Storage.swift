//
//  World.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public class Storage: Storing {

    private class StorageCompartment {
        let index: CompartmentIndex
        var storage: [CompartmentIndex: StorageCompartment] = [:]
        var localData: [StorableId: [AnyStorable]] = [:]

        init(index: CompartmentIndex) {
            self.index = index
        }
    }

    private var rootStorage = StorageCompartment(index: .root)

    public var delegate: StorageDelegate? = nil

    public init() { }

    private func compartment(for path: Path) -> StorageCompartment {
        var compartmentIdx: CompartmentIndex = path.compartment
        var compartmentChain: [CompartmentIndex] = [compartmentIdx]

        while case let .node(_, parent) = compartmentIdx {
            compartmentChain.append(parent)
            compartmentIdx = parent
        }

        var currentCompartment = rootStorage
        for compartmentIdx in compartmentChain.reversed().dropFirst() {
            let nextCompartment: StorageCompartment
            if let c = currentCompartment.storage[compartmentIdx] {
                nextCompartment = c
            } else {
                let newCompartment = StorageCompartment(index: compartmentIdx)
                currentCompartment.storage[compartmentIdx] = newCompartment
                nextCompartment = newCompartment
            }
            currentCompartment = nextCompartment
        }

        return currentCompartment
    }

    public func put(data: AnyStorable, to path: Path) {
        let compartment = self.compartment(for: path)

        if compartment.localData[path.storable] == nil {
            compartment.localData[path.storable] = []
        }
        compartment.localData[path.storable]!.append(data)

        delegate?.didPutValue(storage: self, for: path, value: data)
    }

    public func take<T>(from path: Path) -> T? where T: AnyStorable {
        let compartment = self.compartment(for: path)

        var found: T? = nil

        if let dataView = compartment.localData[path.storable] {
            if let dataIdx = (dataView.index { v in v as? T != nil }) {
                found = (compartment.localData[path.storable]?.remove(at: dataIdx) as! T)
            }
        }

        if compartment.localData[path.storable]?.count == 0 {
            compartment.localData[path.storable] = nil
        }

        if let d = found {
            delegate?.didTakeValue(storage: self, for: path, value: d)
        }

        return found
    }
}

public protocol StorageDelegate {
    /// Invoked right after adding value to the compartment.
    func didPutValue(storage: Storage, for path: Path, value: AnyStorable)
    func didTakeValue(storage: Storage, for path: Path, value: AnyStorable)
}


