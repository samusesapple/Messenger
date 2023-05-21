//
//  LoginViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel = AuthViewModel()
    private var loginObserver: NSObjectProtocol?
    private let progressHUD = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "logo")
        iv.contentMode = .scaleAspectFit
        return iv
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
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        stack.axis = .vertical
        stack.spacing = 15
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let loginButton: UIButton = {
        let button = AuthButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let facebookLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "facebook")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.addTarget(self, action: #selector(handleFacebookLogin), for: .touchUpInside)
        return button
    }()
    
    private let googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "google")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "apple")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var socialButtonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [facebookLoginButton, googleLoginButton, appleLoginButton])
        stack.spacing = 35
        stack.distribution = .fillProportionally
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "로그인"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "회원가입",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(handleRegisterButton))
        viewModel.loginSucceed = { [weak self] in
            self?.progressHUD.dismiss()
            self?.dismiss(animated: true)
        }
        configureUI()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: - Actions
    
    @objc func handleRegisterButton() {
        let registerVC = RegisterViewController()
        registerVC.title = "회원가입"
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc func handleFacebookLogin() {
        progressHUD.show(in: view)
        viewModel.handleFBLogin(controller: self)
    }
    
    @objc func handleGoogleLogin() {
        progressHUD.show(in: view)
        viewModel.handleGoogleLogin(controller: self)
    }
    
    @objc func handleAppleLogin() {
        requestAppleLogin()
    }
    
    @objc func loginButtonTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            presentLoginErrorAlert(error: "정보를 모두 입력해주세요.")
            return
        }
        progressHUD.show(in: view, animated: true)
        // Firebase login
        viewModel.handleUserLogin(email: email, password: password) { [weak self] success in
            if !success {
                self?.progressHUD.dismiss()
                self?.presentLoginErrorAlert(error: "잘못된 정보 입니다.")
            } else {
                self?.progressHUD.dismiss()
                self?.navigationController?.dismiss(animated: true)
            }
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
        stackView.setDimensions(height: 110, width: view.frame.width - 100)
        stackView.anchor(top: imageView.bottomAnchor, paddingTop: 60)
        
        scrollView.addSubview(loginButton)
        loginButton.centerX(inView: scrollView)
        loginButton.anchor(top: stackView.bottomAnchor, paddingTop: 20)
        loginButton.setDimensions(height: 50, width: view.frame.width - 100)
        
        scrollView.addSubview(socialButtonStackView)
        socialButtonStackView.centerX(inView: scrollView)
        socialButtonStackView.anchor(top: loginButton.bottomAnchor, paddingTop: 30)
    }
    
    func presentLoginErrorAlert(error message: String) {
        let alert = UIAlertController(title: message,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            loginButtonTapped()
        }
        return true
    }
    
}

// MARK: - ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate {
    // 성공한 경우 동작하는 코드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        guard let email = appleCredential.email,
              let userName = appleCredential.fullName?.givenName
//              let uid = appleCredentia
        else {
            return
        }
        let credential = authorization.credential as! AuthCredential
        
//        let loggingUser = User(name: userName, emailAddress: email)
    }
    
    
    // 실패한 경우 동작하는 코드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        print("애플 로그인 실패")
    }
    
    func requestAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let appleAuthController = ASAuthorizationController(authorizationRequests: [request])
        appleAuthController.delegate = self
        appleAuthController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        appleAuthController.performRequests()
    }
    
}
