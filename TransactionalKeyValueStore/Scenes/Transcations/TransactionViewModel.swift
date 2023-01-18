//
//  TransactionViewModel.swift
//  TransactionalKeyValueStore
//
//  Created by Alexander on 18.01.23.
//

import Foundation
import Combine

final class TransactionViewModel: ObservableObject {
    
    private var store: KeyValueStoreType
    private var statusSubject = PassthroughSubject<(status: OperationStatus, message: String), Never>()
    private var statusPublisher: AnyPublisher<(status: OperationStatus, message: String), Never> {
        return statusSubject.eraseToAnyPublisher()
    }
    
    @Published private(set) var operationsLog: [String] = []
    @Published var operation = Operation(type: .set, key: "", value: "")
    @Published var isNeedToShowAlert = false

    init(store: KeyValueStoreType) {
        self.store = store
    }
    
    func checkIfAlertNeeded() {
        switch operation.type {
        case .commit, .delete, .rollback:
            isNeedToShowAlert = true
        default:
            processCommand()
        }
    }
    
    func processCommand() {
        switch operation.type {
        case .set:
            guard !operation.key.isEmpty && !operation.value.isEmpty  else {
                statusSubject.send((status: .failure, message: "SET command requires 2 arguments: key and value"))
                return
            }
            store.set(operation.key, operation.value)
            operationsLog.append("\(operation.type.rawValue.uppercased()) \(operation.key) \(operation.value)")
            statusSubject.send((status: .success, "Value \(operation.value) is set for \(operation.key)"))
        case .get:
            guard !operation.key.isEmpty else {
                statusSubject.send((status: .failure, message: "GET command requires a key"))
                return
            }
            if let value = store.get(operation.key) {
                statusSubject.send((status: .success, "Value is \(value)"))
                operationsLog.append("\(operation.type.rawValue.uppercased()) \(operation.key) \(value)")
            } else {
                statusSubject.send((status: .failure, "Key \(operation.key) not found. The provided key does not exist in the store"))
            }
        case .delete:
            guard !operation.key.isEmpty else {
                statusSubject.send((status: .failure, message: "DELETE command requires a key"))
                return
            }
            guard let _ = store.delete(operation.key) else {
                statusSubject.send((status: .failure,"Key \(operation.key) doesn't exist"))
                return
            }
            statusSubject.send((status: .success,"Key \(operation.key) is deleted"))
            operationsLog.append("\(operation.type.rawValue.uppercased()) \(operation.key)")
        case .count:
            guard !operation.value.isEmpty else {
                statusSubject.send((status: .failure, message: "COUNT command requires a value"))
                return
            }
            let count = store.count(operation.value)
            statusSubject.send((status: .success, "Number of keys with the given value: \(count)"))
            operationsLog.append("\(operation.type.rawValue.uppercased()) \(operation.value)")
        case .begin:
            store.beginTransaction()
            statusSubject.send((status: .success, "New transaction started"))
            operationsLog.append("\(operation.type.rawValue.uppercased())")
        case .commit:
            if store.commitTransaction() {
                statusSubject.send((status: .success, "Current transaction committed"))
                operationsLog.append("\(operation.type.rawValue.uppercased())")
            } else {
                statusSubject.send((status: .failure, "No active transaction"))
            }
        case .rollback:
            if store.rollbackTransaction() {
                statusSubject.send((status: .success, "Current transaction rolled back"))
                operationsLog.append("\(operation.type.rawValue.uppercased())")
            } else {
                statusSubject.send((status: .failure, "No active transaction"))
            }
        }
        operation.key = ""
        operation.value = ""
    }
    
    
    func getStatusPublisher() -> AnyPublisher<(status: OperationStatus, message: String), Never> {
        return statusPublisher
    }
}

