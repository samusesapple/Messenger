//
//  ChatDatabaseManager.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/13.
//

import Foundation
import FirebaseDatabase
import MessageKit

final class ChatDatabaseManager {
    
    static let shared = ChatDatabaseManager()
    
    private let database = Database.database().reference()
    
    private init() { }
    
    public func safeEmail(email: String) -> String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
}

// MARK: - Data Management
extension ChatDatabaseManager {
    /// check if user email already exists
    public func checkIfUserExists(with email: String, completion: @escaping ((Bool) -> Void)) {
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
    public func createUser(with user: User) {
        database.child(user.safeEmail).setValue([
            "name": user.name,
            "email": user.safeEmail,
            "uid": user.uid
        ])
        print("회원가입 완료 - \(user.name)")
    }
    
    /// get Data from database
    public func getDataFor(path: String, completion: @escaping (Any) -> Void) {
        self.database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else { return }
            completion(value)
        }
    }
    
}

// MARK: - Sending Messages

extension ChatDatabaseManager {
    
    /// 상대 유저의 이메일과 함께 새로운 대화 생성하기
    public func createNewConversation(with otherUserEmail: String, otherUserName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "userName") as? String else { return }
        
        let safeEmail = ChatDatabaseManager.shared.safeEmail(email: currentEmail)
        let reference = database.child(safeEmail)
        reference.observeSingleEvent(of: .value) { [weak self] snapshot, _  in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("NO USER IN REALTIME DATABASE")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewModel.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String : Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "other_user_name": otherUserName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ] as [String : Any]
            ]
            
            let recipient_newConversation: [String : Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "other_user_name": currentUserName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ] as [String : Any]
            ]
            // 메세지 받는 유저의 대화 내용 데이터 업데이트
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // 이미 존재하는 대화방 : 새 메세지 append
                    conversations.append(recipient_newConversation)
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversation])
                } else {
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversation])
                }
            }
            // 접속 중인 유저의 대화 내용 데이터 업데이트
            if var conversations = userNode["conversation"] as? [[String: Any]] {
                // 이미 존재하는 대화방 : 새 메세지를 append
                conversations.append(newConversationData)
                reference.setValue(userNode) { [weak self] error, ref in
                    guard error == nil else {
                        print("기존 대화방에 새로운 대화 얹기 실패")
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(otherUserName: otherUserName,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)                }
            } else {
                // 대화 데이터 reference 미존재함, 새로 생성 필요
                userNode["conversations"] = [
                    newConversationData
                ]
                reference.setValue(userNode) { [weak self] error, ref in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(otherUserName: otherUserName,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                }
            }
        }
    }
    
    private func finishCreatingConversation(otherUserName: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool)-> Void) {
        let dateString = ChatViewModel.dateFormatter.string(from: firstMessage.sentDate)
        var sentMessage = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            sentMessage = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let safeCurrentUserEmail = ChatDatabaseManager.shared.safeEmail(email: currentUserEmail)
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": sentMessage,
            "date": dateString,
            "sender_email": safeCurrentUserEmail,
            "is_read": false,
            "recipient_name": otherUserName
        ]
        let value: [String: Any] = [
            "messages": [
                message
            ]
        ]
        database.child(conversationID).setValue(value) { error, reference in
            guard error == nil else {
                completion(false)
                return
            }
        }
    }
    
    /// 이메일에 해당되는 유저의 모든 대화 목록 불러오기 (접속한 유저의 모든 대화)
    public func getAllConversations(for email: String, completion: @escaping ([Conversation]) -> Void) {
        database.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else { print("채팅 목록 불러오기 오류"); return }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let otherUserName = dictionary["other_user_name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                print(otherUserEmail)
                return Conversation(id: conversationId,
                                    name: otherUserName,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            }
            completion(conversations)
        }
    }
    
    /// 해당 대화에 있는 채팅 내용 불러오기
    public func getAllMessagesForConversation(with id: String, completion: @escaping ([Message]) -> Void) {
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else { print("채팅 내용 가져오기 오류"); return }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["recipient_name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewModel.dateFormatter.date(from: dateString) else { return nil }
                
                var kind: MessageKind?
                
                if type == "photo" {
                    // photo
                    guard let imageURL = URL(string: content),
                          let placeholder = UIImage(systemName: "photo") else { return nil }
                    
                    let media = Media(url: imageURL,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 200, height: 200))
                    kind = .photo(media)
                } else if type == "video" {
                    guard let videoURL = URL(string: content),
                          let placeholder = UIImage(named: "videoThumbnail") else { return nil }
                    
                    let media = Media(url: videoURL,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 200, height: 200))
                    kind = .video(media)
                } else {
                    kind = .text(content)
                }
                guard let finalKind = kind else { return nil }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: finalKind)
            }
            completion(messages)
        }
    }
    
    /// conversation에 메세지 보내기 - 기존에 존재하는 메세지에 새로운 메세지 더하기, sender와 recipient의 latest message 업데이트,
    public func sendMessage(id conversationId: String, reciptientEmail: String, recipientName: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeCurrentUserEmail = safeEmail(email: currentUserEmail)
        let safeReciptientEmail = safeEmail(email: reciptientEmail)
        database.child("\(conversationId)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                print("최근 메세지 없음")
                completion(false)
                return
            }
            let messageDate = newMessage.sentDate
            let dateString = ChatViewModel.dateFormatter.string(from: messageDate)
            
            var sentMessage = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                sentMessage = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetURLString = mediaItem.url?.absoluteString {
                    sentMessage = targetURLString
                }
                break
            case .video(let mediaItem):
                if let targetURLString = mediaItem.url?.absoluteString {
                    sentMessage = targetURLString
                }
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let safeCurrentUserEmail = ChatDatabaseManager.shared.safeEmail(email: currentUserEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": sentMessage,
                "date": dateString,
                "sender_email": safeCurrentUserEmail,
                "is_read": false,
                "recipient_name": recipientName
            ]
            
            currentMessages.append(newMessageEntry)
            
            self?.database.child("\(conversationId)/messages").setValue(currentMessages,
                                                                        withCompletionBlock: { error, reference in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                self?.database.child("\(safeCurrentUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": sentMessage
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversationId {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else { return }
                    
                    currentUserConversations[position] = finalConversation
                    self?.database.child("\(safeCurrentUserEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else { print("ChatDatabaseManager - sendMessage : 최근 메세지 업데이트 하는 것 에러 발생"); return }
                        
                        // 메세지 받는 상대방의 최신 메세지도 업데이트하기
                        self?.database.child("\(safeReciptientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var receiverUserConversations = snapshot.value as? [[String: Any]] else {
                                print("최신 메세지 업데이트 하려고 데이터 받는데 실패")
                                completion(false)
                                return
                            }
                            
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": sentMessage
                            ]
                            
                            var targetConversation: [String: Any]?
                            var position = 0
                            
                            for conversationDictionary in receiverUserConversations {
                                if let currentId = conversationDictionary["id"] as? String, currentId == conversationId {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConversation = targetConversation else { return }
                            
                            receiverUserConversations[position] = finalConversation
                            self?.database.child("\(safeReciptientEmail)/conversations").setValue(receiverUserConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    print("ChatDatabaseManager - sendMessage : 최근 메세지 업데이트 하는 것 에러 발생")
                                    return
                                }
                                completion(true)
                                print("\(receiverUserConversations) :: 최신 메세지 목록 업데이트 완료")
                            })
                        })
                    })
                })
                
            })
        }
    }
    
}
