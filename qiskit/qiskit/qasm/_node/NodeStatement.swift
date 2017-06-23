//
//  NodeStatement.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeStatment: Node {
    
    public let op: Node?
    public let p2: Node?
    public let p3: Node?
    public let p4: Node?
    
    public init(p1: Node?, p2: Node?, p3: Node?, p4: Node?) {
        self.op = p1 // decl | gatedecl | opqaue | qop | ifn | barrier
        self.p2 = p2 // nil | goplist | id | anylist
        self.p3 = p3 // nil | idlist
        self.p4 = p4 // nil | idlist | nninteger | qop
    
        if let type = self.op?.type {
            switch type {
            case .N_GATEDECL:
                if let gop = self.p2 {
                    (self.op as? NodeGateDecl)?.updateNode(gateBody: gop)
                }
            case .N_IF:
                if let nid = self.p2,
                    let idlist = self.p3,
                    let qop = self.p4 {
                    (self.op as? NodeIf)?.updateNode(identifier: nid, nninteger: idlist, qop: qop)
                }
            default:
                break;
            }
        }
        super.init()
    }
    
    public override var type: NodeType {
        return .N_STATEMENT
    }
    
    
    public func calls() -> [String] {
        
        var idNameList: [String] = []
        
        if let op = self.op {
            if op.type == .N_GATEDECL {
                if let goplist = p2 as? NodeGoplist {
                    
                    if let bl = goplist.barrieridlist {
                        for child in bl {
                            if let ids = (child.idlist as? NodeIdList)?.identifiers {
                                for i in ids {
                                    if i.type == .N_CUSTOMUNITARY {
                                        idNameList.append(i.name)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let uops = goplist.uops  {
                        for uop in uops {
                            if uop.type == .N_CUSTOMUNITARY {
                                idNameList.append(uop.name)
                            }
                        }
                    }
                }
            }
        }
        
        return idNameList
    }
    
    public override func qasm() -> String {
 
        guard let op = self.op else {
            assertionFailure("Invalid NodeStatment Operation")
            return ""
        }
        
        switch op.type {
            case .N_DECL:
                return "\(op.qasm())"
            case .N_GATEDECL:
                return "\(op.qasm())"
            case .N_OPAQUE:
                    guard let s2 = p2 else {
                        assertionFailure("Invalid NodeStatment Operation")
                        return ""
                    }

                    guard let s3 = p3 else {
                        assertionFailure("Invalid NodeStatment Operation")
                        return ""
                    }

                    if let s4 = p4 {
                      return "\(op.qasm()) \(s2.qasm()) ( \(s3.qasm()) ) \(s4.qasm()) ;"
                    }
                    return "\(op.qasm()) \(s2.qasm()) \(s3.qasm());"
            case .N_QOP:
                return "\(op.qasm())"
            case .N_IF:
                return "\(op.qasm())"
            case .N_BARRIER:
                guard let s2 = p2 else {
                    assertionFailure("Invalid NodeStatment Operation")
                    return ""
                }
                return "\(op.qasm()) \(s2.qasm());"
            default:
                assertionFailure("Invalid NodeStatment Operation")
                return ""
        }
    }
}
