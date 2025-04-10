//
//  UserRepositoryProtocol.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol UserRepositoryProtocol {
    func fetchUser(completion: @escaping (Result<User, UserServiceError>) -> Void) 
}
