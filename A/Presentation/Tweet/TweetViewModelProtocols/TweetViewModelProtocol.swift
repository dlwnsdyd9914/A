//
//  TweetViewModelProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import Foundation

protocol TweetViewModelProtocol {
    var caption: String { get }
    var timestamp: String { get }
    var profileImageUrl: URL? { get }
    var tweetId: String { get }
    var infoLabel: NSAttributedString { get }
    func handleLikeButton()
    func handleRetweetButton()
    func handleCommentButton()
    func handleShareButton()
    var onHandleCommentButton: (() -> Void)? { get set }

}
