//
//  NSAttributedString+Style.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol AttributedTextApplicable {
    func makeAttributedText(font: UIFont, color: UIColor, text: String) -> NSAttributedString
    func makeAttributedTitle(font: UIFont, color: UIColor, firstText: String, secondText: String) -> NSAttributedString
}

extension AttributedTextApplicable {
    func makeAttributedText(font: UIFont, color: UIColor, text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [.font : font, .foregroundColor : color])
    }

    func makeAttributedTitle(font: UIFont, color: UIColor, firstText: String, secondText: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: firstText, attributes: [.font : font, .foregroundColor : color])
        attributedTitle.append(NSAttributedString(string: secondText, attributes: [.font : font, .foregroundColor : color]))
        return attributedTitle
    }
}

extension UITextField: AttributedTextApplicable {

}

extension UIButton: AttributedTextApplicable {

}
