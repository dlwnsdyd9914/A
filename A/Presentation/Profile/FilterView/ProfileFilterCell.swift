//
//  ProfileFilterCell.swift
//  A
//
//

import UIKit
import Then
import SnapKit

/// 프로필 화면의 필터 탭 셀입니다.
/// - 기능: 현재 선택된 필터에 따라 label 스타일 변경
/// - 구조: 뷰모델로부터 필터 옵션을 받아와 셀 UI를 갱신
final class ProfileFilterCell: UICollectionViewCell {

    // MARK: - View Models

    /// 현재 셀에 바인딩된 필터 뷰모델
    var viewModel: ProfileFilterItemViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - UI Components

    /// 필터 타이틀 레이블
    private let titleLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.text = "Test" // 기본 테스트 텍스트
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard 사용 안함")
    }

    // MARK: - UI Configurations

    /// 셀에 서브뷰 추가
    private func addSubViews() {
        contentView.addSubview(titleLabel)
        setTitleLabelConstraints()
    }

    /// 타이틀 라벨의 제약 조건 설정
    private func setTitleLabelConstraints() {
        titleLabel.snp.makeConstraints({
            $0.centerX.centerY.equalToSuperview()
        })
    }

    // MARK: - Bind ViewModels

    /// 셀 뷰모델을 이용해 텍스트 및 UI 업데이트 바인딩
    private func configureCell() {
        guard let viewModel else { return }

        // 필터 라벨 텍스트 지정
        titleLabel.text = viewModel.selectedFilterOption.description

        // 최초 UI 스타일 설정
        updateUI()

        // 뷰모델의 필터 선택 상태 변경에 따른 UI 반영
        viewModel.onFilterStatus = { [weak self] isSelected in
            self?.updateUI()
        }
    }

    // MARK: - Functions

    /// 선택 여부에 따라 UI 스타일 업데이트
    private func updateUI() {
        guard let viewModel else { return }
        titleLabel.font = viewModel.isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = viewModel.isSelected ? UIColor.backGround : .lightGray
    }
}
