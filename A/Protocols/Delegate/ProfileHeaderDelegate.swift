//
//  ProfileHeaderDelegate.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func profileHeader(_ header: ProfileHeader, didSelect filter: FilterOption)
}
