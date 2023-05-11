//
//  AuthService.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/11.
//

import Foundation
import Firebase
import FBSDKLoginKit
import GoogleSignIn

struct AuthCredentials {
    let email: String
    let fullName: String
    let password: String
}

typealias AuthDataResultCallback = (AuthDataResult?, Error?) -> Void

struct FirestoreManager {
    
    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(userInfo credentials: AuthCredentials, completion: @escaping ((Error?)) -> Void) {
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
            if let error = error {
                print("Error - RegisterUser : \(error.localizedDescription)")
                return
            }
            guard let userUID = result?.user.uid else { return }
            
            let data = ["email": credentials.email,
                        "fullName": credentials.fullName,
                        "uid": userUID]
            
            COLLECTION_USERS.document(userUID).setData(data, completion: completion)
        }
    }
    
    /// Facebook login
    static func handleFBLogin(token: String, completion: @escaping (String) -> Void) {
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name, picture"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        // 요청 시작
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any?], error == nil else {
                print("FB 그래프 요청 실패")
                return
            }
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String
            else {
                print("FB로부터 유저 정보 가져오기 실패")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
                guard let uid = result?.user.uid, error == nil else {
                    print("FB - CREDENTIAL LOGIN FAILLED")
                    print(error?.localizedDescription as Any)
                    return
                }
                
                let data = ["email": email,
                            "fullName": userName,
                            "uid": uid]
                // Firestore에 저장
                COLLECTION_USERS.document(uid).setData(data) { error in
                    guard error == nil else { return }
                    print("FB 로그인 성공")
                    completion(email)
                }
            }
        }
    }
    
    
    /// Google login
    static func handleGoogleLogin(result: GIDSignInResult?, completion: @escaping (String) -> Void) {
        guard let user = result?.user,
              let idToken = user.idToken?.tokenString
        else {
        // 토큰 오류
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)
        guard let email = user.profile?.email,
              let userName = user.profile?.name else { return }
        
        // 이미 존재하는 유저인지 확인
        let loggingUser = User(name: userName, emailAddress: email)
        // 유저 정보 저장 (completion block - 사진 firebase에 업로드)
        FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
            guard let uid = result?.user.uid, error == nil else {
                print("GOOGLE - credential error")
                return
            }
            let data = ["email": email,
                        "fullName": userName,
                        "uid": uid]

            // 유저 이메일 캐싱하기 및 firestore에 저장
            COLLECTION_USERS.document(uid).setData(data) { error in
                guard error == nil else { return }
                print("GOOGLE 로그인 성공")
                completion(email)
            }
        }
    }
    
    
}
