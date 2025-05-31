//
//  AppPrefsViewerScreen.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation
import SwiftUI

/// The main entry view of the application.
/// Provides a three-column split interface to:
/// 1. Select a simulator
/// 2. Choose an installed app within the selected simulator
/// 3. View and edit UserDefaults for that app
struct MainView: View {
    // MARK: - ViewModels

    /// ViewModel for listing available simulators
    @StateObject private var simulatorVM = SimulatorListViewModel()

    /// ViewModel for listing installed applications within a simulator
    @StateObject private var appVM = SimulatorAppListViewModel()

    /// ViewModel for loading and editing UserDefaults of an app
    @StateObject private var userDefaultsVM = UserDefaultsViewModel()

    // MARK: - View Body

    var body: some View {
        NavigationSplitView {
            // Left Column: Simulator selection
            SimulatorListView(viewModel: simulatorVM) { selectedSimulator in
                appVM.loadApps(for: selectedSimulator)
                userDefaultsVM.clear()
            }
        } content: {
            // Middle Column: App selection
            SimulatorAppListView(viewModel: appVM) { selectedApp in
                userDefaultsVM.load(for: selectedApp)
            }
        } detail: {
            // Right Column: UserDefaults editor
            UserDefaultsEditorView(viewModel: userDefaultsVM)
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}
