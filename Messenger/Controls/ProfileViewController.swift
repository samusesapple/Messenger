//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    private let data = ["로그아웃"]
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Helpers
    
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "로그아웃",
                                      style: .destructive) { [weak self] _ in
            // fb logout
            FBSDKLoginKit.LoginManager().logOut()
            // google logout
            GIDSignIn.sharedInstance.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                // 로그인 화면 다시 띄우기
                let loginVC = LoginViewController()
                let naviVC = UINavigationController(rootViewController: loginVC)
                naviVC.modalPresentationStyle = .fullScreen
                self?.present(naviVC, animated: true)
            }
            catch {
                print("로그아웃 실패")
            }
        })
        alert.addAction(UIAlertAction(title: "취소",
                                      style: .cancel))
        self.present(alert, animated: true)
    }
    
    
    
}
