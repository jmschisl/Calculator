//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Jason Schisler on 7/17/17.
//  Copyright © 2017 Jason Schisler. All rights reserved.
//

import Foundation

func changeSign(operand: Double) -> Double {
    return -operand
}

func multiply(op1: Double, op2: Double) -> Double {
    return op1 * op2
}

struct CalculatorBrain {
    
    private var accumulator: (Double, String)?
    
    private enum Operation {
        case constant(Double)
        case nullaryOperation(() -> Double, String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private let operations: Dictionary<String,Operation> = [
        "Rand": Operation.nullaryOperation( { Double(arc4random()) / Double(UInt32.max) }, "rand()"),
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "x²" : Operation.unaryOperation({ pow($0, 2) }, { "(" + $0 + ")²" }),
        "x³" : Operation.unaryOperation({ pow($0, 3) }, { "(" + $0 + ")³" }),
        "x⁻¹" : Operation.unaryOperation({ 1 / $0 }, {  "(" + $0 + ")⁻¹" }),
        "√": Operation.unaryOperation(sqrt, { "√(" + $0 + ")" }),
        "sin": Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
        "cos": Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
        "tan": Operation.unaryOperation(tan, { "tan(" + $0 + ")" }),
        "sinh" : Operation.unaryOperation(sinh, { "sinh(" + $0 + ")" }),
        "cosh" : Operation.unaryOperation(cosh, { "sinh(" + $0 + ")" }),
        "tanh" : Operation.unaryOperation(tanh, { "sinh(" + $0 + ")" }),
        "ln" : Operation.unaryOperation(log, { "ln(" + $0 + ")" }),
        "log" : Operation.unaryOperation(log10, { "log(" + $0 + ")" }),
        "eˣ" : Operation.unaryOperation(exp, { "e^(" + $0 + ")" }),
        "10ˣ" : Operation.unaryOperation({ pow(10, $0) }, { "10^(" + $0 + ")" }),
        "±": Operation.unaryOperation({ -$0 }, { "-(" + $0 + ")" }),
        "xʸ" : Operation.binaryOperation(pow, { $0 + "^" + $1 }),
        "×": Operation.binaryOperation(*, { $0 + "×" + $1 }),
        "÷": Operation.binaryOperation(/, { $0 + "÷" + $1 }),
        "+": Operation.binaryOperation(+, { $0 + "+" + $1 }),
        "-": Operation.binaryOperation(-, { $0 + "-" + $1 }),
        "=": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, symbol)
            case .nullaryOperation(let function, let description):
                accumulator = (function(), description)
            case .unaryOperation(let function, let description):
                if nil != accumulator {
                    accumulator = (function(accumulator!.0), description(accumulator!.1))
                }
            case .binaryOperation(let function, let description):
                performPendingBinaryOperation()
                if nil != accumulator {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if nil != pendingBinaryOperation && nil != accumulator {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let description: (String, String) -> String
        let firstOperand: (Double, String)
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), "(" + description(firstOperand.1, secondOperand.1) + ")")
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, "\(operand)")
    }
    
    var result: Double? {
        get {
            if nil != accumulator {
                return accumulator!.0
            }
            return nil        }
    }
    
    var resultIsPending: Bool {
        get {
            return nil != pendingBinaryOperation
        }
    }
    
    var description: String? {
        get {
            if resultIsPending {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            } else {
                return accumulator?.1
            }
        }
    }
}

