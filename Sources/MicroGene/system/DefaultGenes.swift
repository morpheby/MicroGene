//
//  DefaultGenes.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation

open class Startup: Gene {
    public static let bindings: [AnyVariableBinding] = [
        !.microgeneEntry <> \Startup.entry
    ]

    public var entry = Var(Entry.self)

    open static let priority = Priority.stubs

    public required init() { }

    public func match() -> Bool {
        return true
    }

    open func execute() -> [AnyOutput] {
        return []
    }
}

public class Shutdown: Gene, RequiresSystem {
    public static let bindings: [AnyVariableBinding] = [
        !.microgeneExit <> \Shutdown.exit
    ]

    public var exit = Var(Exit.self)
    internal var system: System!

    open static let priority = Priority.stubs

    public required init() { }

    public func match() -> Bool {
        return true
    }

    open func execute() -> [AnyOutput] {
        system.terminate()
        return []
    }
}

