//
//  PhotoViewerViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit

class PhotoViewerViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel: PhotoViewerViewModel?
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Lifecycle
    
    init(url: URL) {
        self.viewModel = PhotoViewerViewModel(url: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "이미지"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .white
        view.addSubview(imageView)
        viewModel?.setImageWithURL(imageView: imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    // MARK: - Helpers
    
}
