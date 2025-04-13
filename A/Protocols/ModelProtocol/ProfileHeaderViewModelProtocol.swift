//
//  ProfileHeaderViewModelProtocol.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

protocol ProfileHeaderViewModelProtocol {
    var followerString: NSAttributedString { get }
    var followingString: NSAttributedString { get }
    var profileImageUrl: URL? { get }
    var infoText: NSAttributedString { get }
    var actionButtonTitle: String { get }
    var fullname: String { get }
    var username: String { get }
    var uid: String { get }
    var didFollow: Bool { get  }
}
