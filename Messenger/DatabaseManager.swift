//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/06.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private init() { }
    
}

// MARK: - Account Management
extension DatabaseManager {
    /// check if user email already exists
    func checkIfUserExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                // 존재하지 않는 이메일
                completion(false)
                return
            }
            // 이미 존재하는 이메일
            completion(true)
        }
    }
    
    /// Inserts new user to Realtime Database
    func createUser(with user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue(["name": user.name,
                                                 "email": user.emailAddress]) { error, ref in
            guard error == nil else {
                print("유저 데이터 firebase에 올리기 실패")
                completion(false)
                return
            }
        }
        print("회원가입 완료 - \(user.name)")
        completion(true)
    }
}

