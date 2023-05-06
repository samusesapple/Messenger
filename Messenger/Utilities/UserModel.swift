//
//  UserModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/06.
//

import Foundation

struct User {
    let name: String
    let emailAddress: String
//    let profilePictureURL: String
    
    var safeEmail: String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
}
