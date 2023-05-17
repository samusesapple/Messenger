//
//  ViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

protocol ConversationViewControllerDelegate: AnyObject {
    func needToReloadChatCollectionView()
}
class ConversationViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel = ConversationViewModel()
    private var delegate: ConversationViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.isHidden = true
        tv.register(ConversationTableViewCell.self,
                    forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return tv
    }()
    
    private let noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "대화 없음"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let progressIndicator = JGProgressHUD(style: .dark)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTappedPlusButton))
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        setTableView()
        fetchConversatons()
        viewModel.startListeningForConversations { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !viewModel.userLoginStatus {
            let loginVC = LoginViewController()
            let naviVC = UINavigationController(rootViewController: loginVC)
            naviVC.modalPresentationStyle = .fullScreen
            present(naviVC, animated: false)
        }
    }
    
    // MARK: - Actions
    
    @objc func didTappedPlusButton() {
        let newConverationVC = NewConversationViewController()
        newConverationVC.delegate = self
        let naviVC = UINavigationController(rootViewController: newConverationVC)
        present(naviVC, animated: true)
    }
    
    // MARK: - Helpers
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setDimensions(height: view.frame.height, width: view.frame.width)
    }
    
    private func fetchConversatons() {
        tableView.isHidden = false
    }
    
    private func presentChatVC(isNewConversation: Bool, conversationId: String?, email userEmail: String, name userName: String) {
        let safeEmail = ChatDatabaseManager.shared.safeEmail(email: userEmail)
        let chatVC = ChatViewController(viewModel: ChatViewModel(isNewConversation: isNewConversation,
                                                                 conversationId: conversationId,
                                                                 otherUserEmail: safeEmail,
                                                                 otherUserName: userName))
        chatVC.delegate = self
        chatVC.title = userName
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configureUI(with: viewModel.conversation[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentChatVC(isNewConversation: false,
                      conversationId: viewModel.conversation[indexPath.row].id,
                      email: viewModel.conversation[indexPath.row].otherUserEmail,
                      name: viewModel.conversation[indexPath.row].name)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - NewConversationViewControllerDelegate

extension ConversationViewController: NewConversationViewControllerDelegate {
    func needToSetNewConversation(with newUser: User, controller: NewConversationViewController) {
        controller.dismiss(animated: true)
        presentChatVC(isNewConversation: true,
                      conversationId: nil,
                      email: newUser.emailAddress,
                      name: newUser.name)
    }
}

// MARK: - ChatViewControllerDelegate
extension ConversationViewController: ChatViewControllerDelegate {
    
    func needToUpdateCoversationList() {
        viewModel.startListeningForConversations { [weak self] in
            self?.tableView.reloadData()
            print("ConversationVC - reloadData 완료")
        }
    }
    
}
