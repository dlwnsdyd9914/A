//
//  FeedController.swift
//  A
//
//

import UIKit
import Kingfisher
import SnapKit
import Then
import SwiftUI

/// 메인 피드 화면 컨트롤러
/// - 기능: 트윗 리스트 출력, 트윗 디테일 진입, 댓글 작성, 멘션 처리, 로그아웃 처리
/// - 구조: MVVM + Router 아키텍처
/// - 유저 정보 변경 시 Notification을 통해 트윗과 헤더 이미지 실시간 갱신
final class FeedController: UIViewController {

    // MARK: - Dependencies

    /// 탭 루트 화면 전환 및 로그아웃 처리를 위한 메인 라우터
    private let router : MainTabBarRouterProtocol

    /// 트윗 디테일, 댓글 작성 등 피드 내 전환 처리를 담당하는 라우터
    private let feedRouter : FeedRouterProtocol

    /// 트윗 데이터를 불러오고 수정하는 저장소
    private let repository : TweetRepositoryProtocol

    /// 로그아웃 비즈니스 로직 처리 유즈케이스
    private let logoutUseCase: LogoutUseCaseProtocol

    /// 좋아요 처리 유즈케이스
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol

    /// 팔로우 상태 관리 유즈케이스
    private let followUseCase: FollowUseCaseProtocol

    /// 유저 정보를 패칭하기 위한 저장소
    private let userRepository: UserRepositoryProtocol

    // MARK: - View Models

    /// 현재 로그인된 유저 상태 관리 뷰모델
    private let userViewModel: UserViewModel

    /// 트윗 리스트 로딩 및 상태 관리 뷰모델
    private let viewModel: FeedViewModel

    // MARK: - UI Components

    /// 트윗을 나열하는 컬렉션 뷰
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    /// 네비게이션 타이틀로 사용될 트위터 로고 이미지
    private let logoImageView = UIImageView().then {
        $0.image = .twitterLogoBlue
    }

    /// 로고 이미지를 감싸는 컨테이너 뷰
    private lazy var logoImageContainerView = UIView().then {
        $0.addSubview(logoImageView)
    }

