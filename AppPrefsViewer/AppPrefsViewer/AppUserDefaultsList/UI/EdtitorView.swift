//
//  EdtitorView.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation
import SwiftUI

/// A SwiftUI view that displays and edits UserDefaults entries
/// for a selected simulator application.
struct UserDefaultsEditorView: View {
    @ObservedObject var viewModel: UserDefaultsViewModel

    @State private var newKey: String = ""
    @State private var newValue: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            if let app = viewModel.currentApp {
                // Header
                HStack {
                    Text("Editing preferences for: \(app.displayName)")
                        .font(.headline)
                    Spacer()
                    Button("Add Key") {
                        viewModel.presentAddSheet = true
                    }
                    Button("Clear All") {
                        viewModel.clearAll()
                    }
                }
                .padding([.horizontal, .top])

                // Search Field
                TextField("Search...", text: $viewModel.query)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // Table of keys
                Table(viewModel.filteredEntries) {
                    TableColumn("Key") { entry in
                        Text(entry.key)
                    }
                    TableColumn("Value") { entry in
                        TextField("", text: Binding(
                            get: { entry.displayValue },
                            set: { new in viewModel.update(entry: entry, with: new) }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                    TableColumn("Actions") { entry in
                        Button("🗑") {
                            viewModel.delete(entry: entry)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Please select an app to inspect its UserDefaults.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        // Sheet for adding new key-value pair
        .sheet(isPresented: $viewModel.presentAddSheet) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Add New Entry")
                    .font(.headline)
                TextField("Key", text: $newKey)
                TextField("Value", text: $newValue)
                HStack {
                    Spacer()
                    Button("Save") {
                        viewModel.add(key: newKey, value: newValue)
                        newKey = ""
                        newValue = ""
                        viewModel.presentAddSheet = false
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
            .frame(width: 400)
        }
        .navigationTitle("UserDefaults")
    }
}
