//
//  RegisterViewController.swift
//  Task-test-for-job
//
//  Created by Apple on 31.7.2024.
//

import UIKit
import SnapKit

class RegisterViewController: BaseViewController {
    
    private let titleScreen: UILabel = {
        let view = UILabel()
        view.text = "Регистрация"
        view.font = .systemFont(ofSize: 25, weight: .bold)
        view.textColor = .black
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textFild = UITextField()
        textFild.placeholder = "Email"
        textFild.borderStyle = .roundedRect
        return textFild
    }()
    
    private let passwordTextField: UITextField = {
        let textFild = UITextField()
        textFild.placeholder = "Пароль"
        textFild.borderStyle = .roundedRect
        textFild.isSecureTextEntry = true
        return textFild
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Регистрация", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private let sessionStore = SessionStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addTargets()
        setup()
    }
    
    private func setup() {
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(titleScreen)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(registerButton)
    }
    
    private func setConstraints() {
        titleScreen.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
        }
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleScreen.snp.bottom).offset(170)
            make.leading.trailing.equalToSuperview().inset(16)
            make.size.equalTo(50)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(16)
            make.size.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func addTargets() {
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    @objc private func registerButtonTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        sessionStore.signUp(email: email, password: password) { error in
            if let error = error {
                self.showAlert(title: "Ошибка", massage: "\(error.localizedDescription)")
                print("\(error.localizedDescription)")
                
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