    /// 좌측 상단 사용자 프로필 이미지
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
    }

    /// 우측 상단 로그아웃 버튼
    private lazy var logoutButton = UIButton(type: .custom).then {
        $0.setTitle("Logout", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .backGround
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(handleLogoutButtonTapped), for: .touchUpInside)
    }

    // MARK: - Initializer

    /// DI 기반 생성자 - 모든 의존성을 외부에서 주입받아 설정
    init(userViewModel: UserViewModel,
         logoutUseCase: LogoutUseCaseProtocol,
         router: MainTabBarRouterProtocol,
         repository: TweetRepositoryProtocol,
         feedRouter: FeedRouterProtocol,
         tweetLikeUseCase: TweetLikeUseCaseProtocol,
         followUseCase: FollowUseCaseProtocol,
         userRepository: UserRepositoryProtocol) {
        self.userViewModel = userViewModel
        self.repository = repository
        self.viewModel = FeedViewModel(logoutUseCase: logoutUseCase, repository: repository)
        self.router = router
        self.feedRouter = feedRouter
        self.tweetLikeUseCase = tweetLikeUseCase
        self.logoutUseCase = logoutUseCase
        self.followUseCase = followUseCase
        self.userRepository = userRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard 미사용")
    }

    // MARK: - Deinitializer

    /// Notification observer 해제
    deinit {
        NotificationCenter.default.removeObserver(self)
        viewModel.onLogoutFail = nil
        viewModel.onLogutSuccess = nil
        viewModel.onFetchTweetsSuccess = nil
        viewModel.onFetchTweetFail = nil
    }

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        configureProfileImageView()
        bindViewModel()
        registerNotificationObservers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
    }

    // MARK: - Selectors

    /// 로그아웃 버튼 탭 시 로그아웃 알럿 표시
    @objc private func handleLogoutButtonTapped() {
        showLogoutAlert()
    }

    /// NotificationCenter를 통해 프로필 정보 변경 시 피드에 실시간 반영
    @objc private func handleProfileUpdated(_ notification: Foundation.Notification) {
        guard let updatedUser = notification.object as? UserModelProtocol else { return }
        self.userViewModel.updateUserViewModel(user: updatedUser)
        self.configureProfileImageView()
        self.updateTweetsWithUpdatedUser(updatedUser)
        self.collectionView.reloadData()
    }

    // MARK: - UI Configurations

    /// 네비게이션바 구성 (로고, 프로필, 로그아웃 버튼 등)
    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        navigationItem.titleView = logoImageContainerView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutButton)
        setLogoImageViewConstraints()
        setProfileImageViewConstraints()
        setLogoutButtonConstraints()
    }

    /// 배경색 설정
    private func configureUI() {
        view.backgroundColor = .white
    }

    /// 컬렉션뷰 설정 및 셀 등록
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: CellIdentifier.tweetCell)
    }

    /// 유저 프로필 이미지 뷰 설정
    private func configureProfileImageView() {
        DispatchQueue.main.async { [weak self, weak vm = userViewModel] in
            guard let self,
                  let vm else { return }
            self.profileImageView.kf.setImage(with: vm.profileImageUrl)
        }
    }

    // MARK: - Constraints 설정

    private func setLogoImageViewConstraints() {
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(60)
        }
    }

    private func setProfileImageViewConstraints() {
        profileImageView.snp.makeConstraints { $0.size.equalTo(32) }
    }

    private func setLogoutButtonConstraints() {
        logoutButton.snp.makeConstraints {
            $0.width.equalTo(64)
            $0.height.equalTo(32)
        }
    }

    // MARK: - Notification 등록

    /// 유저 정보 변경 감지를 위한 Notification observer 등록
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProfileUpdated), name: .didUpdateProfile, object: nil)
    }

    // MARK: - 트윗 내부 유저 정보 갱신

    /// 트윗 목록 중 해당 유저의 UID를 가진 트윗의 user 속성을 업데이트
    private func updateTweetsWithUpdatedUser(_ updatedUser: UserModelProtocol) {
        for tweet in viewModel.allTweets where tweet.user.uid == updatedUser.uid {
            tweet.user = updatedUser
        }
    }

    // MARK: - Alert 처리

    /// 에러 메시지용 공통 Alert
    private func authErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    /// 로그아웃 전 사용자 확인용 Alert
    private func showLogoutAlert() {
        let alertController = UIAlertController(title: "Logout", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        })
        alertController.addAction(UIAlertAction(title: "Cancle", style: .cancel))
        present(alertController, animated: true)
    }

    // MARK: - ViewModel 바인딩

    /// ViewModel에서 전달되는 상태값에 따른 UI 처리
    private func bindViewModel() {
        viewModel.onLogutSuccess = { [weak self] in
            self?.router.logout(from: self!)
        }

        viewModel.onLogoutFail = { [weak self] message in
            self?.authErrorAlert(message: message)
        }

        viewModel.onFetchTweetsSuccess = { [weak self] in
            self?.collectionView.reloadData()
        }

        viewModel.onFetchTweetFail = { [weak self] error in
            self?.authErrorAlert(message: error.localizedDescription)
        }

        viewModel.fetchAllTweets()
    }

}

// MARK: - UICollectionViewDataSource

extension FeedController: UICollectionViewDataSource {

