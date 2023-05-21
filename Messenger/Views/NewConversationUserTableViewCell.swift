//
//  NewConversationUserCell.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/18.
//

import UIKit

class NewConversationUserTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "NewConversationUserTableViewCell"
    var viewModel: NewConversationCellViewModel? {
        didSet {
            configureUI()
        }
    }
    
    private let userImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 70 / 2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [userImageView, userNameLabel].forEach { view in
            contentView.addSubview(view)
        }
        setAutolayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        userImageView.setDimensions(height: 70, width: 70)
        userImageView.centerY(inView: contentView)
        userImageView.anchor(left: contentView.leftAnchor, paddingLeft: 10)
        
        userNameLabel.anchor(left: userImageView.rightAnchor, paddingLeft: 10)
        userNameLabel.centerY(inView: contentView)
        userNameLabel.setDimensions(height: (contentView.frame.height) / 2, width: contentView.frame.width - 20 - userImageView.frame.width)
    }
    
    private func configureUI() {
        guard let viewModel = viewModel else { return }
        userNameLabel.text = viewModel.name
        let safeEmail = ChatDatabaseManager.shared.safeEmail(email: viewModel.email)
        let path = "images/\(safeEmail)_profile_picture.png"
        print(path)
        StorageManager.shared.downloadURL(for: path) { [weak self] url in
            DispatchQueue.main.async {
                self?.userImageView.sd_setImage(with: url)
            }
        }
    }
    
}

