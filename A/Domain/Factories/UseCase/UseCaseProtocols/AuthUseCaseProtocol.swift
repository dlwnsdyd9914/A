//
//  AuthUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol SignUpUseCaseProtocol {
    func signUp(email: String, password: String, username: String, fullname: String, profileImage: UIImage, completion: @escaping (Result<Void, AuthServiceError>) -> Void)
}

protocol LoginUseCaseProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void)
}

protocol LogoutUseCaseProtocol {
    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void)
}
