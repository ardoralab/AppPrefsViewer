//
//  SimulatorListView.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import SwiftUI

/// Displays a list of available simulators for selection.
struct SimulatorListView: View {
    @ObservedObject var viewModel: SimulatorListViewModel
    var onSelect: (Simulator) -> Void

    var body: some View {
        List(selection: $viewModel.selected) {
            ForEach(viewModel.simulators) { simulator in
                Text("\(simulator.name) (\(simulator.runtimeVersion))")
                    .tag(simulator)
            }
        }
        .onChange(of: viewModel.selected) { newValue in
            if let selectedSimulator = newValue {
                onSelect(selectedSimulator)
            }
        }
        .onAppear(perform: viewModel.fetchSimulators)
        .navigationTitle("Simulators")
    }
}
