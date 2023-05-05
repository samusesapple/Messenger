//
//  ViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit

class ConversationViewController: UIViewController {
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_In")
        // 로그인 안되면 loginVC present
        if !isLoggedIn {
            let loginVC = LoginViewController()
            let naviVC = UINavigationController(rootViewController: loginVC)
            
            naviVC.modalPresentationStyle = .fullScreen
            present(naviVC, animated: false)
        }
    }


}

