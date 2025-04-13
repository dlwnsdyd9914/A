//
//  ProfileFilterViewModel.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import Foundation

final class ProfileFilterViewModel {

    var selectedIndex: Int = 0

    let filterOptions: [FilterOption]

    init(filterOptions: [FilterOption] = FilterOption.allCases, selectedIndex: Int = 0) {
        self.filterOptions = filterOptions
        self.selectedIndex = selectedIndex
    }
}

