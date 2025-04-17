//
//  ProfileController.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit
import Then
import SwiftUI

/// 프로필 화면 컨트롤러
/// - 유저 트윗, 좋아요, 리플 목록을 필터로 구분해 보여주는 화면
/// - MVVM 아키텍처 기반: UserViewModel + ProfileViewModel + ProfileHeaderViewModel 사용
/// - 동적 셀 높이 계산, 사용자 프로필 수정/탭 전환 기능 포함
final class ProfileController: UIViewController {

    // MARK: - Dependencies

    /// 라우터 (탭 이동 및 뒤로가기)
    private let router: MainTabBarRouterProtocol
    private let feedRouter: FeedRouterProtocol

    /// 도메인 레벨 유즈케이스 및 리포지토리
    private let useCase: ProfileUseCaseProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let tweetRepository: TweetRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let editUseCase: EditUseCaseProtocol

    // MARK: - ViewModels

    /// 현재 유저 정보 상태 관리
    private let userViewModel: UserViewModel

    /// 트윗 필터링 및 데이터소스 관리
    private let viewModel: ProfileViewModel

    /// 헤더 뷰 관련 상태 및 바인딩 관리
    private let profileHeaderViewModel: ProfileHeaderViewModel

    // MARK: - UI Components

    /// 트윗 목록을 보여주는 컬렉션 뷰 (동적 높이 셀 포함)
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // MARK: - Initializer

    /// DI 기반 생성자
    init(
        router: MainTabBarRouterProtocol,
        userViewModel: UserViewModel,
        useCase: ProfileUseCaseProtocol,
        followUseCase: FollowUseCaseProtocol,
        feedRouter: FeedRouterProtocol,
        tweetLikeUseCase: TweetLikeUseCaseProtocol,
        tweetRepository: TweetRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        editUseCase: EditUseCaseProtocol
    ) {
        self.router = router
        self.userViewModel = userViewModel
        self.useCase = useCase
        self.followUseCase = followUseCase
        self.viewModel = ProfileViewModel(useCase: useCase)
        self.profileHeaderViewModel = ProfileHeaderViewModel(user: userViewModel.getUser(), repository: userRepository, useCase: followUseCase)
        self.feedRouter = feedRouter
        self.tweetLikeUseCase = tweetLikeUseCase
        self.tweetRepository = tweetRepository
        self.userRepository = userRepository
        self.editUseCase = editUseCase
        super.init(nibName: nil, bundle: nil)
    }
    

    required init?(coder: NSCoder) {
        fatalError("Storyboard 미사용")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Selectors

    /// NotificationCenter를 통한 유저 업데이트 반영
    @objc private func handleProfileUpdated(_ notification: Foundation.Notification) {
        guard let updateUser = notification.object as? UserModelProtocol else { return }
        self.userViewModel.updateUserViewModel(user: updateUser)
        self.collectionView.reloadData()
    }


    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        bindViewModel()
        registerNotificationObservers()
    }

    // MARK: - UI Configurations

    private func configureUI() {
        view.backgroundColor = .white
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: CellIdentifier.tweetCell)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.profileHeader)
    }

    // MARK: - ViewModel Bindings

    private func bindViewModel() {
        // 트윗 필터 적용 시 데이터소스 업데이트
        viewModel.onFetchFilterSuccess = { [weak self] in
            self?.collectionView.reloadData()
        }

        // 팔로우 상태 변경 시 헤더 갱신
        profileHeaderViewModel.onFollowToggled = { [weak self] in
            self?.collectionView.reloadData()
        }

        // 초기 유저 트윗 가져오기
        viewModel.selectedFetchTweet(uid: userViewModel.uid)
    }

    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileUpdated),
            name: .didUpdateProfile,
            object: nil
        )
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.tweetCell, for: indexPath) as? TweetCell else {
            return UICollectionViewCell()
        }

        let tweet = viewModel.currentDataSource[indexPath.row]
        let tweetVM = TweetViewModel(tweet: tweet, repository: tweetRepository, useCase: tweetLikeUseCase, userViewModel: userViewModel, userRepository: userRepository)
        let userVM = UserViewModel(user: tweet.user, followUseCase: followUseCase)

        cell.viewModel = tweetVM

        // 좋아요 탭일 때만 유저 프로필로 이동 가능
        if viewModel.selectedFilter == .likes {
            cell.onProfileImageViewTapped = { [weak self] in
                self?.feedRouter.navigateToUserProfile(userViewModel: userVM, from: self!)
            }
        } else {
            cell.onProfileImageViewTapped = nil
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.profileHeader, for: indexPath) as? ProfileHeader else {
            return UICollectionReusableView()
        }

        header.viewModel = profileHeaderViewModel
        header.delegate = self

        header.onBackButtonTap = { [weak self] in
            self?.router.popNav(from: self!)
        }

        header.viewModel?.onEditProfileTapped = { [weak self] in
            guard let self else { return }
            let editVM = EditProfileViewModel(repository: userRepository, user: self.userViewModel.getUser(), useCase: editUseCase)
            let headerVM = EditProfileHeaderViewModel()

            self.feedRouter.naivgateToEditProfile(
                userViewModel: self.userViewModel,
                editProfileHeaderViewModel: headerVM,
                editProfileViewModel: editVM,
                from: self
            ) { user in
                self.collectionView.reloadData()
                self.viewModel.selectedFetchTweet(uid: user.uid)
            }
        }

        return header
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: estimatedHeight(isHeader: true))
    }



    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width
        let tweet = viewModel.currentDataSource[indexPath.row]

        print(estimatedHeight(tweet: tweet, isHeader: false))

        return CGSize(width: width, height: estimatedHeight(tweet: tweet, isHeader: false))
    }

    private func estimatedHeight(tweet: Tweet? = nil, isHeader: Bool) -> CGFloat {
        let dummy: UIView

        // collectionView width가 아직 0인 경우 대비
        let safeWidth = collectionView.frame.width > 0 ? collectionView.frame.width : UIScreen.main.bounds.width

        if isHeader {
            let dummyHeader = ProfileHeader()

            dummyHeader.viewModel = profileHeaderViewModel

            dummyHeader.frame = CGRect(x: 0, y: 0, width: safeWidth, height: 1000)
            dummyHeader.setNeedsLayout()
            dummyHeader.layoutIfNeeded()
            dummy = dummyHeader
        } else {
            let dummyCell = TweetCell()


            dummyCell.frame = CGRect(x: 0, y: 0, width: safeWidth, height: 1000)


            if let tweet = tweet {
                dummyCell.viewModel = TweetViewModel(tweet: tweet, repository: tweetRepository, useCase: tweetLikeUseCase, userViewModel: userViewModel, userRepository: userRepository)
            }

            dummyCell.setNeedsLayout()
            dummyCell.layoutIfNeeded()
            dummy = dummyCell.contentView
        }

        let targetSize = CGSize(width: safeWidth, height: UIView.layoutFittingCompressedSize.height)

        var estimatedSize = dummy.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        // 최소 높이 설정 (예: 프로필 헤더는 기본적으로 일정 높이 이상 유지)
        if isHeader {
            estimatedSize.height = max(estimatedSize.height, 200)
        }

        return estimatedSize.height
    }


}

// MARK: - 헤더 필터 탭 처리

extension ProfileController: ProfileHeaderDelegate {
    func profileHeader(_ header: ProfileHeader, didSelect filter: FilterOption) {
        viewModel.selectedFilter = filter
        viewModel.selectedFetchTweet(uid: userViewModel.uid)
    }
}
