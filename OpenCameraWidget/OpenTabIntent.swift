//
//  OpenTabIntent.swift
//  VocabularyBuilder
//
//  Created by Lucas on 21.07.25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct OpenTabIntent: AppIntent, @unchecked Sendable {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Open Tab"
    nonisolated(unsafe) static var description = IntentDescription("Opens the selected tab in VocabularyBuilder")
    
    nonisolated(unsafe) static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Store the selected tab in shared UserDefaults
        if let sharedDefaults = UserDefaults(suiteName: "group.com.rianamiCorp.VocabularyBuilder") {
            sharedDefaults.set(true, forKey: "launchedFromControl")
            sharedDefaults.synchronize()
        }
        
        return .result()
    }
}
