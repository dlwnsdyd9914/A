//
//  ProfileFilterViewDelegate.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol ProfileFilterViewDelegate: AnyObject {
    func filterView(view: ProfileFilterView, didSelect filter: FilterOption)
}

