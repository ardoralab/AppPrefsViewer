//
//  SimulatorListViewModel.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation

/// View model responsible for managing the list of available iOS simulators.
final class SimulatorListViewModel: ObservableObject {
    /// List of detected simulators.
    @Published var simulators: [Simulator] = []

    /// Currently selected simulator.
    @Published var selected: Simulator?

    private let provider = SimulatorProvider()

    /// Loads the available simulators using `SimulatorProvider`.
    func fetchSimulators() {
        simulators = provider.fetchSimulators()
    }
}
