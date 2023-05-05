//
//  AuthButton.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit

final class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .link
        tintColor = .white
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
