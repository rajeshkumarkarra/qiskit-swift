//
//  QiskitProgramTests.swift
//  qiskit
//
//  Created by Joe Ligman on 7/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
import qiskit

class QiskitProgramTests: XCTestCase {

    private static let QPS_SPECS: [String: Any] = [
        "name": "program-name",
        "circuits": [[
            "name": "circuitName",
            "quantum_registers": [
                ["name": "qname", "size": 3]
            ],
            "classical_registers": [
                ["name": "cname", "size": 3],
            ]]]
    ]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCreateProgram() {
        do {
            let result: QuantumProgram? = try QuantumProgram()
            XCTAssertTrue(result != nil)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testConfigScriptsFile() {
        do {
            let qconf = try Qconfig()
            XCTAssertEqual(qconf.url.absoluteString, "https://quantumexperience.ng.bluemix.net/api/")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testGetComponents() {
        do {
            let qprogram = try QuantumProgram(specs: QiskitProgramTests.QPS_SPECS)
            let elements = qprogram.get_quantum_elements()
             XCTAssertTrue(elements.0 != nil)
             XCTAssertTrue(elements.1 != nil)
             XCTAssertTrue(elements.2 != nil)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testGetIndividualComponents() {
        do {
            let qprogram = try QuantumProgram(specs: QiskitProgramTests.QPS_SPECS)
            let qc = qprogram.get_circuit("circuitName")
            let qr = qprogram.get_quantum_registers("qname")
            let cr = qprogram.get_classical_registers("cname")
            XCTAssertTrue(qc != nil)
            XCTAssertTrue(qr != nil)
            XCTAssertTrue(cr != nil)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCreateClassicalRegister() {
        do {
            let qprogram = try QuantumProgram()
            let cr = try qprogram.create_classical_registers("cr", 3)
            XCTAssertTrue(cr.name == "cr" && cr.size == 3)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCreateQuantumRegister() {
        do {
            let qprogram = try QuantumProgram()
            let qr = try qprogram.create_quantum_registers("qr", 3)
            XCTAssertTrue(qr.name == "qr" && qr.size == 3)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCreateCircuit() {
        do {
            let qprogram = try QuantumProgram()
            let qr = try qprogram.create_quantum_registers("qr", 3)
            let cr = try qprogram.create_classical_registers("cr", 3)
            let qc: QuantumCircuit? = try qprogram.create_circuit("qc", ["qr"], ["cr"])
            XCTAssertTrue(qr.name == "qr" && qr.size == 3)
            XCTAssertTrue(cr.name == "cr" && cr.size == 3)
            XCTAssertNotNil(qc)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCreateServeralCircuits() {
        do {
            let qprogram = try QuantumProgram()
            let qr = try qprogram.create_quantum_registers("qr", 3)
            let cr = try qprogram.create_classical_registers("cr", 3)
            let qc1: QuantumCircuit? = try qprogram.create_circuit("qc1", ["qr"], ["cr"])
            let qc2: QuantumCircuit? = try qprogram.create_circuit("qc2", ["qr"], ["cr"])
            let qc3: QuantumCircuit? = try qprogram.create_circuit("qc3", ["qr"], ["cr"])
            XCTAssertTrue(qr.name == "qr" && qr.size == 3)
            XCTAssertTrue(cr.name == "cr" && cr.size == 3)
            XCTAssertNotNil(qc1)
            XCTAssertNotNil(qc2)
            XCTAssertNotNil(qc3)
        } catch {
            XCTFail("\(error)")
        }

    }
    
    func testPrintCircuit() {
        do {
            let qprogram = try QuantumProgram(specs: QiskitProgramTests.QPS_SPECS)
            let elements = qprogram.get_quantum_elements()
            guard let qc = elements.0 else {
                XCTFail("Quantum circuit not defined!")
                return }
            guard let qr = elements.1 else {
                XCTFail("Quantum register not defined!")
                return  }
            
            _ = try qc.h(qr[1])
            let result = qc.qasm()
            XCTAssertEqual(result, "OPENQASM 2.0;\ninclude \"qelib1.inc\";\nqreg qname[3];\ncreg cname[3];\nh qname[1];")
            
        } catch {
            XCTFail("\(error)")
        }
    }

    func testPrintProgram() {
        do {
            let qprogram = try QuantumProgram(specs: QiskitProgramTests.QPS_SPECS)
            guard let qc = qprogram.get_circuit("circuitName") else {
                XCTFail("Quantum circuit not defined!")
                return
            }
            guard let qr = qprogram.get_quantum_registers("qname") else {
                XCTFail("Quantum register not defined!")
                return
            }
            
            guard let _ = qprogram.get_classical_registers("cname") else {
                XCTFail("Classical register not defined!")
                return
            }
            
             _ = try qc.h(qr[1])
            let result = try qprogram.get_qasm("circuitName")
            XCTAssertEqual(result, "OPENQASM 2.0;\ninclude \"qelib1.inc\";\nqreg qname[3];\ncreg cname[3];\nh qname[1];")
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testAddGates() {
        do {
            let qprogram = try QuantumProgram(specs: QiskitProgramTests.QPS_SPECS)
            guard let qc = qprogram.get_circuit("circuitName") else {
                XCTFail("Quantum circuit not defined!")
                return
            }
            guard let qr = qprogram.get_quantum_registers("qname") else {
                XCTFail("Quantum register not defined!")
                return
            }
            
            guard let cr = qprogram.get_classical_registers("cname") else {
                XCTFail("Classical register not defined!")
                return
            }
            
            try qc.u3(0.3, 0.2, 0.1, qr[0])
            try qc.h(qr[1])
            try qc.cx(qr[1], qr[2])
            try qc.barrier()
            try qc.cx(qr[0], qr[1])
            try qc.h(qr[0])
            try qc.z(qr[2]).c_if(cr, 1)
            try qc.x(qr[2]).c_if(cr, 1)
            try qc.measure(qr[0], cr[0])
            try qc.measure(qr[1], cr[1])
            
            let result = try qprogram.get_qasm("circuitName")
            XCTAssertEqual(result, "OPENQASM 2.0;\ninclude \"qelib1.inc\";\nqreg qname[3];\ncreg cname[3];\nu3(0.300000000000000,0.200000000000000,0.100000000000000) qname[0];\nh qname[1];\ncx qname[1],qname[2];\nbarrier qname[0],qname[1],qname[2];\ncx qname[0],qname[1];\nh qname[0];\nif(cname==1) z qname[2];\nif(cname==1) x qname[2];\nmeasure qname[0] -> cname[0];\nmeasure qname[1] -> cname[1];")
            
        } catch {
            XCTFail("\(error)")
        }
   
    }

    func testCreateCircuitMultipleRegisters() {
        do {
            let qprogram = try QuantumProgram(specs: QiskitProgramTests.QPS_SPECS)

            let _ = qprogram.get_quantum_registers("qname")
            let _ = qprogram.get_classical_registers("cname")
            let _ = try qprogram.create_quantum_registers("qr", 3)
            let _ = try qprogram.create_classical_registers("cr", 3)
            
            let result = try qprogram.create_circuit("qc2",
                                                 ["qname", "qr"],
                                                 ["cname", "cr"])
            
            XCTAssertEqual(result.qasm(), "OPENQASM 2.0;\ninclude \"qelib1.inc\";\nqreg qname[3];\nqreg qr[3];\ncreg cname[3];\ncreg cr[3];")
        } catch {
            XCTFail("\(error)")
        }
        
    }

    func testContactMultipleHorizontalRegisters() {
        do {
            let qprogram = try QuantumProgram(specs: QiskitProgramTests.QPS_SPECS)
            

            guard let qr = qprogram.get_quantum_registers("qname") else {
                XCTFail("Quantum register not defined!")
                return
            }
            
            guard let cr = qprogram.get_classical_registers("cname") else {
                XCTFail("Classical register not defined!")
                return
            }
            
            let qc2 = try qprogram.create_circuit("qc2",
                                                     ["qname"],
                                                     ["cname"])

            let qc3 = try qprogram.create_circuit("qc3",
                                                  ["qname"],
                                                  ["cname"])

            try qc2.h(qr[0])
            try qc3.h(qr[0])
            try qc2.measure(qr[0], cr[0])
            try qc3.measure(qr[0], cr[0])
            let qc_result = try qc2 + qc3

            XCTAssertEqual(qc_result.qasm(), "OPENQASM 2.0;\ninclude \"qelib1.inc\";\nqreg qname[3];\ncreg cname[3];\nh qname[0];\nmeasure qname[0] -> cname[0];")
        } catch {
            XCTFail("\(error)")
        }
        
    }
    
    func testCompileProgram() {
        do {
            let qprogram = try QuantumProgram(specs: QiskitProgramTests.QPS_SPECS)
            guard let qc = qprogram.get_circuit("circuitName") else {
                XCTFail("Quantum circuit not defined!")
                return
            }
            guard let qr = qprogram.get_quantum_registers("qname") else {
                XCTFail("Quantum register not defined!")
                return
            }
            
            guard let cr = qprogram.get_classical_registers("cname") else {
                XCTFail("Classical register not defined!")
                return
            }
            
            try qc.h(qr[0])
            try qc.h(qr[0])
            try qc.measure(qr[0], cr[0])

            
            try qprogram.compile(["circuitName"])
            guard let to_test = qprogram.get_circuit("circuitName") else {
                XCTFail("Quantum circuit not defined!")
                return
            }
            XCTAssertEqual(to_test.qasm(), "OPENQASM 2.0;\ninclude \"qelib1.inc\";\nqreg qname[3];\ncreg cname[3];\nh qname[0];\nh qname[0];\nmeasure qname[0] -> cname[0];")
        } catch {
            XCTFail("\(error)")
        }
        
    }
    
}

