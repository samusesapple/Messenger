//
//  ChatViewModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/13.
//

import UIKit
import SDWebImage

class ChatViewModel {
    
    var messages = [Message]()
    
    var sender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "userName") as? String else { return nil }
        let safeEmail = ChatDatabaseManager.shared.safeEmail(email: email)
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: currentUserName)
    }
    
    /// 새로운 채팅인 경우 true, 이미 존재하는 채팅인 경우 false
    var isNewConversation: Bool = false
    
    var otherUserName: String
    var otherUserEmail: String
    
    private let conversationId: String?
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    init(isNewConversation: Bool, conversationId: String?, otherUserEmail: String, otherUserName: String) {
        self.isNewConversation = isNewConversation
        self.otherUserEmail = otherUserEmail
        self.otherUserName = otherUserName
        self.conversationId = conversationId
    }
    
    /// 기존에 존재하지 않는 새로운 대화 생성
    func createNewConversation(text: String, completion: @escaping () -> Void) {
        guard let sender = sender, let messageId = createMessageID() else { return }
        let message = Message(sender: sender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        ChatDatabaseManager.shared.createNewConversation(with: otherUserEmail,
                                                         otherUserName: otherUserName,
                                                         firstMessage: message) { [weak self] success in
            guard success else { print("새로운 대화 생성 실패"); return }
            self?.isNewConversation = false
            completion()
        }
    }
    
    /// 기존에 존재하는 대화에 새로운 메세지 보내기
    func sendMessage(text: String, completion: @escaping () -> Void) {
        guard let sender = sender,
              let messageId = createMessageID(),
              let conversationId = conversationId else { return }
        let message = Message(sender: sender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        ChatDatabaseManager.shared.sendMessage(id: conversationId,
                                               reciptientEmail: otherUserEmail,
                                               recipientName: otherUserName,
                                               newMessage: message) { [weak self] success in
            guard success else { print("기존 대화에 메세지 추가하기 실패"); return }
            completion()
        }
    }
    
    private func createMessageID() -> String? {
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
        let safeCurrentUserEmail: String = ChatDatabaseManager.shared.safeEmail(email: currentUserEmail)
        let newIdentifier = "\(otherUserName)_\(safeCurrentUserEmail)_\(dateString)"
        print("IDENTIFIER : \(newIdentifier)")
        return newIdentifier
    }
    
    func listenForMessages(completion: @escaping () -> Void) {
        guard let conversationId = self.conversationId else { return }
        ChatDatabaseManager.shared.getAllMessagesForConversation(with: conversationId) { [weak self] messages in
            guard !messages.isEmpty, self?.conversationId != nil else { return }
            self?.messages = messages
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    /// Database에 이미지 업로드 및 메세지에 이미지 첨부하여 보내기
    func uploadAndSendImageData(data: Data, completion: @escaping () -> Void) {
        guard let messageId = createMessageID(),
        let conversationId = conversationId,
        let sender = sender else { print("옵셔널 벗기기 실패"); return }
        let imageMessageId = messageId.replacingOccurrences(of: "/", with: "-")
        let safeImageMessageId = imageMessageId.replacingOccurrences(of: " ", with: "_") + ".png"
        let fileName = "photo_message_" + safeImageMessageId
        
        StorageManager.shared.uploadMessagePhoto(with: data,
                                                 fileName: fileName) { [weak self] result in
            switch result {
            case .success(let urlString):
                print("메세지에 사진 첨부해서 보내기 url: \(urlString)")
                guard let url = URL(string: urlString),
                      let placeholder = UIImage(systemName: "photo") else { return }
                let media = Media(url: url,
                                  image: nil,
                                  placeholderImage: placeholder,
                                  size: .zero)
                let message = Message(sender: sender,
                                      messageId: messageId,
                                      sentDate: Date(),
                                      kind: .photo(media))
                
                ChatDatabaseManager.shared.sendMessage(id: conversationId,
                                                       reciptientEmail: self!.otherUserEmail,
                                                       recipientName: self!.otherUserName,
                                                       newMessage: message) { success in
                    if success {
                        completion()
                    } else {
                        print("이미지 데이터 업로드 후, 메세지로 보내기 실패")
                    }
                }
                // 메세지 보내기
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func needToDownloadImage(at imageView: UIImageView, with url: URL) {
        imageView.sd_setImage(with: url)
    }
    
}
