//
//  Mock.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

class MockMainTabRouter: MainTabBarRouterProtocol {
    func showLogin(from viewController: UIViewController) {

    }

    func logout(from viewController: UIViewController) {

    }

    func navigate(to destination: TweetDestination, from viewController: UIViewController) {

    }

    func popNav(from viewController: UIViewController) {

    }


    
    func popView() {

    }
    
    func navigate(to destination: TweetDestination) {
        
    }
    
    func showLogin() {

    }
    
    func logout() {

    }
    

}

class MockLogoutUseCase: LogoutUseCaseProtocol {
    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        
    }

}

class MockUploadRouter: UploadTweetRouterProtocol {
    func dismiss(from viewController: UIViewController) {

    }
    

}

class MockTweetRepository: TweetRepositoryProtocol {
    func uploadTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {

    }
    
    func fetchAllTweets(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {

    }
    

}

class MockUploadTweetUseCase: UploadTweetUseCaseProtocol {
    func uploadTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        
    }
}
