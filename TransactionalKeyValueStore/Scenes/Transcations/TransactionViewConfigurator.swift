//
//  TransactionViewConfigurator.swift
//  TransactionalKeyValueStore
//
//  Created by Alexander on 18.01.23.
//

import Foundation

struct TransactionViewConfigurator {
    private let store = KeyValueStore()
    
    func configureTransactionView() -> TransactionView {
        let viewModel = TransactionViewModel(store: store)
        let transactionView = TransactionView(viewModel: viewModel)
        return transactionView
    }
}
