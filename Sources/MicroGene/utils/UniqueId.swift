//
//  UniqueId.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 15.12.2017.
//

import Foundation

public func globallyUniqueId() -> String {
    let uuid = UUID()
    return "@" + uuid.uuidString
}

fileprivate var localIdCounter: Int = 0

public func locallyUniqueId() -> String {
    localIdCounter += 1
    let lid = localIdCounter
    return "#" + lid.description
}
