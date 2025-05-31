//
//  UserDefaultsProvider.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation

/// A service that loads, modifies, and saves `UserDefaults` data for a given simulator app.
/// This provider directly reads and writes `.plist` files inside the app container.
final class UserDefaultsProvider {

    /// Loads and parses the UserDefaults (`.plist`) for a given app.
    /// - Parameter app: The simulator app info.
    /// - Returns: An array of key-value entries found in the plist.
    func loadPreferences(for app: SimulatorAppInfo) -> [UserDefaultsEntry] {
        let plistURL = preferencesURL(for: app)

        guard FileManager.default.fileExists(atPath: plistURL.path) else {
            print("❌ Plist not found at: \(plistURL.path)")
            return []
        }

        guard let data = try? Data(contentsOf: plistURL),
              let rawDict = try? PropertyListSerialization.propertyList(
                from: data, format: nil
              ) as? [String: Any] else {
            print("❌ Failed to read or parse plist at: \(plistURL.path)")
            return []
        }

        return rawDict.map { key, value in
            UserDefaultsEntry(key: key, value: value)
        }.sorted(by: { $0.key < $1.key })
    }

    /// Saves the given list of entries back to the app's plist.
    /// - Parameters:
    ///   - entries: The entries to save.
    ///   - app: The simulator app to target.
    func savePreferences(_ entries: [UserDefaultsEntry], for app: SimulatorAppInfo) throws {
        let dict = Dictionary(uniqueKeysWithValues: entries.map { ($0.key, $0.value) })
        let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        try data.write(to: preferencesURL(for: app))
    }

    /// Deletes a specific key from the plist.
    /// - Parameters:
    ///   - key: The key to remove.
    ///   - app: The app to update.
    func deleteKey(_ key: String, from app: SimulatorAppInfo) throws {
        var entries = loadPreferences(for: app)
        entries.removeAll { $0.key == key }
        try savePreferences(entries, for: app)
    }

    /// Updates or adds a key-value pair in the plist.
    /// - Parameters:
    ///   - newValue: The new value to set.
    ///   - key: The key to update or insert.
    ///   - app: The app to modify.
    func setValue(_ newValue: Any, for key: String, in app: SimulatorAppInfo) throws {
        var entries = loadPreferences(for: app)

        if let index = entries.firstIndex(where: { $0.key == key }) {
            entries[index] = UserDefaultsEntry(key: key, value: newValue)
        } else {
            entries.append(UserDefaultsEntry(key: key, value: newValue))
        }

        try savePreferences(entries, for: app)
    }

    /// Clears all keys from the plist for the specified app.
    /// - Parameter app: The app to clear.
    func clearAll(for app: SimulatorAppInfo) throws {
        try savePreferences([], for: app)
    }

    // MARK: - Private Helpers

    /// Computes the full URL to the plist file for the given app.
    private func preferencesURL(for app: SimulatorAppInfo) -> URL {
        app.appContainerURL
            .appendingPathComponent("Library/Preferences")
            .appendingPathComponent("\(app.bundleId).plist")
    }
}