    /// 현재 트윗 개수 반환 (컬렉션 뷰 셀 개수 결정)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.allTweets.count
    }

    /// 트윗 셀 구성 및 뷰모델 주입
    /// - 프로필 이미지 탭, 댓글 탭, 멘션 탭 등의 이벤트 콜백도 이곳에서 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.tweetCell, for: indexPath) as? TweetCell else {
            return UICollectionViewCell()
        }

        let tweet = viewModel.allTweets[indexPath.item]
        let userVM = UserViewModel(user: tweet.user, followUseCase: followUseCase)
        let tweetVM = TweetViewModel(tweet: tweet,
                                     repository: repository,
                                     useCase: tweetLikeUseCase,
                                     userViewModel: userVM,
                                     userRepository: userRepository)

        cell.viewModel = tweetVM

        // 프로필 이미지 탭 → 해당 유저 프로필로 이동
        cell.onProfileImageViewTapped = { [weak self, weak vm = tweetVM] in
            guard let self,
                  let vm else { return }
            let userVM = UserViewModel(user: vm.getUser(), followUseCase: followUseCase)
            self.feedRouter.navigateToUserProfile(userViewModel: userVM, from: self)
        }

        // 댓글 버튼 탭 → 댓글 작성 화면으로 전환
        cell.viewModel?.onHandleCommentButton = { [weak self, weak vm = tweetVM] in
            guard let self,
                  let vm else { return }
            let userVM = UserViewModel(user: vm.getUser(), followUseCase: followUseCase)
            self.feedRouter.navigate(to: .uploadReply(userViewModel: userVM, tweet: tweet), from: self)
        }

        // 멘션된 유저 탭 → 해당 유저 프로필로 이동
        cell.viewModel?.onMentionUserFetched = { [weak self] user in
            guard let self else { return }
            let userVM = UserViewModel(user: user, followUseCase: followUseCase)
            self.feedRouter.navigateToUserProfile(userViewModel: userVM, from: self)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension FeedController: UICollectionViewDelegate {

    /// 셀 선택 시 트윗 디테일 화면으로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweet = viewModel.allTweets[indexPath.item]
        let userVM = UserViewModel(user: tweet.user, followUseCase: followUseCase)
        let tweetVM = TweetViewModel(tweet: tweet, repository: repository,
                                     useCase: tweetLikeUseCase,
                                     userViewModel: userVM,
                                     userRepository: userRepository)

        feedRouter.navigateToTweetDetail(viewModel: tweetVM, userViewModel: userVM, from: self)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {

    /// 트윗 셀 높이를 트윗 내용에 따라 동적으로 계산
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = viewModel.allTweets[indexPath.row]
        let estimatedHeight = estimateCellHeight(for: tweet)
        return CGSize(width: collectionView.frame.width, height: estimatedHeight)
    }

    /// 셀 높이 계산을 위해 임시 TweetCell을 생성해 AutoLayout 기반 측정 수행
    private func estimateCellHeight(for tweet: Tweet) -> CGFloat {
        let dummyCell = TweetCell()
        dummyCell.viewModel = TweetViewModel(tweet: tweet,repository: repository, useCase: tweetLikeUseCase, userViewModel: userViewModel, userRepository: userRepository)
        dummyCell.layoutIfNeeded()

        let targetSize = CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return estimatedSize.height
    }
}

#Preview {

    let mockUserViewModel = UserViewModel(user: MockUserModel(bio: "test"), followUseCase: MockFollowUseCase())
    let mockLogoutUseCase = MockLogoutUseCase()
    let mockRouter = MockMainTabRouter()
    let mockRepository = MockTweetRepository()
    let mockFeedRouter = MockFeedRouter()
    let mockDiContainer = MockDiContainer()
    let mockTweetLikeUseCase = MockTweetLikeUseCase()

    VCPreView {
        UINavigationController(rootViewController: FeedController(userViewModel: mockUserViewModel, logoutUseCase: mockLogoutUseCase, router: mockRouter, repository: mockRepository, feedRouter: mockFeedRouter, tweetLikeUseCase: mockTweetLikeUseCase, followUseCase: MockFollowUseCase(), userRepository: MockUserRepository()))
    }
}
