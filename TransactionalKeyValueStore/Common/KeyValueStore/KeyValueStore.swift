//
//  TransactionalStore.swift
//  TransactionalKeyValueStore
//
//  Created by Alexander on 18.01.23.
//

import Foundation

protocol KeyValueStoreType {
    func set(_ key: String, _ value: String)
    func get(_ key: String) -> String?
    func delete(_ key: String) -> String?
    func count(_ value: String) -> Int
    func beginTransaction()
    func commitTransaction() -> Bool
    func rollbackTransaction() -> Bool
}

final class KeyValueStore: KeyValueStoreType {
    private var store = [String: String]()
    private var stack = [[String: String]]()
    
    func set(_ key: String, _ value: String) {
        store[key] = value
    }
    
    func get(_ key: String) -> String? {
        store[key]
    }
    
    func delete(_ key: String) -> String? {
        store.removeValue(forKey: key)
    }
    
    func count(_ value: String) -> Int {
        store.values.filter { $0 == value }.count
    }
    
    func beginTransaction() {
        stack.append(store)
    }
    
    func commitTransaction() -> Bool {
        stack.popLast() != nil
    }
    
    func rollbackTransaction() -> Bool {
        guard let transaction = stack.popLast() else {
            return false
        }
        store = transaction
        return true
    }
}
