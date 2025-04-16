//
//  Tweet.swift
//  A
//
//

import UIKit

/// 하나의 트윗 데이터를 나타내는 모델입니다.
///
/// - 역할: Firebase에서 받아온 트윗 데이터를 파싱하여 앱 내에서 사용 가능한 모델로 변환합니다.
///         트윗 본문, 작성자 정보, 좋아요 및 리트윗 수 등 핵심 트윗 정보를 제공합니다.
/// - 주요 사용처:
///     - `TweetViewModel`: 트윗 데이터를 바탕으로 셀에 표시할 정보 구성
///     - `FeedViewModel`, `ProfileViewModel`: 트윗 리스트를 관리 및 필터링할 때 사용
///     - `TweetController`, `TweetCell`: UI에 트윗 정보 출력 및 인터랙션 처리
final class Tweet: TweetModelProtocol {

    // MARK: - Properties

    /// 트윗 본문 텍스트
    var caption: String

    /// 좋아요 수
    var lieks: Int

    /// 리트윗 수
    var retweets: Int

    /// 트윗이 작성된 시간
    var timeStamp: Date

    /// 트윗의 고유 ID (문서 ID)
    var tweetId: String

    /// 트윗 작성자의 UID
    var uid: String

    /// 트윗 작성자 정보
    var user: UserModelProtocol

    /// 현재 로그인 유저가 이 트윗에 좋아요를 눌렀는지 여부
    var didLike: Bool = false

    /// 답글 대상 사용자 아이디 (멘션)
    var replyingTo: String?

    /// 이 트윗이 답글인지 여부
    var isRely: Bool {
        return !(replyingTo?.isEmpty ?? true)
    }

    // MARK: - Initializer

    /// 파이어베이스에서 받아온 딕셔너리를 통해 트윗 초기화
    /// - Parameters:
    ///   - tweetId: 문서 ID
    ///   - dictionary: 트윗 데이터 딕셔너리
    ///   - user: 트윗 작성자 정보
    init(tweetId: String, dictionary: [String: Any], user: UserModelProtocol) {
        self.user = user
        self.tweetId = tweetId
        self.uid = dictionary["uid"] as? String ?? ""
        self.lieks = dictionary["likes"] as? Int ?? 0
        self.retweets = dictionary["retweets"] as? Int ?? 0
        self.caption = dictionary["caption"] as? String ?? ""
        self.replyingTo = dictionary["replyingTo"] as? String ?? ""

        // 타임스탬프 파싱
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timeStamp = Date(timeIntervalSince1970: timestamp)
        } else {
            self.timeStamp = Date()
        }
    }

    // MARK: - Functions

    /// 트윗에 연결된 유저 정보 업데이트
    /// - Parameter user: 새로 받아온 유저 정보
    func updateUser(user: User) {
        self.user = user
    }
}
