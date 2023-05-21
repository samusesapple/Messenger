//
//  ChatViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/07.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVFoundation
import AVKit

protocol ChatViewControllerDelegate: AnyObject {
    func needToUpdateCoversationList()
}
class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    private var viewModel: ChatViewModel?
    
    weak var delegate: ChatViewControllerDelegate?
    
    // MARK: - Lifecycle
    init(viewModel: ChatViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        print("메세지 세팅 ㅇㅋ")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        setupInputButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        viewModel?.listenForMessages(completion: { [weak self] in
            self?.messagesCollectionView.reloadDataAndKeepOffset()
            self?.messagesCollectionView.scrollToLastItem()
        })
        
    }
    
    
    // MARK: - Actions
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "사진",
                                            style: .default,
                                            handler: { [weak self] action in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "동영상",
                                            style: .default,
                                            handler: { [weak self] action in
            self?.presentVideoInputActionSheet()
            print("동영상")
        }))
        actionSheet.addAction(UIAlertAction(title: "음성",
                                            style: .default,
                                            handler: { [weak self] action in
            print("음성")
        }))
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "사진",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "카메라",
                                            style: .default,
                                            handler: { [weak self] action in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "앨범",
                                            style: .default,
                                            handler: { [weak self] action in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "동영상",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "카메라",
                                            style: .default,
                                            handler: { [weak self] action in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "앨범",
                                            style: .default,
                                            handler: { [weak self] action in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - Helpers
    
    private func setupInputButton() {
        let button = InputBarButtonItem(type: .system)
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.onTouchUpInside { [weak self] button in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func handleUIAfterMessageSent() {
        delegate?.needToUpdateCoversationList()
        messageInputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
    }
    
}
// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        guard let sender = viewModel?.sender else {
            fatalError("CURRENT SENDER is NIL, EMAIL SHOULD BE CACHED")
        }
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        guard let message = viewModel?.messages else { return MessageKit.MessageType.self as! MessageType }
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return viewModel?.messages.count ?? 0
    }
}

extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = viewModel?.messages[indexPath.section] else { return }
        
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else { return }
            let photoVC = PhotoViewerViewController(url: imageURL)
            self.navigationController?.pushViewController(photoVC, animated: true)
        case .video(let media):
            guard let videoURL = media.url else { return }
            // AVFoundation, AVkit을 사용하여 비디오 재생하는 VC 생성
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            vc.player?.play()
            present(vc, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        inputBar.inputTextView.text = nil
        // 메세지 보내져야함
        if viewModel!.isNewConversation {
            // 새로운 대화 시작해야함
            viewModel?.createNewConversation(text: text, completion: { [weak self] in
                // 새로운 대화 시작하면 메세지 바로 안뜨는 버그 해결 필요
                print("새로운 대화방 추가")
            })
        } else {
            // 이미 존재하는 대화에 새로운 메세지 데이터 append
            viewModel?.sendMessage(text: text, completion: { [weak self] in
                print("기존 대화에 새로운 메세지 추가")
            })
        }
    }
}

// MARK: - UIPickerViewDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        // Firestore에 이미지 업로드 + 이미지 메세지 보내기
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            viewModel?.uploadAndSendImageData(data: imageData) {
                print("imagePickerController - upload and send ImageData 성공")
            }
        } else if let videoURL = info[.mediaURL] as? URL {
            // 동영상 업로드
            viewModel?.uploadAndSendVideoData(videoURL: videoURL, completion: {
                print("imagePickerController - uploadAndSendVideoData 성공")
            })
        }

    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else { return }
            viewModel?.needToDownloadImage(at: imageView, with: imageURL)
        default:
            break
        }
    }
}

