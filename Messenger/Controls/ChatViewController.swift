//
//  ChatViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/07.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {

    // MARK: - Properties
    
    private var messages = [Message]()
    
    private let sender = Sender(photoURL: "",
                                    senderId: "1",
                                    displayName: "접속한 유저")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(sender: sender,
                                messageId: "하나",
                                sentDate: Date(),
                                kind: .text("Hello World")))
        
        messages.append(Message(sender: sender,
                                messageId: "둘",
                                sentDate: Date(),
                                kind: .text("Hello World222222")))
        
        view.backgroundColor = .brown
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    // MARK: - Helpers
    

}
// MARK: - Extensions

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
