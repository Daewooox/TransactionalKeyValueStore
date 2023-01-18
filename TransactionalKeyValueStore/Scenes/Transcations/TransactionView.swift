//
//  ContentView.swift
//  TransactionalKeyValueStore
//
//  Created by Alexander on 18.01.23.
//

import SwiftUI

struct TransactionView: View {
    
    private struct Constants {
        static let formHeight = 150.0
    }
    
    @ObservedObject var viewModel: TransactionViewModel
    @State private var result: (status: OperationStatus, message: String) = (status: .success, message: "")
    @FocusState private var focusField: Bool
    
    var body: some View {
        VStack {
            Form {
                Picker("Choise command", selection: $viewModel.operation.type) {
                    ForEach(CommandType.allCases, id: \.self) { command in
                        Text(command.rawValue.capitalized)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.operation.type) { _ in
                    viewModel.operation.key = ""
                    viewModel.operation.value = ""
                }
                
                HStack {
                    if viewModel.operation.type == .set || viewModel.operation.type == .get || viewModel.operation.type == .delete {
                        TextField("Enter Key", text: $viewModel.operation.key)
                    }
                    if viewModel.operation.type == .set || viewModel.operation.type == .count  {
                        TextField("Enter Value", text: $viewModel.operation.value)
                    }
                }
                .focused($focusField)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            }.frame(height: Constants.formHeight)
            Button("Execute") {
                viewModel.isNeedToShowAlert = false
                viewModel.checkIfAlertNeeded()
                focusField = false
            }
            .padding(.vertical, 20)
            .buttonStyle(.bordered)
            
            Text(result.message.isEmpty ? "" : "Result: " + result.message)
                .foregroundColor(result.status == .success ? .green : .red)
            Text("Operations Log:")
                .font(.headline)
                .padding(.vertical, 20)
            ScrollView {
                ForEach(viewModel.operationsLog, id: \.self) { transaction in
                    Text(transaction)
                }
            }
            
        }
        .alert(isPresented: $viewModel.isNeedToShowAlert) {
            Alert(title: Text("Confirmation"), message: Text("Execute an irreversible command \(viewModel.operation.type.rawValue.uppercased())?"),
                  primaryButton: .cancel( Text("Cancel")),
                  secondaryButton: .default(Text("Execute"), action: {
                viewModel.processCommand()
            })
            )
        }
        .onReceive(viewModel.getStatusPublisher()) { value in
            result = value
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionViewConfigurator().configureTransactionView()
    }
}
