//
//  CommandType.swift
//  TransactionalKeyValueStore
//
//  Created by Alexander on 18.01.23.
//

import Foundation

struct Operation {
    var type: CommandType
    var key: String
    var value: String
}

enum CommandType: String, CaseIterable {
    case set, get, delete, count, begin, commit, rollback
}

enum OperationStatus {
    case success, failure
}
