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



// MARK: - UISearchBarDelegate

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 대화할 유저 검색
    }
}
