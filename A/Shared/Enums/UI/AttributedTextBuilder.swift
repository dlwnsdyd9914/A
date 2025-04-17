//
//  AttributedTextBuilder.swift
//  A
//
//

import UIKit

enum AttributedTextBuilder {
    static func build(text: String, font: UIFont, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: color
        ])
    }
}
