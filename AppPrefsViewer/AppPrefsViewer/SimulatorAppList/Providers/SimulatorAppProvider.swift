//
//  SimulatorAppProvider.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation

import Foundation

/// Provides access to the list of applications installed inside a simulator container.
final class SimulatorAppProvider {

    /// Fetches installed applications for a given simulator.
    ///
    /// - Parameter simulator: The simulator whose apps should be listed.
    /// - Returns: A list of discovered applications with display names and bundle identifiers.
    func fetchInstalledApps(for simulator: Simulator) -> [SimulatorAppInfo] {
        let appDataPath = simulator.dataPath.appendingPathComponent("Containers/Data/Application")

        guard let appContainers = try? FileManager.default.contentsOfDirectory(
            at: appDataPath,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            print("❌ Failed to read simulator application containers at: \(appDataPath.path)")
            return []
        }

        var discoveredApps: [SimulatorAppInfo] = []

        for containerURL in appContainers {
            let preferencesPath = containerURL.appendingPathComponent("Library/Preferences")

            guard let plistFiles = try? FileManager.default.contentsOfDirectory(
                at: preferencesPath,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else {
                continue
            }

            for plistURL in plistFiles where plistURL.pathExtension == "plist" {
                let bundleId = plistURL.deletingPathExtension().lastPathComponent

                // Attempt to resolve app name and bundle path from the bundle container
                if let (displayName, appBundleURL) = findAppDisplayName(
                    in: simulator.dataPath.appendingPathComponent("Containers/Bundle/Application"),
                    matching: bundleId
                ) {
                    let app = SimulatorAppInfo(
                        bundleId: bundleId,
                        displayName: displayName,
                        appContainerURL: containerURL,
                        appBundleURL: appBundleURL
                    )
                    discoveredApps.append(app)
                }
            }
        }

        return discoveredApps
            .unique(by: { $0.bundleId })
            .sorted(by: { $0.displayName.lowercased() < $1.displayName.lowercased() })
    }

    /// Attempts to find an app's display name and bundle path by matching the bundle identifier.
    ///
    /// - Parameters:
    ///   - bundleContainer: The simulator's `Containers/Bundle/Application` path.
    ///   - bundleId: The bundle identifier to match.
    /// - Returns: A tuple containing the display name and path to the `.app` bundle, or `nil` if not found.
    private func findAppDisplayName(in bundleContainer: URL, matching bundleId: String) -> (String, URL)? {
        guard let appBundles = try? FileManager.default.contentsOfDirectory(
            at: bundleContainer,
            includingPropertiesForKeys: nil
        ) else {
            return nil
        }

        for bundleDirectory in appBundles {
            let contents = (try? FileManager.default.contentsOfDirectory(
                at: bundleDirectory,
                includingPropertiesForKeys: nil
            )) ?? []

            for app in contents where app.pathExtension == "app" {
                let infoPlist = app.appendingPathComponent("Info.plist")

                guard let data = try? Data(contentsOf: infoPlist),
                      let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                      let foundBundleId = plist["CFBundleIdentifier"] as? String,
                      foundBundleId == bundleId,
                      let name = plist["CFBundleDisplayName"] as? String ?? plist["CFBundleName"] as? String else {
                    continue
                }

                return (name, app)
            }
        }

        return nil
    }
}

// MARK: - Array Extension

extension Array {
    /// Removes duplicate elements using a key-based comparison.
    ///
    /// - Parameter key: Closure that returns a hashable key for each element.
    /// - Returns: An array containing only unique elements.
    func unique<T: Hashable>(by key: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert(key($0)).inserted }
    }
}
