//
//  Executing.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public protocol Executing {

    func untie(_ closure: @escaping () -> ())

    func untieSync(_ closure: () -> ())

    func execute(_ executable: Executable) -> [AnyOutput]
}
