//
//  DefaultTypes.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation

extension CompartmentId {
    public static let core = CompartmentId(name: "MicroGene::Core")
}

extension StorableId {
    public static let entry = StorableId(name: "MGEntry")
    public static let exit = StorableId(name: "MGExit")
}

/// Emitted into `Path.microgeneEntry` on System.start()
public struct Entry {
}

/// Emit into `Path.microgeneExit` to exit system
public struct Exit {
}

extension Path {
    public static let microgeneEntry = /.core / .entry
    public static let microgeneExit = /.core / .exit
}

extension Priority {
    public static let stubs = Priority.lower(than: .normal)
}

extension Entry: Storable { }
extension Exit: Storable { }
