//
//  World.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public class World: Storing {

    private class StorageCompartment {
        let index: CompartmentIndex
        var storage: [CompartmentIndex: StorageCompartment] = [:]
        var localData: [StorableId: Storable] = [:]

        init(index: CompartmentIndex) {
            self.index = index
        }
    }

    private var rootStorage = StorageCompartment(index: CompartmentIndex.rootCompartment)

    public var delegate: WorldDelegate? = nil

    private func compartment(for path: Path) -> StorageCompartment {
        var compartmentIdx: CompartmentIndex = path.innermostCompartment
        var compartmentChain: [CompartmentIndex] = [compartmentIdx]

        while let parent = compartmentIdx.parent {
            compartmentChain.append(parent)
            compartmentIdx = parent
        }

        var currentCompartment = rootStorage
        for compartmentIdx in compartmentChain {
            precondition(currentCompartment === rootStorage || compartmentIdx.parent == currentCompartment.index,
                         "Invalid path chain supplied or invalid compartment tree in World")
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

    public func put(data: Storable, to path: Path) {
        let compartment = self.compartment(for: path)

        precondition(compartment.localData[path.storable] == nil,
                     "Data already present. Overwrite and overlay are forbidden in MicroGene")

        compartment.localData[path.storable] = data

        delegate?.didPutValue(world: self, for: path, value: data)
    }

    public func take(from path: Path) -> Storable? {
        let compartment = self.compartment(for: path)

        let data = compartment.localData.removeValue(forKey: path.storable)

        if let d = data {
            delegate?.didTakeValue(world: self, for: path, value: d)
        }

        return data
    }
}

public protocol WorldDelegate {
    /// Invoked right after adding value to the compartment.
    func didPutValue(world: World, for path: Path, value: Storable)
    func didTakeValue(world: World, for path: Path, value: Storable)
}


