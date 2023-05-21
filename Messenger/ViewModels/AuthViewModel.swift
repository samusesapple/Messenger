//
//  LoginViewModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/08.
//

import UIKit
import AuthenticationServices
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class AuthViewModel {
    
    /// 로그인 완료 후 실행, 클로저에 실행할 액션 정의 필요
    var loginSucceed: () -> Void = { }
    
    private func profilePictureFileName(email: String) -> String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return "\(safeEmail)_profile_picture.png"
    }
    
    func registerUser(imageView: UIImageView, credentials: AuthCredentials, completion: @escaping () -> Void) {
        let safeEmail = profilePictureFileName(email: credentials.email)
        AuthService.registerUser(userInfo: credentials) { error in
            guard let data = imageView.image?.pngData(), error == nil else { return }
            StorageManager.shared.uploadProfilePicture(
                with: data,
                fileName: safeEmail) { result in
                    switch result {
                    case .success(let downloadURL):
                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                    case .failure(let error):
                        print("유저 이미지 저장 실패")
                        print(error)
                    }
                }
            UserDefaults.standard.set(credentials.email, forKey: "email")
            UserDefaults.standard.set(credentials.fullName, forKey: "userName")
            completion()
        }
    }
    
    func handleUserLogin(email: String, password: String, completion: @escaping (Bool) -> Void) {
        AuthService.logUserIn(withEmail: email, password: password) { [weak self] result, error in
            guard error == nil else { completion(false); return }
            UserDefaults.standard.set(email, forKey: "email")
            completion(true)
            self?.loginSucceed()
        }
    }
    
    func handleFBLogin(controller: UIViewController) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: controller) { (result, error) -> Void in
            guard let result = result, error == nil else { return }
            if result.isCancelled {
                print("로그인 취소")
                return
            }
            if result.grantedPermissions.contains("email") {
                guard let token = result.token?.tokenString as? String else { return }
                AuthService.handleFBLogin(token: token) { [weak self] email, userName, urlString  in
                    // url로 이미지 파일 받아서 저장하기
                    guard let url = URL(string: urlString) else { return }
                    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                        guard let data = data,
                                let fileName = self?.profilePictureFileName(email: email),
                                error == nil else { return }
                        StorageManager.shared.uploadProfilePicture(with: data,
                                                                   fileName: fileName) { result in
                            switch result {
                            case .success(let downloadURL):
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                print(downloadURL)
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }.resume()
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(userName, forKey: "userName")
                    self?.loginSucceed()
                }
            }
        }
    }
    
    func handleGoogleLogin(controller: UIViewController) {
        let clientID = FirebaseApp.app()?.options.clientID
        let config = GIDConfiguration(clientID: clientID!)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { [weak self] result, error in
            guard let user = result?.user, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            if ((user.profile?.hasImage) != nil) {
                guard let url = user.profile?.imageURL(withDimension: 200),
                        let fileName = self?.profilePictureFileName(email: user.profile!.email)
                        else { return }
                
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                        switch result {
                        case .success(let downloadURL):
                            UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                            print(downloadURL)
                        case .failure(_):
                            print("GOOGLE - StorageManager 이미지 저장 실패")
                        }
                    }
                }.resume()
            }
            AuthService.handleGoogleLogin(result: result) { [weak self] email, userName in
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(userName, forKey: "userName")
                self?.loginSucceed()
            }
        }
    }
    
    func handleAppleLogin(controller: UIViewController) {
        func requestAppleLogin() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            let appleAuthController = ASAuthorizationController(authorizationRequests: [request])
            appleAuthController.delegate = controller as? any ASAuthorizationControllerDelegate
            appleAuthController.presentationContextProvider = controller as? ASAuthorizationControllerPresentationContextProviding
            appleAuthController.performRequests()
        }
    }
}
