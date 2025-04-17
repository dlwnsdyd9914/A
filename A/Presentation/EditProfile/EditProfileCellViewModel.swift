//
//  EditProfileCellViewModel.swift
//  A
//
//

/// 프로필 편집 셀에 대한 뷰모델입니다.
/// 각 셀의 타입(옵션)에 따라 텍스트 필드 또는 텍스트 뷰를 노출하며, 뷰모델과 바인딩합니다.
final class EditProfileCellViewModel {

    // MARK: - Properties

    /// 셀의 타입 (Fullname, Username, Bio 중 하나)
    let option: EditProfileOption

    /// 부모 뷰모델로부터 주입받은 ViewModel (EditProfileViewModel)
    private let viewModel: EditProfileViewModel

    // MARK: - Initializer

    init(option: EditProfileOption, viewModel: EditProfileViewModel) {
        self.option = option
        self.viewModel = viewModel
    }

    // MARK: - Computed Properties

    /// 셀 좌측 타이틀 텍스트
    var titleText: String {
        return option.description
    }

    /// TextField 사용 여부 (Bio일 경우 숨김)
    var shouldHideTextField: Bool {
        return option == .bio
    }

    /// TextView 사용 여부 (Bio일 경우만 노출)
    var shouldHideTextView: Bool {
        return option != .bio
    }

    /// 해당 옵션에 대한 현재 텍스트 값
    var optionValue: String {
        switch option {
        case .fullname:
            return viewModel.currentFullname
        case .username:
            return viewModel.currentUsername
        case .bio:
            return viewModel.currentBio
        }
    }

    // MARK: - Binding

    /// 사용자가 텍스트를 수정할 때 호출되어 내부 상태 업데이트 및 변경 여부 체크
    func bindText(option: EditProfileOption, text: String) {
        switch option {
        case .username:
            viewModel.currentUsername = text
        case .fullname:
            viewModel.currentFullname = text
        case .bio:
            viewModel.currentBio = text
        }

        viewModel.checkForChanges()

        print("✅ [바인딩 확인] \(option) 변경됨 → \(text)")
    }
}
