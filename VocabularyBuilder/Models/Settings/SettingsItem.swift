//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import Foundation

/// Generic protocol for settings items that can be displayed in the settings UI
@MainActor
protocol SettingsItem {
    var displayName: String { get }
    var description: String { get }
    var isSelected: Bool { get }
}

/// Represents a settings row with selection capability
struct SettingsRow<T: SettingsItem> {
    let item: T
    let onSelect: (T) -> Void

    init(item: T, onSelect: @escaping (T) -> Void) {
        self.item = item
        self.onSelect = onSelect
    }
}

/// Represents a section in the settings UI
struct SettingsSection {
    let title: String
    let footerText: String?
    let rows: [Any] // Will contain SettingsRow<T> instances

    init(title: String, footerText: String? = nil, rows: [Any]) {
        self.title = title
        self.footerText = footerText
        self.rows = rows
    }
}
