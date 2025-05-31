//
//  Simulator.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation

/// Represents a single iOS simulator device.
struct Simulator: Identifiable, Hashable {
    /// The unique identifier (UDID) of the simulator.
    var id: String

    /// The name of the simulator (e.g., "iPhone 14").
    let name: String

    /// The runtime version of the simulator (e.g., "com.apple.CoreSimulator.SimRuntime.iOS-17-0").
    let runtimeVersion: String

    /// The file system path to the simulator's data directory.
    let dataPath: URL
}
