//
//  TextHighlightStyle.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import UIKit

/// Defines how highlighted text should be styled
enum TextHighlightStyle {
    case bold
    case color(UIColor)
    case boldAndColor(UIColor)
    case underline
    
    /// Applies the highlight style to the given attributes
    func apply(to attributes: inout [NSAttributedString.Key: Any], baseFont: UIFont) {
        switch self {
        case .bold:
            attributes[.font] = UIFont.boldSystemFont(ofSize: UIFont.systemFont(ofSize: 20).pointSize)
        case .color(let color):
            attributes[.font] = UIFont.systemFont(ofSize: UIFont.systemFont(ofSize: 20).pointSize)
            attributes[.foregroundColor] = color
        case .boldAndColor(let color):
            attributes[.font] = UIFont.boldSystemFont(ofSize: UIFont.systemFont(ofSize: 20).pointSize)
            attributes[.foregroundColor] = color
        case .underline:
            attributes[.font] = UIFont.systemFont(ofSize: UIFont.systemFont(ofSize: 20).pointSize)
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
    }
}
