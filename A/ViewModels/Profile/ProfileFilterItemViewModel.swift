//
//  ProfileFilterItemViewModel.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import Foundation

final class ProfileFilterItemViewModel {
    var isSelected: Bool {
        didSet {
            onFilterStatus?(isSelected)
        }
    }

    let selectedFilterOption: FilterOption
    var onFilterStatus: ((Bool) -> Void)?

    init(filterOption: FilterOption, isSelected: Bool) {
        self.selectedFilterOption = filterOption
        self.isSelected = isSelected
    }

    func updateSelectionStatus(isSelected: Bool) {
        self.isSelected = isSelected
    }
}
