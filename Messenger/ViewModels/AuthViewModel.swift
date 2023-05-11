//
//  LoginViewModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/08.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class AuthViewModel {
    
    func registerUser(credentials: AuthCredentials, completion: @escaping () -> Void) {
        FirestoreManager.registerUser(userInfo: credentials) { error in
            guard error == nil else { return }
            UserDefaults.standard.set(credentials.email, forKey: "email")
            completion()
        }
    }
    
    func handleUserLogin(email: String, password: String, completion: @escaping () -> Void) {
        FirestoreManager.logUserIn(withEmail: email, password: password) { result, error in
            guard error == nil else { return }
            UserDefaults.standard.set(email, forKey: "email")
            completion()
        }
    }
    
    func handleFBLogin(controller: UIViewController, completion: @escaping () -> Void) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: controller) { (result, error) -> Void in
            guard let result = result, error == nil else { return }
            if result.isCancelled {
                print("로그인 취소")
                return
            }
            if result.grantedPermissions.contains("email") {
                guard let token = result.token?.tokenString as? String else { return }
                FirestoreManager.handleFBLogin(token: token) { email in
                    UserDefaults.standard.set(email, forKey: "email")
                    completion()
                }
            }
        }
    }
    
    func handleGoogleLogin(controller: UIViewController, completion: @escaping () -> Void) {
        let clientID = FirebaseApp.app()?.options.clientID
        let config = GIDConfiguration(clientID: clientID!)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { [weak self] result, error in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            FirestoreManager.handleGoogleLogin(result: result) { email in
                UserDefaults.standard.set(email, forKey: "email")
                completion()
            }
        }
    }
}
