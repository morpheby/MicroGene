//
//  Gene.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation

public protocol Gene: Matchable, Executable {
}

public protocol RequiresStartupInitialization {
    static func startupHook()
}

internal protocol RequiresSystem {
    var system: System! { get set }
}
