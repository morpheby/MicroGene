//
//  Priority.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation

fileprivate class RealPriority {
    var lowerPriority: RealPriority?
    var higherPriority: RealPriority?

    func makePriority() -> Priority {
        return Priority(real: self)
    }
}

public struct Priority {
    fileprivate var real: RealPriority

    fileprivate init(real: RealPriority) {
        self.real = real
    }

    public var lower: Priority {
        if let p = self.real.lowerPriority {
            return p.makePriority()
        } else {
            let p = RealPriority()
            self.real.lowerPriority = p
            p.higherPriority = self.real
            return p.makePriority()
        }
    }

    public var higher: Priority {
        if let p = self.real.higherPriority {
            return p.makePriority()
        } else {
            let p = RealPriority()
            self.real.higherPriority = p
            p.lowerPriority = self.real
            return p.makePriority()
        }
    }

    public static func lower(than other: Priority) -> Priority {
        return other.lower
    }

    public static func higher(than other: Priority) -> Priority {
        return other.higher
    }

    public mutating func makeLower() {
        self = self.lower
    }

    public mutating func makeHigher() {
        self = self.higher
    }
}

extension Priority {
    public static let normal = Priority(real: RealPriority())
}

extension Priority: Equatable {
    public static func == (lhv: Priority, rhv: Priority) -> Bool {
        return lhv.real === rhv.real
    }
}

extension Priority: Hashable {
    public var hashValue: Int {
        return ObjectIdentifier(real).hashValue
    }
}

extension Priority: Comparable {
    public static func < (lhv: Priority, rhv: Priority) -> Bool {
        guard lhv != rhv else { return false }
        var lhvUp: RealPriority = lhv.real
        var lhvDown: RealPriority = lhv.real
        while true {
            // Go to the higher priorities, and if none are higher, then lhv > rhv
            if let up = lhvUp.higherPriority { lhvUp = up }
            else { return false }

            // If found higher priority that is rhv, return true
            if lhvUp === rhv.real { return true }

            // Go to the lower priorities (this is an attempt at heuristic optimization)
            if let down = lhvDown.lowerPriority {
                lhvDown = down
                // If we found rhv among lower priorities, then lhv > rhv
                if lhvDown === rhv.real { return false }
            }
        }
    }
}

