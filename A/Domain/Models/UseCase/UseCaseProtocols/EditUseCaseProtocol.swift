//
//  EditUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/16/25.
//

import UIKit

protocol EditUseCaseProtocol {
    func editProfile(profileImage: UIImage?, fullName: String?, userName: String?, bio: String?, profileImageUrl: String?, currentUser: UserModelProtocol, completion: @escaping ((Result<String?, Error>) -> Void))

}
