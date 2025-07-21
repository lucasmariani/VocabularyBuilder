//
//  OpenCameraWidgetControl.swift
//  OpenCameraWidget
//
//  Created by Lucas on 20.07.25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct OpenCameraWidgetControl: ControlWidget {
    static let kind: String = "com.rianamiCorp.VocabularyBuilder.OpenCameraWidget"
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenTabIntent()) {
                Label(
                    "Open camera tab",
                    systemImage: "apple.books.pages.fill"
                )
            }
        }
        .displayName("VocabularyBuilder")
        .description("Open VocabularyBuilder to camera tab")
    }
}
