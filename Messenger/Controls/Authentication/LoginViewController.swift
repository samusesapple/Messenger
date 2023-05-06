//
//  LoginViewController.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/05.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
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
        //        let button = FBLoginButton(type: .custom)
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
    
    private lazy var socialButtonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [facebookLoginButton, googleLoginButton])
        stack.spacing = 30
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
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) -> Void in
            guard let result = result, error == nil else { return }
            // if user cancel the login
            if result.isCancelled {
                print("로그인 취소")
                return
            }
            if result.grantedPermissions.contains("email")
            {
                self.getFBUserData()
            }
        }
    }
    
    @objc func handleGoogleLogin() {
        print(#function)
    }
    
    @objc func loginButtonTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            presentLoginErrorAlert()
            return
        }
        
        // Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let result = result, error == nil else {
                print(error?.localizedDescription)
                return
            }
            let user = result.user
            print("로그인 성공 - \(user)")
            self?.navigationController?.dismiss(animated: true)
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
    
    func presentLoginErrorAlert() {
        let alert = UIAlertController(title: "정보를 모두 기입해주세요.",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        present(alert, animated: true)
    }
    
    func getFBUserData() {
        guard let token = AccessToken.current?.tokenString as? String else { return }
        // 토큰 사용해서 FB에 있는 유저 데이터 요청 만들기 (email, name)
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        // 요청 시작
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any?], error == nil else {
                print("FB 그래프 요청 실패")
                return
            }
            // 성공시, 이름과 이메일 String 형태로 받기
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("FB로부터 유저 정보 가져오기 실패")
                return
            }
            // Firebase에 FB로그인 한 유저 정보 없으면 저장
            DatabaseManager.shared.checkIfUserExists(with: email) { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: User(name: userName,
                                                                 emailAddress: email))
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] result, error in
                guard result != nil, error == nil else {
                    print("FB - CREDENTIAL LOGIN FAILLED")
                    print(error?.localizedDescription)
                    return
                }
                print("FB 로그인 성공")
                self?.dismiss(animated: true)
            }
            
            
        }
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
