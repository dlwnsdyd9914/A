//
//  ProfileController.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit
import Then
import SwiftUI


final class ProfileController: UIViewController {

    // MARK: - Properties

    private let router: MainTabBarRouterProtocol
    private let feedRouter: FeedRouterProtocol
    private let repository: TweetRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol


    // MARK: - View Models

    private let userViewModel: UserViewModel
    private let viewModel: ProfileViewModel
    private let profileHeaderViewModel: ProfileHeaderViewModel


    // MARK: - UI Components

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()


    // MARK: - Initializer

    init(router: MainTabBarRouterProtocol, userViewModel: UserViewModel, repository: TweetRepositoryProtocol, useCase: FollowUseCaseProtocol, feedRouter: FeedRouterProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol) {
        self.router = router
        self.userViewModel = userViewModel
        self.repository = repository
        self.viewModel = ProfileViewModel(repository: repository)
        self.profileHeaderViewModel = ProfileHeaderViewModel(user: userViewModel.getUser(), useCase: useCase)
        self.feedRouter = feedRouter
        self.tweetLikeUseCase = tweetLikeUseCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Life Cycles

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        bindViewModel()
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureUI() {
        view.backgroundColor = .white
    }

    private func configureCollectionView() {
        self.view.addSubview(collectionView)

        self.collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInsetAdjustmentBehavior = .never
        //        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        self.collectionView.register(TweetCell.self, forCellWithReuseIdentifier: CellIdentifier.tweetCell)
        self.collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.profileHeader)


    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        viewModel.onSuccessSelectedFetchTweet = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

        profileHeaderViewModel.onFollowToggled = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

        viewModel.selectedFetchTweet(uid: userViewModel.uid)
    }

}


extension ProfileController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedTweet.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.tweetCell, for: indexPath) as? TweetCell else {
            return UICollectionViewCell()
        }
        let tweetViewModel = TweetViewModel(tweet: viewModel.selectedTweet[indexPath.row], repository: repository, useCase: tweetLikeUseCase)
        cell.viewModel = tweetViewModel
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.profileHeader, for: indexPath) as? ProfileHeader else {
            return UICollectionReusableView()
        }
        header.viewModel = profileHeaderViewModel
        header.delegate = self


        header.onBackButtonTap = { [weak self] in
            guard let self else { return }
            router.popNav(from: self)
        }
        return header
    }
}

extension ProfileController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweetViewModel = TweetViewModel(tweet: viewModel.selectedTweet[indexPath.item], repository: repository, useCase: tweetLikeUseCase)
        feedRouter.navigateToTweetDetail(viewModel: tweetViewModel, from: self)
    }
}

extension ProfileController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: estimatedHeight(isHeader: true))
    }



    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width
        let tweet = viewModel.selectedTweet[indexPath.row]

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
                dummyCell.viewModel = TweetViewModel(tweet: tweet, repository: repository, useCase: tweetLikeUseCase)
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

extension ProfileController: ProfileHeaderDelegate {
    func profileHeader(_ header: ProfileHeader, didSelect filter: FilterOption) {
        viewModel.selectedFilter = filter
        viewModel.selectedFetchTweet(uid: userViewModel.uid)
    }


}

#Preview {

    let mockUserViewModel = UserViewModel(user: MockUserModel(bio: "Test"))
    let mockRouter = MockMainTabRouter()
    let mockRepository = MockTweetRepository()
    let mockFollowUseCase = MockFollowUseCase()
    let mockFeedRouter = MockFeedRouter()
    let mockDiContainer = MockDiContainer()
    let mockTweetLikeUseCase = MockTweetLikeUseCase()

    VCPreView {
        UINavigationController(rootViewController: ProfileController(router: mockRouter, userViewModel: mockUserViewModel, repository: mockRepository, useCase: mockFollowUseCase, feedRouter: mockFeedRouter, tweetLikeUseCase: mockTweetLikeUseCase))
    }.edgesIgnoringSafeArea(.all)
}
