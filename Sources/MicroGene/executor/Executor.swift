//
//  Executor.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public class Executor: Executing {

    private var executionQueue: OperationQueue

    public init() {
        executionQueue = OperationQueue()
        executionQueue.qualityOfService = .userInteractive
        executionQueue.maxConcurrentOperationCount = 1
    }

    public func untie(_ closure: @escaping () -> ()) {
        executionQueue.addOperation {
            closure()
        }
    }

    public func untieSync(_ closure: () -> ()) {
        withoutActuallyEscaping(closure) { c in
            let condition = NSCondition()

            condition.lock()
            defer {
                condition.unlock()
            }

            var completed = false
            executionQueue.addOperation {
                c()
                condition.lock()
                defer {
                    condition.unlock()
                }
                completed = true
                condition.signal()
            }

            while !completed {
                condition.wait()
            }
        }
    }

    private func executeUnsafe(_ executable: Executable) -> [AnyOutput] {
        let result = executable.execute()
        return result
    }

    public func execute(_ executable: Executable) -> [AnyOutput] {
        if OperationQueue.current != executionQueue {
            return jumpback(executable)
        }

        return executeUnsafe(executable)
    }

    private func jumpback(_ executable: Executable) -> [AnyOutput] {
        let condition = NSCondition()

        condition.lock()
        defer {
            condition.unlock()
        }

        var resultCompleted: [AnyOutput]? = nil
        executionQueue.addOperation {
            let result = self.executeUnsafe(executable)
            condition.lock()
            defer {
                condition.unlock()
            }
            resultCompleted = result
            condition.signal()
        }

        while resultCompleted == nil {
            condition.wait()
        }

        return resultCompleted!
    }
}

