//
//  SimulatorAppInfo.swift
//  AppPrefsViewer
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation
import AppKit

/// Represents an installed application inside an iOS simulator.
struct SimulatorAppInfo: Identifiable, Hashable {
    /// Unique identifier used by SwiftUI views.
    let id = UUID()

    /// Bundle identifier of the application.
    let bundleId: String

    /// User-visible application name (from `CFBundleDisplayName` or `CFBundleName`).
    let displayName: String

    /// Path to the app's container directory (e.g., `.../Containers/Data/Application/XYZ...`).
    let appContainerURL: URL

    /// Optional path to the `.app` bundle (from `Containers/Bundle/Application`).
    let appBundleURL: URL?

    /// Attempts to load and return the app icon from the app bundle.
    ///
    /// - Returns: An `NSImage` if a suitable app icon is found, otherwise `nil`.
    func iconImage() -> NSImage? {
        guard let appURL = appBundleURL else { return nil }

        // Check for common icon filenames.
        let contents = (try? FileManager.default.contentsOfDirectory(at: appURL, includingPropertiesForKeys: nil)) ?? []
        let iconNameCandidates = [
            "AppIcon60x60@2x.png", "AppIcon76x76@2x.png",
            "AppIcon60x60@3x.png", "AppIcon40x40@2x.png"
        ]

        for iconName in iconNameCandidates {
            if let iconURL = contents.first(where: { $0.lastPathComponent.contains(iconName) }) {
                return NSImage(contentsOf: iconURL)
            }
        }

        // Fallback: Parse Info.plist to get icon name from CFBundleIconFiles.
        let infoPlistURL = appURL.appendingPathComponent("Info.plist")
        if let data = try? Data(contentsOf: infoPlistURL),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let icons = dict["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let iconName = files.last {
            let pngName = iconName.hasSuffix(".png") ? iconName : iconName + ".png"
            let iconURL = appURL.appendingPathComponent(pngName)
            return NSImage(contentsOf: iconURL)
        }

        return nil
    }
}
