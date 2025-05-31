//
//  UserDefaultsViewModel.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation

/// ViewModel responsible for managing UserDefaults entries
/// for a selected simulator application. Provides reactive updates
/// for UI and handles live file observation via FileWatcher.
final class UserDefaultsViewModel: ObservableObject {
    // MARK: - Published Properties

    /// All loaded UserDefaults entries.
    @Published var entries: [UserDefaultsEntry] = []

    /// The currently selected simulator app.
    @Published var currentApp: SimulatorAppInfo?

    /// Controls the visibility of the 'Add Key' modal sheet.
    @Published var presentAddSheet: Bool = false

    /// User-entered search query used for filtering keys.
    @Published var query: String = ""

    // MARK: - Dependencies

    private let provider = UserDefaultsProvider()
    private let fileWatcher = FileWatcher()

    // MARK: - Computed Properties

    /// Entries filtered by the current search query.
    var filteredEntries: [UserDefaultsEntry] {
        guard !query.isEmpty else { return entries }
        return entries.filter { $0.key.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Public Methods

    /// Loads the UserDefaults entries for the given app and starts live file watching.
    /// - Parameter app: The simulator app whose preferences should be loaded.
    func load(for app: SimulatorAppInfo) {
        currentApp = app
        entries = provider.loadPreferences(for: app)

        let plistURL = app.appContainerURL
            .appendingPathComponent("Library/Preferences")
            .appendingPathComponent("\(app.bundleId).plist")

        fileWatcher.watch(url: plistURL) { [weak self] in
            guard let self, let app = self.currentApp else { return }
            DispatchQueue.main.async {
                self.entries = self.provider.loadPreferences(for: app)
            }
        }
    }

    /// Updates the value for a specific key in UserDefaults.
    /// - Parameters:
    ///   - entry: The entry to update.
    ///   - string: The new value as a string.
    func update(entry: UserDefaultsEntry, with string: String) {
        guard let app = currentApp else { return }
        var updatedEntry = entry
        updatedEntry.value = string

        do {
            try provider.setValue(string, for: entry.key, in: app)
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index] = updatedEntry
            }
        } catch {
            print("❌ Failed to update value: \(error)")
        }
    }

    /// Deletes the given entry from UserDefaults.
    /// - Parameter entry: The entry to delete.
    func delete(entry: UserDefaultsEntry) {
        guard let app = currentApp else { return }

        do {
            try provider.deleteKey(entry.key, from: app)
            entries.removeAll { $0.id == entry.id }
        } catch {
            print("❌ Failed to delete entry: \(error)")
        }
    }

    /// Adds a new key-value pair to the UserDefaults.
    /// - Parameters:
    ///   - key: The key to insert.
    ///   - value: The string value to insert.
    func add(key: String, value: String) {
        guard let app = currentApp else { return }

        do {
            try provider.setValue(value, for: key, in: app)
            entries.append(UserDefaultsEntry(key: key, value: value))
        } catch {
            print("❌ Failed to add entry: \(error)")
        }
    }

    /// Clears all UserDefaults entries for the current app.
    func clearAll() {
        guard let app = currentApp else { return }
        try? provider.clearAll(for: app)
        entries = []
    }

    /// Resets all state and stops watching the file.
    func clear() {
        fileWatcher.stop()
        currentApp = nil
        entries = []
    }
}
