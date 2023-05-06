//
//  ViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoginStatus()
    }

    // MARK: - Helpers
    func checkLoginStatus() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            let naviVC = UINavigationController(rootViewController: loginVC)
            naviVC.modalPresentationStyle = .fullScreen
            present(naviVC, animated: false)
        }
    }
    
}

