//
//  AttributedTextBuilder.swift
//  A
//
//  Created by 이준용 on 4/10/25.
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
