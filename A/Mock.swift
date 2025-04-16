import UIKit

// MARK: - Mock Routers

class MockAuthRouter : AuthRouterProtocol {
    func navigate(to destination: AuthDestination, from viewController: UIViewController) {}
    func popNav(from viewController: UIViewController) {}


}

class MockMainTabRouter: MainTabBarRouterProtocol {
    func showLogin(from viewController: UIViewController) {}
    func logout(from viewController: UIViewController) {}
    func navigate(to destination: TweetDestination, from viewController: UIViewController) {}
    func popNav(from viewController: UIViewController) {}
    func popView() {}
    func navigate(to destination: TweetDestination) {}
    func showLogin() {}
    func logout() {}
}

class MockTweetRouter: TweetRouterProtocol {
    func navigateToTweetDetail(viewModel tweetViewModel: TweetViewModel, userViewModel: UserViewModel, from viewController: UIViewController) {

    }
    

    func navigateToUserProfile(userViewModel: UserViewModel, from viewController: UIViewController) {}
    
    func navigateToTweetDetail(viewModel: TweetViewModel, from viewController: UIViewController) {}
    func presentActionSheet(viewModel: ActionSheetViewModel, from viewController: UIViewController) {}
    func dismissAlert(_ alert: CustomAlertController, animated bool: Bool) {}
}

class MockFeedRouter: FeedRouterProtocol {
    func navigateToTweetDetail(viewModel tweetViewModel: TweetViewModel, userViewModel: UserViewModel, from viewController: UIViewController) {
        
    }
    
    func naivgateToEditProfile(userViewModel: UserViewModel, editProfileHeaderViewModel: EditProfileHeaderViewModel, editProfileViewModel: EditProfileViewModel, from viewController: UIViewController, onProfileEdited: @escaping (any UserModelProtocol) -> Void) {
    }
    

    


    
    func popNav(from viewController: UIViewController) {
    
    }

    
    func dismiss(from viewController: UIViewController) {
        
    }

    

    
    func navigate(to destination: TweetDestination, from viewController: UIViewController) {}
    func navigateToUserProfile(userViewModel: UserViewModel, from viewController: UIViewController) {}
}

class MockExplorerRouter: ExplorerRouterProtocol {
    func navigateToUserProfile(user: UserModelProtocol, from viewController: UIViewController) {}
}

class MockUploadTweetRouter: UploadTweetRouterProtocol {
    func close(style: UploadTweetPresentationStyle, from viewController: UIViewController) {}
    func navigate(to destination: TweetDestination, from viewController: UIViewController) {}
    func navigateToUploadTweet(type: UploadTweetController, viewModel: UserViewModel, from viewController: UIViewController) {}
    func dismiss(from viewController: UIViewController) {}
}

class MockNotificationRouter: NotificationRouterProtocol {
    func navigate(to destination: NotificationDestination, from viewController: UIViewController) {}
    

}


// MARK: - Mock UseCases

class MockLogoutUseCase: LogoutUseCaseProtocol {
    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void) {}
}

class MockUploadTweetUseCase: UploadTweetUseCaseProtocol {
    func uploadNewTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {}
    func uploadReply(caption: String, to tweet: TweetModelProtocol, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {}
}

class MockFollowUseCase: FollowUseCaseProtocol {
    func follow(uid: String, completion: @escaping () -> Void) {}
    func unfollow(uid: String, completion: @escaping () -> Void) {}
    func checkFollowStatus(uid: String, completion: @escaping (Bool) -> Void) {}
    func getFollowCounts(uid: String, completion: @escaping (Int, Int) -> Void) {}
    func toggleFollow(didFollow: Bool, uid: String, completion: @escaping () -> Void) {}
}

class MockFetchTweetWithRepliesUseCase: FetchTweetWithRepliesUseCaseProtocol {
    func fetchTweetWithReplies(completion: @escaping (Result<([Tweet], [Tweet]), TweetServiceError>) -> Void) {

    }
    
    func fetchTweetWithReplies(completion: @escaping (Result<(Tweet, [Tweet]), TweetServiceError>) -> Void) {}
    func fetchTweetsWithRepliesForProfile(uid: String, completion: @escaping (Result<(Tweet, [Tweet]), TweetServiceError>) -> Void) {}
}

class MockTweetLikeUseCase: TweetLikeUseCaseProtocol {
    func likesStatus(tweet: any TweetModelProtocol, completion: @escaping (Bool) -> Void) {}

    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void) {}
}

class MockSignUpUseCase: SignUpUseCaseProtocol {
    func signUp(email: String, password: String, username: String, fullname: String, profileImage: UIImage, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {}


}

class MockLoginUseCase: LoginUseCaseProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {}
}

