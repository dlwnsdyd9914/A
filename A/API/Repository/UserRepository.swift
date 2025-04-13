//
//  UserRepository.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class UserRepository: UserRepositoryProtocol {

    
    
    private let service: UserService

    init(service: UserService) {
        self.service = service
    }

    func fetchUser(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        service.getCurrentUser(completion: completion)
    }

    func fetchAllUserList(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        service.getAllUserList(completion: completion)
    }

    func follow(uid: String, completion: @escaping () -> Void) {
        service.follow(uid: uid, completion: completion)
    }

    func unfollow(uid: String, completion: @escaping () -> Void) {
        service.unFollow(uid: uid, completion: completion)
    }

    func checkFollowStatus(uid: String, completion: @escaping (Bool) -> Void) {
        service.checkingFollow(uid: uid, completion: completion)
    }

    func getFollowCount(uid: String, completion: @escaping (Int, Int) -> Void) {
        service.getFollowCount(uid: uid, completion: completion)
    }

    func fetchSelectedUser(uid: String, completion: @escaping (Result<User, UserServiceError>) -> Void) {
        service.fetchSelectedUser(uid: uid, completion: completion)
    }



    

}
