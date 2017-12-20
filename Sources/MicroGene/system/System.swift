//
//  System.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public class System {
    private let matcher: Matching
    private let storage: Storing
    private let executor: Executing

    private var termination: Bool = false
    private let exitCondition = NSCondition()

    public convenience init() {
        self.init(storage: Storage(), matcher: Matcher(), executor: Executor())
    }

    public init(storage: Storing, matcher: Matching, executor: Executing) {
        let _ = allGenesRegistration

        self.storage = storage
        self.matcher = matcher
        self.executor = executor

        self.restoreDelayed()
    }

    private func restoreDelayed() {
        for delayed in DelayedRegistration.shared.genes {
            let t = delayed as Gene.Type
            registerUntyped(t)
        }
    }

    public func register<T>(_ type: T.Type) where T: Gene {
        matcher.register(type) { gene in
            let result = self.executor.execute(gene)
            for output in result {
                self.putUntyped(value: output.universalValue, state: output.state, path: output.path)
            }
        }
        if let t = type as? RequiresStartupInitialization.Type {
            t.startupHook(store: self.storage)
        }
    }

    public func registerUntyped(_ type: Gene.Type) {
        matcher.registerUntyped(type) { possiblyGene in
            guard let gene  = possiblyGene as? Gene else { fatalError("Untyped operation failed to resolve type: \(self.matcher) supplied value that is not Gene") }

            guard !self.termination else { return }
            if var r = gene as? RequiresSystem { r.system = self }

            let result = self.executor.execute(gene)
            self.executor.untie {
                for output in result {
                    self.putUntyped(value: output.universalValue, state: output.state, path: output.path)
                }
            }
        }
        if let t = type as? RequiresStartupInitialization.Type {
            t.startupHook(store: self.storage)
        }
    }

    private func _start() {
        self.put(value: Entry(), path: .microgeneEntry)
    }

    public func start() {
        self.executor.untie {
            self._start()
        }
    }

    public func startAndLock() {
        exitCondition.lock()
        defer {
            exitCondition.unlock()
        }

        start()

        while !self.termination {
            exitCondition.wait()
        }
    }

    // TODO: Remove double functions when Swift generics work the way they are supposed to
    private func _put(completeValue: AnyCompleteValue, path: Path) {
        if !matcher.match(value: completeValue, at: path, in: storage) {
            storage.put(data: completeValue, to: path)
        } else {
            // Ignore, since the execution is performed through the closure supplied earlier
        }
    }

    public func putUntyped(value: AnyStorable, state: StorableState, path: Path) {
        self._put(completeValue: AnyCompleteValueConcrete(state: state, value: value), path: path)
    }

    public func put<T>(value: T, state: StorableState, path: Path) where T: AnyStorable {
        self._put(completeValue: CompleteValue(state: state, value: value), path: path)
    }

    public func putUntyped(value: AnyStorable, path: Path) {
        self.putUntyped(value: value, state: StorableState(), path: path)
    }

    public func put<T>(value: T, path: Path) where T: AnyStorable {
        self.put(value: value, state: StorableState(), path: path)
    }

    internal func terminate() {
        exitCondition.lock()
        defer {
            exitCondition.unlock()
        }
        termination = true
        exitCondition.signal()
    }
}
