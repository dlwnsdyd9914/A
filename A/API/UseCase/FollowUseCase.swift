//
//  FollowUseCase.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class FollowUseCase: FollowUseCaseProtocol {

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func follow(uid: String, completion: @escaping () -> Void) {
        repository.follow(uid: uid, completion: completion)
    }
    
    func unfollow(uid: String, completion: @escaping () -> Void) {
        repository.unfollow(uid: uid, completion: completion)
    }
    
    func checkFollowStatus(uid: String, completion: @escaping (Bool) -> Void) {
        repository.checkFollowStatus(uid: uid, completion: completion)
    }
    
    func getFollowCounts(uid: String, completion: @escaping (Int, Int) -> Void) {
        repository.getFollowCount(uid: uid, completion: completion)
    }

    func toggleFollow(didFollow: Bool, uid: String, completion: @escaping () -> Void) {
        didFollow ? unfollow(uid: uid, completion: completion)
                          : follow(uid: uid, completion: completion)
    }


}
