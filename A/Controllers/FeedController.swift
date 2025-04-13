//
//  FeedController.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import Kingfisher
import SnapKit
import Then
import SwiftUI

final class FeedController: UIViewController {

    // MARK: - Properties

    private let router : MainTabBarRouterProtocol
    private let feedRouter : FeedRouterProtocol
    private let repository : TweetRepositoryProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol



    // MARK: - View Models

    private let userViewModel: UserViewModel

    private let viewModel: FeedViewModel

    // MARK: - UI Components

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private let logoImageView = UIImageView().then {
        $0.image = .twitterLogoBlue
    }

    private lazy var logoImageContainerView = UIView().then {
        $0.addSubview(logoImageView)
    }

    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
    }

    private lazy var logoutButton = UIButton(type: .custom).then {
        $0.setTitle("Logout", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .backGround
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(handleLogoutButtonTapped), for: .touchUpInside)
    }

    // MARK: - Initializer
    init(userViewModel: UserViewModel, logoutUseCase: LogoutUseCaseProtocol, router: MainTabBarRouterProtocol, repository: TweetRepositoryProtocol, feedRouter: FeedRouterProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol) {
        self.userViewModel = userViewModel
        self.repository = repository
        self.viewModel = FeedViewModel(logoutUseCase: logoutUseCase, repository: repository)
        self.router = router
        self.feedRouter = feedRouter
        self.tweetLikeUseCase = tweetLikeUseCase
        self.logoutUseCase = logoutUseCase
        super.init(nibName: nil, bundle: nil)
    }



    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Life Cycles

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        configureProfileImageView()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
    }

    // MARK: - Selectors

    @objc private func handleLogoutButtonTapped() {
        showLogoutAlert()
    }

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        self.navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()

        self.navigationItem.titleView = logoImageContainerView

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutButton)

        setLogoImageViewConstraints()
        setProfileImageViewConstraints()
        setLogoutButtonConstraints()


    }

    private func configureUI() {
        view.backgroundColor = .white
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: CellIdentifier.tweetCell)
    }

    private func setLogoImageViewConstraints() {
        logoImageView.snp.makeConstraints({
            $0.centerX.equalTo(logoImageContainerView.snp.centerX)
            $0.centerY.equalTo(logoImageContainerView.snp.centerY)
            $0.size.equalTo(60)
        })
    }

    private func setProfileImageViewConstraints() {
        profileImageView.snp.makeConstraints({
            $0.size.equalTo(32)
        })
    }

    private func setLogoutButtonConstraints() {
        logoutButton.snp.makeConstraints({
            $0.width.equalTo(64)
            $0.height.equalTo(32)
        })
    }


    // MARK: - Functions

    private func authErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }

    private func showLogoutAlert() {
        let alertController = UIAlertController(title: "Logut", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        let logout = UIAlertAction(title: "Logout", style: .destructive) {[weak self] _ in
            guard let self else { return }

            self.viewModel.logout()
        }
        let cancle = UIAlertAction(title: "Cancle", style: .cancel)
        alertController.addAction(logout)
        alertController.addAction(cancle)
        self.present(alertController, animated: true)
    }


    // MARK: - Bind ViewModels

    private func bindViewModel() {

        viewModel.onLogutSuccess = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.router.logout(from: self)
            }
        }

        viewModel.onLogoutFail = { [weak self] message in
            guard let self else { return }
            DispatchQueue.main.async {
                self.authErrorAlert(message: message)
            }
        }

        viewModel.onFetchTweetsSuccess = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

        viewModel.onFetchTweetFail = { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                self.authErrorAlert(message: error.localizedDescription)
            }
        }


        viewModel.fetchAllTweets()

    }


    private func configureProfileImageView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            profileImageView.kf.setImage(with: userViewModel.profileImageUrl)
        }
    }

}

extension FeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.allTweets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.tweetCell, for: indexPath) as? TweetCell else {
            return UICollectionViewCell()
        }

        let tweetViewModel = TweetViewModel(tweet: viewModel.allTweets[indexPath.row], repository: repository, useCase: tweetLikeUseCase)
        cell.viewModel = tweetViewModel

        cell.onProfileImageViewTapped = { [weak self] in
            guard let self else { return }
            let userViewModel = UserViewModel(user: tweetViewModel.getUser())
            DispatchQueue.main.async {
                self.feedRouter.navigateToUserProfile(userViewModel: userViewModel, from: self)
            }
        }

        cell.viewModel?.onHandleCommentButton = {[weak self] in
            guard let self else { return }
            let userViewModel = UserViewModel(user: tweetViewModel.getUser())
            let tweet = viewModel.allTweets[indexPath.row]
            self.feedRouter.navigate(to: .uploadReply(userViewModel: userViewModel, tweet: tweet), from: self)
        }
        return cell
    }
}

extension FeedController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweetViewModel = TweetViewModel(tweet: viewModel.allTweets[indexPath.item], repository: repository, useCase: tweetLikeUseCase)
        feedRouter.navigateToTweetDetail(viewModel: tweetViewModel, from: self)
    }
}


extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}


#Preview {

    let mockUserViewModel = UserViewModel(user: MockUserModel(bio: "test"))
    let mockLogoutUseCase = MockLogoutUseCase()
    let mockRouter = MockMainTabRouter()
    let mockRepository = MockTweetRepository()
    let mockFeedRouter = MockFeedRouter()
    let mockDiContainer = MockDiContainer()
    let mockTweetLikeUseCase = MockTweetLikeUseCase()

    VCPreView {
        UINavigationController(rootViewController: FeedController(userViewModel: mockUserViewModel, logoutUseCase: mockLogoutUseCase, router: mockRouter, repository: mockRepository, feedRouter: mockFeedRouter, tweetLikeUseCase: mockTweetLikeUseCase))
    }
}