class MockProfileUseCase: ProfileUseCaseProtocol {
    func selectFetchTweets(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {

    }
    
    func fetchTweetLikes(uid: String, completion: @escaping ((Tweet?) -> Void)) {

    }
    
    func fetchReplies(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {

    }
}

class MockEditUseCase: EditUseCaseProtocol {
    func editProfileInfo(fullName: String, userName: String, bio: String, profileImageUrl: String?, currentUser: any UserModelProtocol, completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }

    func editProfile(profileImage: UIImage?, fullName: String?, userName: String?, bio: String?, profileImageUrl: String?, currentUser: any UserModelProtocol, completion: @escaping ((Result<String?, any Error>) -> Void)) {

    }
   
    
    func saveUserData(fullName: String, userName: String, bio: String, profileImageUrl: String?, completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    

    

}

// MARK: - Mock Repositories

class MockTweetRepository: TweetRepositoryProtocol {
    func fetchReplies(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {

    }
    
    func fetchTweetLikes(uid: String, completion: @escaping ((Tweet?) -> Void)) {

    }
    
    func fetchTweet(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        
    }
    
    func likesStatus(tweet: any TweetModelProtocol, completion: @escaping (Bool) -> Void) {}
    
    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void) {}
    func fetchTweetReplies(tweetId: String, completion: @escaping ([Tweet]) -> Void) {}
    func fetchTweetReplies(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {}
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {}
    func selectFetchTweet(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {}
    func fetchAllTweets(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {}
}

class MockUserRepository: UserRepositoryProtocol {
    func fetchUser(username: String, completion: @escaping (Result<any UserModelProtocol, UserServiceError>) -> Void) {

    }

    
    func saveUserData(fullName: String, userName: String, bio: String, completion: @escaping ((Result<Void, any Error>) -> Void)) {
        
    }

    
    func updateProfileImage(image: UIImage, completion: @escaping ((Result<String, any Error>) -> Void)) {
        
    }
    
    func fetchSelectedUser(uid: String, completion: @escaping (Result<User, UserServiceError>) -> Void) {}
    
    func getFollowCount(uid: String, completion: @escaping (Int, Int) -> Void) {}
    func follow(uid: String, completion: @escaping () -> Void) {}
    func unfollow(uid: String, completion: @escaping () -> Void) {}
    func checkFollowStatus(uid: String, completion: @escaping (Bool) -> Void) {}
    func fetchUser(completion: @escaping (Result<User, UserServiceError>) -> Void) {}
    func fetchAllUserList(completion: @escaping (Result<User, UserServiceError>) -> Void) {}
}

class MockAuthRepository: AuthRepositoryProtocol {
    func signUp(email: String, password: String, username: String, fullname: String, profileImage: UIImage, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {}

    func createUser(email: String, password: String, profileImage: UIImage, username: String, fullname: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {}
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {}
    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void) {}
}

class MockNotificationRepository: NotificationRepositoryProtocol {
    func fetchNotifications(completion: @escaping (Result<[Notification], NotificationServiceError>) -> Void) {}


}

class MockNotificationUseCase: NotificationUseCaseProtocol {
    func fetchNotifications(completion: @escaping (Result<[NotificationItem], NotificationServiceError>) -> Void) {}
    func fetchNotifications(completion: @escaping (Result<[Notification], NotificationServiceError>) -> Void){}
    

}

// MARK: - Mock Services

class MockAuthService: AuthService {}
class MockUserService: UserService {}
class MockTweetService: TweetService {}
class mockNotificationServce: NotificationService {}

// MARK: - Mock DIContainer

final class MockDiContainer: AppDIContainerProtocol {
    func makeUploadTweetRouter() -> any UploadTweetRouterProtocol {
        MockUploadTweetRouter()
    }
    
    func makeMainTabBarRouter() -> any MainTabBarRouterProtocol {
        MockMainTabRouter()
    }
    
    func makeEditUseCase() -> any EditUseCaseProtocol {
        MockEditUseCase()
    }
    
    func makeAuthRouter() -> any AuthRouterProtocol {
        MockAuthRouter()
    }
    
    func makeFeedRouter() -> any FeedRouterProtocol {
        MockFeedRouter()
    }
    
    func makeExplorerRouter() -> any ExplorerRouterProtocol {
        MockExplorerRouter()
    }
    
    func makeTweetRouter() -> any TweetRouterProtocol {
        MockTweetRouter()
    }
    
    func makeProfileUseCase() -> ProfileUseCaseProtocol {
        MockProfileUseCase()
    }


    

    

    func makeAuthService() -> AuthService { AuthService.shared }
    func makeUserService() -> UserService { MockUserService() }
    func makeTweetService() -> TweetService { MockTweetService() }
    func makeNotificationService() -> NotificationService { mockNotificationServce()}


    func makeAuthRepository() -> AuthRepositoryProtocol { MockAuthRepository() }
    func makeUserRepository() -> UserRepositoryProtocol { MockUserRepository() }
    func makeTweetRepository() -> TweetRepositoryProtocol { MockTweetRepository() }
    func makeNotificationRepository() -> NotificationRepositoryProtocol { MockNotificationRepository() }


    func makeSignUpUseCase() -> SignUpUseCaseProtocol { MockSignUpUseCase() }
    func makeLoginUseCase() -> LoginUseCaseProtocol { MockLoginUseCase() }
    func makeLogoutUseCase() -> LogoutUseCaseProtocol { MockLogoutUseCase() }
    func makeUploadTweetUseCase() -> UploadTweetUseCaseProtocol { MockUploadTweetUseCase() }
    func makeFollowUseCase() -> FollowUseCaseProtocol { MockFollowUseCase() }
    func makeFetchTweetWithRepliesUseCase() -> FetchTweetWithRepliesUseCaseProtocol { MockFetchTweetWithRepliesUseCase() }
    func makeTweetLikeUseCase() -> TweetLikeUseCaseProtocol { MockTweetLikeUseCase() }
    func makeNotificationUseCase() ->  NotificationUseCaseProtocol { MockNotificationUseCase()}

    
}
