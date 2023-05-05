//
//  UIImageView+Extensions.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit

extension UIImageView {
    
    func makeRounded() {
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}
