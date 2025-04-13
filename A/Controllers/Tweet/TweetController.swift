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

final class TweetController: UIViewController {

    // MARK: - Properties

    private let repository: TweetRepositoryProtocol

    private let router: TweetRouterProtocol

    private let useCase: TweetLikeUseCaseProtocol

    private let followUseCase: FollowUseCaseProtocol


    // MARK: - View Models

    private let viewModel: TweetViewModel

    // MARK: - UI Components

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    // MARK: - Initializer
    init(viewModel: TweetViewModel, repository: TweetRepositoryProtocol, router: TweetRouterProtocol, useCase: TweetLikeUseCaseProtocol, followUseCase: FollowUseCaseProtocol) {
        self.viewModel = viewModel
        self.repository = repository
        self.router = router
        self.useCase = useCase
        self.followUseCase = followUseCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Life Cycles

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

    // MARK: - Selectors

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

        collectionView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: CellIdentifier.tweetCell)
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.tweetHeader)
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    private func bindViewModel() {

        viewModel.onRepliesFetchSuccess = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

        viewModel.onLikeSuccess = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }}

        viewModel.fetchReplies()
    }


}

extension TweetController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.replies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.tweetCell, for: indexPath) as? TweetCell else {
            return UICollectionViewCell()
        }

        let tweetViewModel = TweetViewModel(tweet: viewModel.replies[indexPath.item], repository: repository, useCase: useCase)

        cell.viewModel = tweetViewModel
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.tweetHeader, for: indexPath) as? TweetHeader else {
            return UICollectionReusableView()
        }
        let tweetHeaderViewModel = TweetHeaderViewModel(tweet: viewModel.getTweet())
        header.viewModel = tweetHeaderViewModel
        header.viewModel?.handleShowActionSheet = { [weak self] in
            guard let self else { return }
            let userViewModel = UserViewModel(user: viewModel.getUser())
            let actionSheetViewModel = ActionSheetViewModel(userviewModel: userViewModel, useCase: followUseCase)
            DispatchQueue.main.async {
                self.router.presentActionSheet(viewModel: actionSheetViewModel, from: self)
            }
        }
        return header
    }
}

extension TweetController: UICollectionViewDelegate {

}

extension TweetController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: estimatedHeight(isHeader: true))
    }



    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width
        let tweet = viewModel.replies[indexPath.row]

        print(estimatedHeight(tweet: tweet, isHeader: false))

        return CGSize(width: width, height: estimatedHeight(tweet: tweet, isHeader: false))
    }

    private func estimatedHeight(tweet: TweetModelProtocol? = nil, isHeader: Bool) -> CGFloat {
        let dummy: UIView

        // collectionView width가 아직 0인 경우 대비
        let safeWidth = collectionView.frame.width > 0 ? collectionView.frame.width : UIScreen.main.bounds.width

        if isHeader {
            let dummyHeader = TweetHeader()

            if let tweet = tweet {
                dummyHeader.viewModel = TweetHeaderViewModel(tweet: tweet)
            }

            dummyHeader.frame = CGRect(x: 0, y: 0, width: safeWidth, height: 1000)
            dummyHeader.setNeedsLayout()
            dummyHeader.layoutIfNeeded()
            dummy = dummyHeader
        } else {
            let dummyCell = TweetCell()


            dummyCell.frame = CGRect(x: 0, y: 0, width: safeWidth, height: 1000)


            if let tweet = tweet {
                dummyCell.viewModel = TweetViewModel(tweet: tweet, repository: repository, useCase: useCase)
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

