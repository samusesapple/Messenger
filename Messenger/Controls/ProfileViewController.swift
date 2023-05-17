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
    
    private var viewModel = ProfileViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableHeaderView = createTableHeader()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let imageView = tableView.tableHeaderView?.subviews[0] as? UIImageView else { return }
        if UserDefaults.standard.value(forKey: "profile_picture_url") == nil {
            viewModel.setProfileImage(imageView: imageView)
        }
    }
    // MARK: - Helpers
    func createTableHeader() -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        headerView.backgroundColor = .blue
        
        let imageView = UIImageView()
        imageView.setDimensions(height: view.frame.width / 3, width: view.frame.width / 3)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        DispatchQueue.main.async {
            imageView.makeRounded()
        }
        headerView.addSubview(imageView)
        imageView.centerInSuperview()
        
        viewModel.setProfileImage(imageView: imageView)
        
        return headerView
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.data[indexPath.row]
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
            self?.viewModel.logout {
                DispatchQueue.main.async {
                    guard let profileView = tableView.tableHeaderView?.subviews[0] as? UIImageView else { return }
                    profileView.image = nil
                }
                let loginVC = LoginViewController()
                let naviVC = UINavigationController(rootViewController: loginVC)
                naviVC.modalPresentationStyle = .fullScreen
                self?.present(naviVC, animated: true)
            }
        })
        alert.addAction(UIAlertAction(title: "취소",
                                      style: .cancel))
        present(alert, animated: true)
    }
    
    
    
}
