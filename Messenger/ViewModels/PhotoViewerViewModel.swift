//
//  PhotoViewerViewModel.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/15.
//

import Foundation
import SDWebImage

struct PhotoViewerViewModel {
    var url: URL?
    
    init(url: URL) {
        self.url = url
    }
    
    func setImageWithURL(imageView: UIImageView) {
        DispatchQueue.main.async {
            imageView.sd_setImage(with: url)
        }
    }
    
}
