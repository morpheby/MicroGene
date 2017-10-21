//
//  Ragistration.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation

public func registerGene<T>(_ type: T.Type) where T: Gene {
    DelayedRegistration.shared.genes.append(type)
}

internal class DelayedRegistration {
    var genes: [Gene.Type] = []

    static var shared: DelayedRegistration = {
        DelayedRegistration()
    }()

    private init() {

    }
}
