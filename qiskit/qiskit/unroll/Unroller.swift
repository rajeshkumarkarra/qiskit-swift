//
//  Unroller.swift
//  qiskit
//
//  Created by Manoel Marques on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 OPENQASM interpreter object that unrolls subroutines and loops.
 */
final class Unroller {

    /**
     Abstract syntax tree from parser
     */
    private let ast: Node
    /**
     Backend object
     */
    private(set) var backend: UnrollerBackend?
    /**
     OPENQASM version number
     */
    private let version: Double = 0.0
    /**
     Dict of qreg names and sizes
     */
    private let qregs: [String:Int] = [:]
    /**
     Dict of creg names and sizes
    */
    private let cregs: [String:Int] = [:]
    /**
     Dict of gates names and properties
     */
    private let gates: [String:GateData] = [:]
    /**
     List of dictionaries mapping local parameter ids to real values
     */
    private let arg_stack: Stack<[String:Double]> = Stack<[String:Double]>()
    /**
     List of dictionaries mapping local bit ids to global ids (name,idx)
     */
    private let bit_stack: Stack<[String:RegBit]> = Stack<[String:RegBit]>()

    /**
     Initialize interpreter's data.
     */
    init(_ ast: Node, _ backend: UnrollerBackend? = nil) {
        self.ast = ast
        self.backend = backend
    }

    /**
     Process an Id or IndexedId node as a bit or register type.
     Return a list of tuples (name,index).
     */
    private func _process_bit_id(_ node: Node) throws -> [RegBit] {
        if node.type == "indexed_id" {
            // An indexed bit or qubit
            return [RegBit(node.name, node.index)]
        }
        if node.type == "id" {
            // A qubit or qreg or creg
            var bits: [String:RegBit] = [:]
            if let map = self.bit_stack.peek() {
                bits = map
            }
            if bits.isEmpty {
                // Global scope
                if let size = self.qregs[node.name] {
                    var array: [RegBit] = []
                    for j in 0..<size {
                        array.append(RegBit(node.name,j))
                    }
                    return array
                }
                if let size = self.cregs[node.name] {
                    var array: [RegBit] = []
                    for j in 0..<size {
                        array.append(RegBit(node.name,j))
                    }
                    return array
                }
                throw UnrollerException.errorregname(line: node.line,file: node.file)
            }
            // local scope
            if let regBit = bits[node.name] {
                return [regBit]
            }
            throw UnrollerException.errorlocalbit(line: node.line,file: node.file)
        }
        return []
    }

    /**
     Process an Id node as a local id.
     */
    private func _process_local_id(_ node: Node) throws -> Double {
        // The id must be in arg_stack i.e. the id is inside a gate_body
        var id_dict: [String:Double] = [:]
        if let map = self.arg_stack.peek() {
            id_dict = map
        }
        if let value = id_dict[node.name] {
            return value
        }
        throw UnrollerException.errorlocalparameter(line: node.line,file: node.file)
    }

    private func _process_node(_ node: Node) throws -> Double {
        preconditionFailure("_process_node not implemented")
    }

    /**
     Set the backend object
     */
    func set_backend(_ backend: UnrollerBackend?) {
        self.backend = backend
    }

    /**
     Interpret OPENQASM and make appropriate backend calls.
     */
    func execute() throws {
        if self.backend != nil {
            _ = try self._process_node(self.ast)
        }
        throw UnrollerException.errorbackend
    }
}
