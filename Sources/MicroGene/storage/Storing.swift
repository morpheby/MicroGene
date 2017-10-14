//
//  Storing.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

internal protocol Storing {
    func put(data: Storable, to: Path)
    func take(from: Path) -> Storable?
}
