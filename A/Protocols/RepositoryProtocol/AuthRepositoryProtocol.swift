//
//  AuthRepository.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol AuthRepositoryProtocol {
    func signUp(email: String, password: String, username: String, fullname: String, profileImage: UIImage, completion: @escaping (Result<Void, AuthServiceError>) -> Void)
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void)
    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void)
}

