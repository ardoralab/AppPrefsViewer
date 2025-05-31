//
//  SimulatorAppListViewModel.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation
import Combine

/// ViewModel responsible for loading and managing the list of applications installed in a selected simulator.
final class SimulatorAppListViewModel: ObservableObject {
    /// The list of applications installed in the selected simulator.
    @Published var apps: [SimulatorAppInfo] = []

    /// The currently selected application.
    @Published var selected: SimulatorAppInfo?

    private let provider = SimulatorAppProvider()

    /// Loads installed applications for the given simulator.
    /// - Parameter simulator: The simulator for which to fetch installed apps.
    func loadApps(for simulator: Simulator) {
        apps = provider.fetchInstalledApps(for: simulator)
    }
}
