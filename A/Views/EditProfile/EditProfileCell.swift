//
//  EditProfileCell.swift
//  A
//
//

import UIKit
import SnapKit
import Then
import Kingfisher

/// 프로필 수정 화면에서 사용되는 셀입니다.
/// - 구성: 타이틀 라벨 + 입력 필드 또는 바이오 입력 뷰
/// - 기능: 입력값이 변경되면 뷰모델로 전달하는 바인딩 처리 포함
final class EditProfileCell: UITableViewCell {

    // MARK: - Properties

    /// 해당 셀에 바인딩되는 뷰모델
    var viewModel: EditProfileCellViewModel? {
        didSet {
            guard let viewModel else { return }
            bindViewModel(viewModel: viewModel)
        }
    }

    // MARK: - View Models

    // 현재 뷰모델에서 텍스트 바인딩을 수행

    // MARK: - UI Components

    /// 수정 항목 제목 라벨 (예: 이름, 아이디, 바이오 등)
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "TestTitle"
    }

    /// 일반 텍스트 필드 (이름/아이디 수정 시 사용)
    lazy var infoTextField = UITextField().then {
        $0.borderStyle = .none
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .left
        $0.textColor = .backGround
        $0.text = "Test User"
        $0.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
    }

    /// 바이오 입력용 텍스트 뷰 (TextField 대체)
    lazy var bioTextView = InputTextView().then {
        $0.delegate = self
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .backGround
        $0.placeholderLabel.text = "Bio"
    }

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configureUI()
        addSubViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles

    // UITableViewCell은 별도 생명 주기 메서드 사용 없음

    // MARK: - Selectors

    /// 텍스트 필드 변경 시 뷰모델로 값 전달
    @objc private func handleTextFieldChange(textField: UITextField) {
        guard let viewModel = viewModel,
              let text = textField.text else { return }
        viewModel.bindText(option: viewModel.option, text: text)
    }

    // MARK: - UI Configurations

    /// 기본 셀 배경 설정
    private func configureUI() {
        backgroundColor = .white
    }

    /// 컴포넌트 계층 추가
    private func addSubViews() {
        [titleLabel, infoTextField, bioTextView].forEach({ contentView.addSubview($0) })
    }

    /// 전체 제약 조건 설정
    private func configureConstraints() {
        setTitleLabelConstraints()
        infoTextFieldConstraints()
        setBioTextViewConstraints()
    }

    /// 타이틀 라벨 위치 설정
    private func setTitleLabelConstraints() {
        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().inset(16)
            $0.width.equalTo(100)
        })
    }

    /// 일반 텍스트 필드 위치 설정
    private func infoTextFieldConstraints() {
        infoTextField.snp.makeConstraints({
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(titleLabel.snp.trailing).inset(16)
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview()
        })
    }

    /// 바이오 텍스트 뷰 위치 설정
    private func setBioTextViewConstraints() {
        bioTextView.snp.makeConstraints({
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(titleLabel.snp.trailing).inset(16)
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview()
        })
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    /// 뷰모델 값에 따라 UI 업데이트 및 텍스트 설정
    private func bindViewModel(viewModel: EditProfileCellViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.infoTextField.isHidden = viewModel.shouldHideTextField
            self.bioTextView.isHidden = viewModel.shouldHideTextView

            self.titleLabel.text = viewModel.titleText

            self.infoTextField.text = viewModel.optionValue
            self.bioTextView.text = viewModel.optionValue
            self.bioTextView.placeholderLabel.isHidden = !viewModel.optionValue.isEmpty
        }
    }
}

// MARK: - UITextViewDelegate

extension EditProfileCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let viewModel else { return }
        viewModel.bindText(option: .bio, text: textView.text)
    }
}
