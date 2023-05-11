//
//  CoversationViewModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/08.
//

import Foundation
import GoogleSignIn
import FBSDKLoginKit
import Firebase

class ProfileViewModel {
    
    func logout(completion: @escaping () -> Void) {
        // fb logout
        FBSDKLoginKit.LoginManager().logOut()
        // google logout
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try FirebaseAuth.Auth.auth().signOut()
            // 로그인 화면 다시 띄우기
            completion()
        }
        catch {
            print("로그아웃 실패")
        }
    }
}
