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
    
    static func safeEmail(email: String) -> String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    
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
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    let newUser: [String: String] = ["name": user.name, "email": user.safeEmail]
                    usersCollection.append(newUser)
                    self.database.child("users").setValue(usersCollection) { error, reference in
                        guard error == nil else { return }
                    }
                    completion(true)
                } else {
                    // 유저 목록 담을 컬렉션 만들기
                    let newUserCollection: [[String: String]] = [
                        ["name": user.name, "email": user.safeEmail]
                    ]
                    self.database.child("users").setValue(newUserCollection) { error, reference in
                        guard error == nil else { return }
                    }
                    completion(true)
                    print("회원가입 완료 - \(user.name)")
                }
            }

        }
    }
    
    func getAllUsersFromFirebase(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else { return }
            completion(.success(value))
        }
    }
}

