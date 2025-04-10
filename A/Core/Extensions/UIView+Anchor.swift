//
//  Extension.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, paddingTop: CGFloat, paddingLeading: CGFloat, paddingTrailing: CGFloat, paddingBottom: CGFloat, width: CGFloat, height: CGFloat, centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?) {

        self.translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }

        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
        }

        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }

        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
}


extension UINavigationBar {
    static func setDefaultAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        return appearance
    }
}
