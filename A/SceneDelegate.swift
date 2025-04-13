//
//  SceneDelegate.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // MARK: - DI
        let di: AppDIContainerProtocol = AppDIContainer()

        // 중복 제거 - 필요한 의존성 한 번만 생성
        let userRepository = di.makeUserRepository()
        let explorerRouter = di.makeExplorerRouter()
        let logoutUseCase = di.makeLogoutUseCase()
        let tweetRepository = di.makeTweetRepository()
        let tweetLikeUseCase = di.makeTweetLikeUseCase()
        let loginUseCase = di.makeLoginUseCase()
        let uploadTweetUseCase = di.makeUploadTweetUseCase()
        let signUpUseCase = di.makeSignUpUseCase()
        let uploadTweetRouter = di.makeUploadTweetRouter()
        let followUseCase = di.makeFollowUseCase()
        let notificationUseCase = di.makeNotificationUseCase()

        // MARK: - Router 초기화
        let authRouter = AuthRouter(
            userRepository: userRepository,
            explorerRouter: explorerRouter,
            signUpUseCase: signUpUseCase,
            logoutUseCase: logoutUseCase,
            tweetReposiotry: tweetRepository,
            tweetLikeUseCase: tweetLikeUseCase,
            notificationUseCase: notificationUseCase
        )

        let mainTabRouter = MainTabRouter(loginUseCase: loginUseCase)
        let tweetRouter = TweetRouter(tweetRepository: tweetRepository, tweetLikeUseCase: tweetLikeUseCase, followUseCase: followUseCase)


        let feedRouter = FeedRouter(mainTabRouter: mainTabRouter, tweetRepository: tweetRepository, tweetRouter: tweetRouter, uploadTweetRouter: uploadTweetRouter, followUseCase: followUseCase, tweetLikeUseCase: tweetLikeUseCase)

        // Router 간 연결
        authRouter.injectMainTabRouter(mainTabRouter: mainTabRouter)
        authRouter.injectFeedRouter(feedRouter: feedRouter)

        mainTabRouter.setAuthRouter(authRouter: authRouter)
        mainTabRouter.setUploadTWeetRouter(uploadTweetRouter: uploadTweetRouter)

        // MARK: - Main VC 설정
        let mainTabVC = MainTabController(
            router: mainTabRouter,
            feedRouter: feedRouter,
            explorerRouter: explorerRouter,
            userRepository: userRepository,
            logoutUseCase: logoutUseCase,
            tweetRepository: tweetRepository,
            tweetLikeUseCase: tweetLikeUseCase, notificationUseCase: notificationUseCase
        )

        self.window?.rootViewController = mainTabVC
        self.window?.makeKeyAndVisible()
    }


    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

