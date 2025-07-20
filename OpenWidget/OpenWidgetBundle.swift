//
//  OpenWidgetBundle.swift
//  OpenWidget
//
//  Created by Lucas on 20.07.25.
//

import WidgetKit
import SwiftUI

@main
struct OpenWidgetBundle: WidgetBundle {
    var body: some Widget {
        OpenWidget()
        OpenWidgetControl()
    }
}
