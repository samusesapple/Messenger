//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel = AuthViewModel()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle")
        iv.tintColor = .gray
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameTextField: UITextField = {
        let tf = AuthTextField(text: "Enter your Name")
        return tf
    }()
    
    private let emailTextField: UITextField = {
        let tf = AuthTextField(text: "Enter Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = AuthTextField(text: "Enter Password", isPassword: true)
        return tf
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameTextField, emailTextField, passwordTextField])
        stack.axis = .vertical
        stack.spacing = 15
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let registerButton: UIButton = {
        let button = AuthButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = .systemGreen
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let progressHUD = JGProgressHUD(style: .dark)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureUI()
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfile))
        gesture.numberOfTouchesRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)
    }
    
    // MARK: - Actions
    
    @objc func didTapChangeProfile() {
        presentPhotoActionSheet()
    }
    
    @objc func registerButtonTapped() {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              !name.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            presentLoginErrorAlert(message: "정보를 모두 기입해주세요.")
            return
        }
        progressHUD.show(in: view)
        
        viewModel.registerUser(credentials: AuthCredentials(email: email,
                                                                   fullName: name,
                                                                   password: password)) {[weak self] in
            self?.navigationController?.dismiss(animated: true)
            self?.progressHUD.dismiss()
        }
        
    }
    
    
    
    // MARK: - Helpers
    
    func configureUI() {
        view.addSubview(scrollView)
        scrollView.setDimensions(height: view.frame.height, width: view.frame.width)
        scrollView.centerInSuperview()
        
        scrollView.addSubview(imageView)
        imageView.setDimensions(height: view.frame.width / 3, width: view.frame.width / 3)
        imageView.anchor(top: scrollView.topAnchor, paddingTop: 30)
        imageView.centerX(inView: scrollView)
        
        scrollView.addSubview(stackView)
        stackView.centerX(inView: scrollView)
        stackView.setDimensions(height: 170, width: view.frame.width - 100)
        stackView.anchor(top: imageView.bottomAnchor, paddingTop: 35)
        
        scrollView.addSubview(registerButton)
        registerButton.centerX(inView: scrollView)
        registerButton.anchor(top: stackView.bottomAnchor, paddingTop: 20)
        registerButton.setDimensions(height: 50, width: view.frame.width - 100)
    }
    
    func presentLoginErrorAlert(message: String) {
        let alert = UIAlertController(title: message,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        present(alert, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if nameTextField == passwordTextField {
            registerButtonTapped()
        }
        return true
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "프로필 사진 선택",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let presentCamera = UIAlertAction(title: "사진 촬영", style: .default) { [weak self] _ in
            self?.presentCamera()
        }
        let showLibrary = UIAlertAction(title: "앨범", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        }
        let cancel = UIAlertAction(title: "돌아가기", style: .cancel)
        
        actionSheet.addAction(presentCamera)
        actionSheet.addAction(showLibrary)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let pickerVC = UIImagePickerController()
        pickerVC.sourceType = .camera
        pickerVC.delegate = self
        pickerVC.allowsEditing = true  // 사진 정사각형 형태로 지정 가능하도록
        present(pickerVC, animated: true)
    }
    
    func presentPhotoPicker() {
        let pickerVC = UIImagePickerController()
        pickerVC.sourceType = .photoLibrary
        pickerVC.delegate = self
        pickerVC.allowsEditing = true
        present(pickerVC, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        DispatchQueue.main.async { [weak self] in
            self?.imageView.makeRounded()
            self?.imageView.image = selectedImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
