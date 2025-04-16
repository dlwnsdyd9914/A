//
//  TweetController.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit
import SnapKit
import Then
import SwiftUI

/// 트윗 상세 화면 컨트롤러
/// - 트윗 본문 + 리플 목록을 표시하며, MVVM 구조 기반으로 구성
/// - TweetViewModel이 메인 모델이며, 댓글/좋아요 관련 유즈케이스와 연결됨
/// - 동적 셀 높이 계산을 통해 댓글이 많아도 유연한 레이아웃 유지
final class TweetController: UIViewController {

    // MARK: - Dependencies

    /// 트윗 데이터 fetch 및 좋아요 처리에 사용되는 레포지토리
    private let repository: TweetRepositoryProtocol

    /// 현재 화면에서 발생하는 라우팅(액션 시트, 프로필 이동 등)을 담당
    private let router: TweetRouterProtocol

    /// 트윗 좋아요/언좋아요 관련 유즈케이스 (비즈니스 로직)
    private let useCase: TweetLikeUseCaseProtocol

    /// 유저 팔로우/언팔로우 처리 유즈케이스
    private let followUseCase: FollowUseCaseProtocol

    /// 유저 관련 정보 fetch/처리용 레포지토리
    private let userRepository: UserRepositoryProtocol

    // MARK: - ViewModels

    /// 현재 트윗의 전체 상태 (본문, 리플, 좋아요 등)
    private let viewModel: TweetViewModel

    /// 현재 로그인된 유저 상태
    private let userViewModel: UserViewModel

    // MARK: - UI Components

    /// 트윗 본문 + 리플 목록을 구성하는 컬렉션뷰
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // MARK: - Initializer

    /// DI를 통한 의존성 주입
    init(
        viewModel: TweetViewModel,
        repository: TweetRepositoryProtocol,
        router: TweetRouterProtocol,
        useCase: TweetLikeUseCaseProtocol,
        followUseCase: FollowUseCaseProtocol,
        userViewModel: UserViewModel,
        userRepository: UserRepositoryProtocol
    ) {
        self.viewModel = viewModel
        self.repository = repository
        self.router = router
        self.useCase = useCase
        self.followUseCase = followUseCase
        self.userViewModel = userViewModel
        self.userRepository = userRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard 미사용")
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
        bindViewModel()
    }

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        navigationItem.title = "Tweet"
    }

    private func configureUI() {
        view.backgroundColor = .white
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: CellIdentifier.tweetCell)
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.tweetHeader)
    }

    // MARK: - ViewModel Bindings

    private func bindViewModel() {
        viewModel.onRepliesFetchSuccess = { [weak self] in
            self?.collectionView.reloadData()
        }

        viewModel.onLikeSuccess = { [weak self] in
            self?.collectionView.reloadData()
        }

        viewModel.fetchReplies()
    }
}

// MARK: - UICollectionViewDataSource

extension TweetController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.replies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.tweetCell, for: indexPath) as? TweetCell else {
            return UICollectionViewCell()
        }

        let reply = viewModel.replies[indexPath.item]
        let tweetViewModel = TweetViewModel(
            tweet: reply,
            repository: repository,
            useCase: useCase,
            userViewModel: userViewModel,
            userRepository: userRepository
        )

        cell.viewModel = tweetViewModel
        return cell
    }

    // 헤더 뷰 (원본 트윗 정보)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.tweetHeader, for: indexPath) as? TweetHeader else {
            return UICollectionReusableView()
        }

        let tweetHeaderViewModel = TweetHeaderViewModel(tweet: viewModel.getTweet(), followUseCase: followUseCase)
        header.viewModel = tweetHeaderViewModel

        header.viewModel?.handleShowActionSheet = { [weak self] in
            guard let self else { return }
            let userVM = UserViewModel(user: viewModel.getUser(), followUseCase: followUseCase)
            let actionSheetVM = ActionSheetViewModel(userviewModel: userVM, useCase: followUseCase)

            DispatchQueue.main.async {
                self.router.presentActionSheet(viewModel: actionSheetVM, from: self)
            }
        }

        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TweetController: UICollectionViewDelegate {}

// MARK: - 셀/헤더 동적 높이 계산

extension TweetController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: estimatedHeight(isHeader: true))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = viewModel.replies[indexPath.row]
        return CGSize(width: collectionView.frame.width, height: estimatedHeight(tweet: tweet, isHeader: false))
    }

    /// 셀/헤더 동적 높이 계산 로직 (레이아웃 잡힌 더미 뷰를 통해 측정)
    private func estimatedHeight(tweet: TweetModelProtocol? = nil, isHeader: Bool) -> CGFloat {
        let width = collectionView.frame.width > 0 ? collectionView.frame.width : UIScreen.main.bounds.width
        let dummy: UIView

        if isHeader {
            let header = TweetHeader()
            if let tweet {
                header.viewModel = TweetHeaderViewModel(tweet: tweet, followUseCase: followUseCase)
            }
            header.frame = CGRect(x: 0, y: 0, width: width, height: 1000)
            header.layoutIfNeeded()
            dummy = header
        } else {
            let cell = TweetCell()
            if let tweet {
                cell.viewModel = TweetViewModel(tweet: tweet, repository: repository, useCase: useCase, userViewModel: userViewModel, userRepository: userRepository)
            }
            cell.frame = CGRect(x: 0, y: 0, width: width, height: 1000)
            cell.layoutIfNeeded()
            dummy = cell.contentView
        }

        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        var estimated = dummy.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        if isHeader {
            estimated.height = max(estimated.height, 200)
        }

        return estimated.height
    }
}
