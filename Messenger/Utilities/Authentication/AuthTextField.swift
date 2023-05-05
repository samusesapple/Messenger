//
//  AuthTextField.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit

final class AuthTextField: UITextField {

    init(text: String, isPassword: Bool = false) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white
        autocapitalizationType = .none
        autocorrectionType = .no
        returnKeyType = !isPassword ? .continue : .done
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        placeholder = text
        isSecureTextEntry = isPassword
        leftViewMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
