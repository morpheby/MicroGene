//
//  Ragistration.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation

public struct _None { }

@discardableResult
public func registerGene<T>(_ type: T.Type) -> _None where T: Gene {
    DelayedRegistration.shared.genes.append(type)
    return _None()
}

internal class DelayedRegistration {
    var genes: [Gene.Type] = []

    static var shared: DelayedRegistration = {
        DelayedRegistration()
    }()

    private init() {

    }
}
