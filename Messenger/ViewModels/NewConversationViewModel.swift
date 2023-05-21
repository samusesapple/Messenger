//
//  NewConversationViewModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/13.
//

import Foundation

class NewConversationViewModel {
    
   private var userArray = [User]()
    var hasFetched: Bool = false
    var results = [User]()
    
    init() {
        getUsers()
        hasFetched = false
    }
    
    private func getUsers() {
        var users: [User] = []
        FirestoreService.fetchWholeUsers { userArray in
            users = userArray
            self.userArray = users
        }
    }
    
    private func filterUsers(with text: String, completion: @escaping () -> Void) {
        guard hasFetched else {
            print("hasFetched : False")
            return
        }
        let results: [User] = userArray.filter { user in
            let name = user.name.lowercased()
            return name.hasPrefix(text.lowercased())
        }
        self.results = results
        completion()
    }
    
    
    func searchUsers(with text: String, completion: @escaping () -> Void) {
        print("hasFetched: \(hasFetched)")
        // firebase에 결과 있는지 검색
        if hasFetched {
            getUsers()
            // 결과 있으면 - 결과 보여주기
            filterUsers(with: text) {
                completion()
            }
        } else {
            // 결과 없으면 - 결과없으면, 데이터 가져오고 결과없음 라벨 띄우기
            getUsers()
            hasFetched = true
            filterUsers(with: text, completion: completion)
        }
    }
}
