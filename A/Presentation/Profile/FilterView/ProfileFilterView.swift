//
//  ProfileFilterView.swift
//
//
//

import UIKit

/// 프로필 화면 상단에서 트윗, 리플, 좋아요 등의 필터를 선택하는 탭 뷰입니다.
/// 하단에 움직이는 언더라인과 함께 UICollectionView를 이용해 구현하였습니다.
final class ProfileFilterView: UIView {

    // MARK: - Properties

    /// 필터 항목 선택 시 외부로 전달하기 위한 델리게이트
    weak var delegate: ProfileFilterViewDelegate?

    // MARK: - View Models

    /// 현재 필터 상태 및 옵션 리스트를 관리하는 뷰모델
    private let viewModel = ProfileFilterViewModel()

    // MARK: - UI Components

    /// 필터 옵션 목록을 표시할 컬렉션 뷰
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    /// 선택된 항목 아래에 위치할 밑줄 뷰
    private let underLineView = UIView().then {
        $0.backgroundColor = .backGround
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Life Cycles

    /// 언더라인 뷰 위치 조정을 위해 레이아웃 계산 후 호출
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(underLineView)
        underLineView.anchor(top: nil, leading: leadingAnchor, trailing: nil, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: frame.width / 3, height: 2, centerX: nil, centerY: nil)
    }

    // MARK: - UI Configurations

    /// 기본 UI 설정
    private func configureUI() {
        backgroundColor = .red // 테스트용 배경색
    }

    /// 컬렉션 뷰 구성 및 제약 설정
    private func configureCollectionView() {
        self.addSubview(collectionView)

        collectionView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
        collectionView.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: CellIdentifier.profileFilterCell)
    }

}

// MARK: - UICollectionViewDataSource
extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filterOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.profileFilterCell, for: indexPath) as? ProfileFilterCell else {
            return UICollectionViewCell()
        }

        let filterOption = viewModel.filterOptions[indexPath.item]
        let isSelected = (indexPath.item == viewModel.selectedIndex)
        cell.viewModel = ProfileFilterItemViewModel(filterOption: filterOption, isSelected: isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 선택된 인덱스 업데이트 및 델리게이트 호출
        viewModel.selectedIndex = indexPath.item
        delegate?.filterView(view: self, didSelect: viewModel.filterOptions[indexPath.item])

        // 언더라인 애니메이션
        UIView.animate(withDuration: 0.3) {
            self.underLineView.frame.origin.x = collectionView.cellForItem(at: indexPath)?.frame.origin.x ?? 0
        }

        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileFilterView: UICollectionViewDelegateFlowLayout {
    /// 각 필터 셀의 크기를 동등하게 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height)
    }
}
