//
//  SimulatorAppListView.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation
import SwiftUI

import SwiftUI

/// Displays a list of applications installed in the selected simulator.
struct SimulatorAppListView: View {
    @ObservedObject var viewModel: SimulatorAppListViewModel
    var onSelect: (SimulatorAppInfo) -> Void

    var body: some View {
        List(selection: $viewModel.selected) {
            ForEach(viewModel.apps) { app in
                HStack {
                    if let icon = app.iconImage() {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                    }
                    Text(app.displayName)
                }
                .tag(app)
            }
        }
        .onChange(of: viewModel.selected) { newValue in
            if let app = newValue {
                onSelect(app)
            }
        }
        .navigationTitle("Applications")
    }
}
