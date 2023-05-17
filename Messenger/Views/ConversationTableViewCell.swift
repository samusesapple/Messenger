//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/14.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [userImageView, userNameLabel, userMessageLabel].forEach { view in
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
    func setAutolayout() {
        userImageView.setDimensions(height: 100, width: 100)
        userImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 10, paddingLeft: 10)
        
        userNameLabel.anchor(top: contentView.topAnchor, left: userImageView.rightAnchor, paddingTop: 20, paddingLeft: 10)
        userNameLabel.setDimensions(height: (contentView.frame.height) / 2, width: contentView.frame.width - 20 - userImageView.frame.width)
        
        userMessageLabel.anchor(top: userNameLabel.bottomAnchor, left: userImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 20, paddingRight: 10)
    }
    
    func configureUI(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name
        let safeEmail = ChatDatabaseManager.shared.safeEmail(email: model.otherUserEmail)
        let path = "images/\(safeEmail)_profile_picture.png"
        print(path)
        StorageManager.shared.downloadURL(for: path) { [weak self] url in
            DispatchQueue.main.async {
                self?.userImageView.sd_setImage(with: url)
            }
        }
    }
    
}
