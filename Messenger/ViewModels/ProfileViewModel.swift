//
//  CoversationViewModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/08.
//

import Foundation
import GoogleSignIn
import FBSDKLoginKit
import SDWebImage
import Firebase

class ProfileViewModel {
    
    let data = ["로그아웃"]
    
    func setProfileImage(imageView: UIImageView) {
        guard let email = UserDefaults.standard.object(forKey: "email") as? String else { print("email없음"); return }
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        let path = "images/" + "\(safeEmail)_profile_picture.png"
        
        StorageManager.shared.downloadURL(for: path) { url in
            URLSession.shared.dataTask(with: url) { data, response, error in
                print("URLSESSSION")
                guard let data = data, error == nil else { print("문제"); return }
                guard let image = UIImage(data: data) else { print("이미지 다운 실패"); return }
                print("URLSession 시작")
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }.resume()
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        // fb logout
        FBSDKLoginKit.LoginManager().logOut()
        // google logout
        GIDSignIn.sharedInstance.signOut()
        do {
            try FirebaseAuth.Auth.auth().signOut()
            // 로그인 화면 다시 띄우기
            UserDefaults.standard.removeObject(forKey: "profile_picture_url")
            completion()
        }
        catch {
            print("로그아웃 실패")
        }
    }
}
