//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    // MARK: - Properties
    
    private var users = [[String: String]]()
    
    private var results = [[String: String]]()
    
    private var hasFetched = false
    
    private let progressHUD = JGProgressHUD(style: .dark)

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "유저를 검색하세요."
        return sb
    }()
    
    private let tableView: UITableView = {
       let tv = UITableView()
        tv.isHidden = true
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private let emptyResultsLabel: UILabel = {
       let label = UILabel()
        label.text = "검색 결과 없음"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .bold)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(emptyResultsLabel)
        emptyResultsLabel.centerInSuperview()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setDimensions(height: view.frame.height, width: view.frame.width)
        
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissViewController))
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
    
}

// MARK: - UITableViewDelegate
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        cell.tintColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - UISearchBarDelegate

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: " ").isEmpty else { return }
        results.removeAll()
        progressHUD.show(in: view)
//        self.searchUsers(with: text)
    }
    
//    func searchUsers(with text: String) {
//        // firebase에 결과 있는지 검색
//        if hasFetched {
//            // 결과 있으면 - 결과 보여주기
//            filterUsers(with: text)
//        } else {
//            // 결과 없으면 - 결과없으면, 데이터 가져오고 결과없음 라벨 띄우기
//            DatabaseManager.shared.getAllUsersFromFirebase { [weak self] result in
//                switch result {
//                case .success(let usersCollection):
//                    self?.hasFetched = true
//                    self?.users = usersCollection
//                    self?.filterUsers(with: text)
//                case .failure(let error):
//                    print("유저 목록 가져오기 실패 \(error)")
//                }
//            }
//        }
//
//    }
    func filterUsers(with text: String) {
        guard hasFetched else {
            return
        }
        
        self.progressHUD.dismiss()
        
        var results: [[String: String]] = self.users.filter {
            guard let name = $0["name"]?.lowercased() else { return false }
            return name.hasPrefix(text.lowercased())
        }
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.emptyResultsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.emptyResultsLabel.isHidden = true
            self.tableView.isHidden = false
        }
    }
    
}
