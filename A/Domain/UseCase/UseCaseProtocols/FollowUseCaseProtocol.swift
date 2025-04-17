//
//  FollowUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol FollowUseCaseProtocol {
    func follow(uid: String, completion: @escaping () -> Void)
    func unfollow(uid: String, completion: @escaping () -> Void)
    func checkFollowStatus(uid: String, completion: @escaping (Bool) -> Void)
    func getFollowCounts(uid: String, completion: @escaping (Int, Int) -> Void)
    func toggleFollow(didFollow: Bool, uid: String, completion: @escaping () -> Void)
}
