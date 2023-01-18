//
//  TransactionalKeyValueStoreApp.swift
//  TransactionalKeyValueStore
//
//  Created by Alexander on 18.01.23.
//

import SwiftUI

@main
struct TransactionalKeyValueStoreApp: App {
    var body: some Scene {
        WindowGroup {
            TransactionViewConfigurator().configureTransactionView()
        }
    }
}
