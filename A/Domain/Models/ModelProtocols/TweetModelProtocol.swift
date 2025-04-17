//
//  TweetModelProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol TweetModelProtocol {
    var caption: String { get }
    var lieks: Int { get set }
    var retweets: Int { get }
    var timeStamp: Date { get }
    var tweetId: String { get }
    var uid: String { get }
    var user: UserModelProtocol { get }
    var didLike: Bool { get set }
    var replyingTo: String? { get set }
    var isRely: Bool { get }
}
