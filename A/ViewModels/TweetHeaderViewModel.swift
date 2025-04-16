//
//  TweetHeaderViewModel.swift
//  A
//

//

import UIKit

/// 트윗 상세 화면의 헤더 정보 구성을 위한 뷰모델입니다.
/// - 기능: 트윗 작성자 정보, 좋아요/리트윗 수, 작성 시간 등의 UI에 필요한 데이터 제공
final class TweetHeaderViewModel: TweetHeaderViewModelProtocol {

    // MARK: - Properties

    /// 트윗 모델
    private var tweet: TweetModelProtocol

    /// 트윗 작성자 유저의 뷰모델 (팔로우 상태 포함)
    private(set) var userViewModel: UserViewModel

    /// 팔로우/언팔로우 처리 유즈케이스
    private let followUseCase: FollowUseCaseProtocol

    // MARK: - Output Closures

    /// 액션 시트 호출 시점에 실행되는 클로저
    var handleShowActionSheet: (() -> Void)?

    // MARK: - Initializer

    init(tweet: TweetModelProtocol, followUseCase: FollowUseCaseProtocol) {
        self.tweet = tweet
        self.followUseCase = followUseCase
        self.userViewModel = UserViewModel(user: tweet.user as UserModelProtocol, followUseCase: followUseCase)
    }

    // MARK: - Computed Properties

    /// 트윗 본문 내용
    var caption: String {
        return tweet.caption
    }

    /// 작성자 전체 이름
    var fullname: String {
        return tweet.user.fullName
    }

    /// 작성자 유저네임
    var username: String {
        return tweet.user.userName
    }

    /// 작성자 프로필 이미지 URL
    var profileImageUrl: URL? {
        return URL(string: tweet.user.profileImageUrl)
    }

    /// 리트윗 수에 대한 AttributedText
    var retweetAttributedString: NSAttributedString {
        return funcAttributedText(value: tweet.retweets, text: "Retweets")
    }

    /// 좋아요 수에 대한 AttributedText
    var likesAttributedString: NSAttributedString {
        return funcAttributedText(value: tweet.lieks, text: "likes")
    }

    /// 트윗 작성 시각 표시용 문자열
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ∙ MM/dd/yyyy"
        return formatter.string(from: tweet.timeStamp)
    }

    /// 작성자 이름 + 유저네임 + 시간 정보가 포함된 복합 라벨 (트윗 셀 상단)
    var infoLabel: NSAttributedString {
        let title = NSMutableAttributedString(
            string: tweet.user.fullName,
            attributes: [.font : UIFont.boldSystemFont(ofSize: 14)]
        )
        title.append(NSAttributedString(
            string: " @\(tweet.user.userName)",
            attributes: [
                .font : UIFont.systemFont(ofSize: 12),
                .foregroundColor : UIColor.lightGray
            ])
        )
        title.append(NSAttributedString(
            string: " . \(headerTimestamp)",
            attributes: [
                .font : UIFont.systemFont(ofSize: 14),
                .foregroundColor : UIColor.lightGray
            ])
        )
        return title
    }

    // MARK: - Functions

    /// 숫자 + 설명 텍스트를 합친 AttributedText 생성기
    /// - Parameters:
    ///   - value: 숫자 값 (ex. 좋아요 수, 리트윗 수)
    ///   - text: 표시될 설명 (ex. "likes", "Retweets")
    /// - Returns: 볼드 숫자 + 회색 설명이 결합된 NSAttributedString
    func funcAttributedText(value: Int, text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "\(value) ",
            attributes: [.font : UIFont.boldSystemFont(ofSize: 14)]
        )
        attributedText.append(NSAttributedString(
            string: text,
            attributes: [
                .font : UIFont.systemFont(ofSize: 14),
                .foregroundColor : UIColor.lightGray
            ])
        )
        return attributedText
    }

    /// 사용자 옵션 버튼을 눌렀을 때 액션 시트를 보여주는 함수
    func showActionSheet() {
        handleShowActionSheet?()
    }
}
