//
//  Update.swift
//  Swift-FFDB
//
//  Created by Fidetro on 2018/5/30.
//  Copyright © 2018年 Fidetro. All rights reserved.
//

import Foundation
public struct Update:STMT {
    let stmt: String
    
    public init(_ table:FFObject.Type) {
        self.init(table.tableName())
    }
    
    public init(_ stmt: String?=nil) {
        if let stmt = stmt {
            self.stmt = "update" +
                        " " +
                        stmt +
                        " "
        }else{
            self.stmt = "update" +
                        " "
        }
    }
    
}

// MARK: - Set
extension Update {
    public func set(_ set:String) -> FFDBSet {
        return FFDBSet(stmt, format: set)
    }
    
    public func set(_ columns:[String]?=nil) -> FFDBSet {
        return FFDBSet.init(stmt, columns: columns)
    }
}
