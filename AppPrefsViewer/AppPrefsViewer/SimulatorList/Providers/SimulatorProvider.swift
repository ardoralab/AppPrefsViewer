//
//  SimulatorProvider.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation

/// Provides a list of available iOS simulators using `xcrun simctl`.
final class SimulatorProvider {

    /// Fetches all available simulators by invoking `xcrun simctl list -j devices`.
    /// - Returns: An array of `Simulator` objects, sorted alphabetically by name.
    func fetchSimulators() -> [Simulator] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "list", "-j", "devices"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
        } catch {
            print("❌ Failed to run simctl: \(error)")
            return []
        }

        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let devices = json["devices"] as? [String: Any] else {
            print("❌ Failed to parse simctl JSON output")
            return []
        }

        var simulators: [Simulator] = []

        for (runtimeVersion, deviceList) in devices {
            guard let deviceArray = deviceList as? [[String: Any]] else { continue }

            for device in deviceArray {
                guard
                    let name = device["name"] as? String,
                    let udid = device["udid"] as? String,
                    let isAvailable = device["isAvailable"] as? Bool,
                    let dataPathString = device["dataPath"] as? String,
                    isAvailable
                else {
                    continue
                }

                let dataPath = URL(fileURLWithPath: dataPathString)

                simulators.append(Simulator(
                    id: udid,
                    name: name,
                    runtimeVersion: runtimeVersion,
                    dataPath: dataPath
                ))
            }
        }

        return simulators.sorted { $0.name < $1.name }
    }
}
