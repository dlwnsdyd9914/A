//
//  TweetHeaderViewModelProtocol.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import Foundation
import UIKit

protocol TweetHeaderViewModelProtocol {
    var caption: String { get }
    var fullname: String { get }
    var username: String { get }
    var profileImageUrl: URL? { get }
    var retweetAttributedString: NSAttributedString { get }
    var likesAttributedString: NSAttributedString { get }
    var headerTimestamp: String { get }
    var infoLabel: NSAttributedString { get }
    func showActionSheet()
    var handleShowActionSheet: (() -> Void)? { get set }
    
}

