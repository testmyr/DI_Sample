//
//  WebOperation.swift
//  DI_Sample
//
//  Created by sdk on 30.09.2021.
//

import Foundation


class WebOperation: Operation {
    enum State: String {
        case ready
        case executing
        case finished
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    private let stateQueue = DispatchQueue(label: "asynchronous.operation.state", attributes: .concurrent)
    private var state_ = State.ready
    var state: State {
        get {
            return stateQueue.sync(execute: {
                state_
            })
        }
        set {
            let oldValue = state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier, execute: {
                state_ = newValue
            })
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }

    open override var isReady: Bool {
        return super.isReady && state == .ready
    }
    public override var isExecuting: Bool {
        return state == .executing
    }
    public override var isFinished: Bool {
        return state == .finished
    }
    
    public override func start() {
        if isCancelled {
            state = .finished
            return
        }
        state = .ready
        main()
    }
}
