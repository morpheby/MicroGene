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

extension Executor: StorageDelegate {
    public func didTakeValue(storage: Storage, for path: Path, value: AnyStorable) {

    }

    public func didPutValue(storage: Storage, for path: Path, value: AnyStorable) {

    }
}
