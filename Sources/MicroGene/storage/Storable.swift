//
//  Value.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public protocol Storable {
    
}

// XXX: Best expressed with a conditional conformance (which is not available yet in Swift 4.0)
extension ImplicitlyUnwrappedOptional: Storable { }
