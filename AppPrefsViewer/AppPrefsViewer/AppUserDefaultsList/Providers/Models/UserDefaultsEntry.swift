//
//  UserDefaultsEntry.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation

/// Represents a single key-value entry from UserDefaults.
///
/// This struct is used to display and manipulate UserDefaults data
/// extracted from a simulator app's preferences plist.
struct UserDefaultsEntry: Identifiable, Hashable, Equatable {
    /// Unique identifier for SwiftUI views
    let id = UUID()

    /// The key name in UserDefaults
    let key: String

    /// The raw value associated with the key
    var value: Any

    /// A human-readable string representation of the value.
    /// Handles common UserDefaults types: String, NSNumber, Date, Data, Array, Dictionary.
    var displayValue: String {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            return number.stringValue
        case let date as Date:
            return DateFormatter.userDefaults.string(from: date)
        case let data as Data:
            return "<\(data.count) bytes>"
        case let array as [Any]:
            return "[\(array.count) items]"
        case let dict as [String: Any]:
            return "{\(dict.count) keys}"
        default:
            return String(describing: value)
        }
    }

    // MARK: - Equatable

    /// Compares entries by their key and stringified value.
    static func == (lhs: UserDefaultsEntry, rhs: UserDefaultsEntry) -> Bool {
        lhs.key == rhs.key && String(describing: lhs.value) == String(describing: rhs.value)
    }

    // MARK: - Hashable

    /// Hashes the key and stringified value.
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(String(describing: value))
    }
}
