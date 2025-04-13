//
//  UserRepositoryProtocol.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol UserRepositoryProtocol {
    func fetchUser(completion: @escaping (Result<User, UserServiceError>) -> Void)
    func fetchAllUserList(completion: @escaping (Result<User, UserServiceError>) -> Void)
    func follow(uid: String, completion: @escaping () -> Void)
    func unfollow(uid: String, completion: @escaping () -> Void)
    func checkFollowStatus(uid: String, completion: @escaping (Bool) -> Void)
    func getFollowCount(uid: String, completion: @escaping (Int, Int) -> Void)
    func fetchSelectedUser(uid: String, completion: @escaping (Result<User, UserServiceError>) -> Void)
}
