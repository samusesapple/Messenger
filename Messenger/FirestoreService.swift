//
//  Service.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/13.
//

import Foundation
import Firebase

struct FirestoreService {
    
// MARK: - [READ]
    ///  Firestore - current user를 제외한 모든 유저 정보 불러오기
    static func fetchWholeUsers(completion: @escaping ([User]) -> Void) {
        var users = [User]()
        let currentUserUID = Auth.auth().currentUser?.uid
        COLLECTION_USERS.getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot, error == nil else { return }
            let filteredDocuments = querySnapshot.documents.filter { $0.documentID != currentUserUID }
            filteredDocuments.forEach { document in
                let dataDic = document.data()
                let user = User(dictionary: dataDic)
                users.append(user)
            }
            completion(users)
        }
    }
    
    
    
    
}
