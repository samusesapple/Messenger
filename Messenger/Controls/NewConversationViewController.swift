//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit
import JGProgressHUD

protocol NewConversationViewControllerDelegate: AnyObject {
    func needToSetNewConversation(with newUser: User, controller: NewConversationViewController)
}

class NewConversationViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = NewConversationViewModel()
    weak var delegate: NewConversationViewControllerDelegate?
    
    private let progressHUD = JGProgressHUD(style: .dark)

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "유저를 검색하세요."
        return sb
    }()
    
    private let tableView: UITableView = {
       let tv = UITableView()
        tv.isHidden = true
        tv.register(NewConversationUserTableViewCell.self, forCellReuseIdentifier: NewConversationUserTableViewCell.identifier)
        return tv
    }()
    
    private let emptyResultsLabel: UILabel = {
       let label = UILabel()
        label.isHidden = true
        label.text = "검색 결과 없음"
        label.textAlignment = .center
        label.textColor = .blue
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
        return viewModel.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationUserTableViewCell.identifier, for: indexPath) as! NewConversationUserTableViewCell
        cell.viewModel = NewConversationCellViewModel(name: viewModel.results[indexPath.row].name,
                                                      email: viewModel.results[indexPath.row].emailAddress)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 선택된 유저와 대화 시작해야함
        let targetUserData = viewModel.results[indexPath.row]
        delegate?.needToSetNewConversation(with: targetUserData, controller: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

// MARK: - UISearchBarDelegate

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: " ").isEmpty else { return }
        viewModel.results = []
        progressHUD.show(in: view)
        viewModel.searchUsers(with: text) { [weak self] in
            self?.progressHUD.dismiss()
            self?.updateUI()
        }
    }

    func updateUI() {
        if viewModel.results.isEmpty {
            self.emptyResultsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.emptyResultsLabel.isHidden = true
            self.tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
}
