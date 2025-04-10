//
//  LoginUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol LoginUseCaseProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void)
}
