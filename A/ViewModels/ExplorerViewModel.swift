//
//  ExplorerViewModel.swift
//  A
//
//

import UIKit

/// 유저 탐색(검색) 화면에 대한 뷰모델
/// - 전체 유저 불러오기, 검색어 바인딩, 유저 필터링 처리
final class ExplorerViewModel {

    // MARK: - Dependencies

    private let repository: UserRepositoryProtocol
    private let userViewModel: UserViewModel

    // MARK: - Initializer

    init(repository: UserRepositoryProtocol, userViewModel: UserViewModel) {
        self.repository = repository
        self.userViewModel = userViewModel
    }

    // MARK: - Data Sources

    /// 전체 유저 목록
    var userList = [User]() {
        didSet {
            onFetchUserSuccess?()
        }
    }

    /// 필터링된 유저 목록 (검색 결과)
    var filterUserList = [User]() {
        didSet {
            onFilterUserList?()
        }
    }

    /// 검색어 입력 시 트리거됨
    var searchText: String? {
        didSet {
            guard let searchText else { return }
            onSearchText?(searchText)
            filterUser()
            print(inSeaerchMode)
        }
    }

    /// 검색창 포커스 여부
    var isActive = false

    /// 현재 검색 중인지 여부
    var inSeaerchMode: Bool {
        return isActive && !(searchText?.isEmpty ?? true)
    }

    // MARK: - Cache

    /// 유저 리스트 캐싱 처리
    static var userListCache = NSCache<NSString, NSArray>()
    static var userListkey = "UserListKey" as NSString

    // MARK: - Binding Events

    var onFetchUserSuccess: (() -> Void)?
    var onFetchUserFail: ((Error) -> Void)?
    var onFilterUserList: (() -> Void)?
    var onSearchText: ((String) -> Void)?

    // MARK: - API Calls

    /// 전체 유저 불러오기 (캐시 사용 가능)
    func fetchUserList() {
        self.userList.removeAll()

        /*
        // ✅ 캐시된 데이터 사용 로직 (추후 필요시 주석 해제 가능)
        if let cacheUserList = ExplorerViewModel.userListCache.object(forKey: ExplorerViewModel.userListkey) as? [User], !cacheUserList.isEmpty {
            self.userList = cacheUserList
            print("🗂 캐시된 유저 사용: \(self.userList.count)명")
            return
        }
        */

        repository.fetchAllUserList { [weak self] result in
            guard let self else  { return }

            switch result {
            case .success(let user):
                self.configureUserList(user: user)
            case .failure(let error):
                self.onFetchUserFail?(error)
            }
        }
    }

    /// 유저 리스트 구성 및 캐시 설정
    private func configureUserList(user: User) {
        self.userList.append(user)
        /*
        if !userList.contains(where: {$0.uid == user.uid}) {
            self.userList.append(user)

        // ✅ 캐시 업데이트 로직 (필요시 주석 해제 가능)
        ExplorerViewModel.userListCache.setObject(self.userList as NSArray, forKey: ExplorerViewModel.userListkey)
        print("🗂 캐시 업데이트 완료: \(self.userList.count)명")
        */
    }

    // MARK: - User Update

    /// 유저 정보가 수정되었을 경우 ViewModel 갱신
    func updatedUser(user: UserModelProtocol) {
        self.userViewModel.updateUserViewModel(user: user)
    }

    // MARK: - Search

    /// 검색어 바인딩 처리
    func bindText(text: String) {
        searchText = text
    }

    /// 검색어 기반 필터 처리
    func filterUser() {
        guard let searchText = searchText?.lowercased(),
              !searchText.isEmpty else {
            filterUserList = []
            return
        }

        filterUserList = userList.filter {
            $0.userName.lowercased().contains(searchText) || $0.fullName.lowercased().contains(searchText)
        }

        print("🔎 검색 결과: \(filterUserList.count)명")
    }
}
