//
//  Executor.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public class Executor: Executing {
    public init() {
    }

}

extension Executor: WorldDelegate {
    public func didTakeValue(world: World, for path: Path, value: Storable) {

    }

    public func didPutValue(world: World, for path: Path, value: Storable) {

    }
}
