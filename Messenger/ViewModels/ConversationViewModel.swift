//
//  ConversationViewModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/13.
//

import Foundation
import FirebaseAuth

class ConversationViewModel {
    
    var conversation = [Conversation]()
    
    /// 로그인 된 경우 true, 로그인 안 된 경우 false
    var userLoginStatus: Bool {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            return false
        } else {
            return true
        }
    }
    
    func startListeningForConversations(completion: @escaping () -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = ChatDatabaseManager.shared.safeEmail(email: email)
        ChatDatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] conversation in
            guard !conversation.isEmpty else { return }
            self?.conversation = conversation
            DispatchQueue.main.async {
                // reload tableview
                completion()
            }
        }
    }
}
