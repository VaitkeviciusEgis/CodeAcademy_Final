//
//  SettingsViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit

class SettingsViewController: UIViewController {
    
    //MARK: - Properties
    
    private let phoneTextField = UITextField()
    private let passwordTextField = UITextField()
    private let titleLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    var loggedInUser: UserAuthenticationResponse?
    var serviceAPI: ServiceAPI?
    var homeVC: HomeViewController?
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPhoneTextField()
        setupPasswordTextField()
        setupSubmitButton()
        setupLogoutButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayDetails()
    }
    
    //MARK: - Setup UI
    
    func displayDetails() {
        let savedPassword = keyChain.get(keyPassword) ?? ""
        passwordTextField.text = savedPassword
        let savedPhoneNumber = keyChain.get(keyPhoneNumber) ?? ""
        phoneTextField.text = savedPhoneNumber
    }
    
    private func setupUI() {
        view.backgroundColor = cardPayBackgroundColor
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        titleLabel.text = "Change Settings"
        titleLabel.textColor = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
    }
    
    private func setupPhoneTextField() {
        phoneTextField.placeholder = "Phone number"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .phonePad
        phoneTextField.backgroundColor = deSelectedColor
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.textAlignment = .center
        view.addSubview(phoneTextField)
        phoneTextField.delegate = self
        
        // Add constraints for phoneTextField
        NSLayoutConstraint.activate([
            phoneTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            phoneTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            phoneTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupPasswordTextField() {
        passwordTextField.placeholder = "Password"
        passwordTextField.keyboardType = .namePhonePad
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        passwordTextField.delegate = self
        passwordTextField.backgroundColor = cardPayBackgroundColor
        passwordTextField.textAlignment = .center
        
        setupPasswordConstraints()
    }
    
    private func setupPasswordConstraints() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupLogoutButton() {
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logoutButton.layer.borderColor = borderColor
        logoutButton.backgroundColor = UIColor(red: 245/255, green: 93/255, blue: 62/255, alpha: 1)
        logoutButton.layer.cornerRadius = 8
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.opacity = 0.5
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 120),
            logoutButton.widthAnchor.constraint(equalToConstant: 120),
            logoutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    private  func setupSubmitButton() {
        // Set up Submit button
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit Changes", for: .normal)
        submitButton.backgroundColor = UIColor(red: 135/255, green: 179/255, blue: 53/255, alpha: 1)
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        submitButton.layer.cornerRadius = 8
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = borderColor
        submitButton.layer.opacity = 0.5
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 60),
            submitButton.widthAnchor.constraint(equalToConstant: 200),
            submitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Action
    
    @objc private func submitButtonTapped() {
        guard let currentPhoneNumber = loggedInUser?.accountInfo.ownerPhoneNumber, let currentToken = loggedInUser?.accessToken else {
            return
        }
        
        let newPhoneNumber = phoneTextField.text
        let newPassword = passwordTextField.text
        
        
        guard let newPhoneNumber = newPhoneNumber, let newPassword = newPassword else {
            
            return
        }
        
        if newPhoneNumber.isEmpty && newPassword.isEmpty {
            UIAlertController.showErrorAlert(title: "Fields are empty", message: "Enter new credentials", controller: self)
        } else if newPhoneNumber.isEmpty {
            UIAlertController.showErrorAlert(title: "Empty input", message: "Enter new phone number", controller: self)
        } else if newPassword.isEmpty {
            UIAlertController.showErrorAlert(title: "Empty input", message: "Enter new password", controller: self)
        }
        
        serviceAPI?.updateUser(currentPhoneNumber: currentPhoneNumber, newPhoneNumber: newPhoneNumber, newPassword: newPassword, accessToken: currentToken, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            
            
            if loggedInUser?.accountInfo.ownerPhoneNumber == newPhoneNumber {
                UIAlertController.showErrorAlert(title: "Current phone number is the same", message: "Please enter new phone number", controller: self)
            }
            
            switch result {
                case .success(let updated):
                    UIAlertController.showErrorAlert(title: "Success!",
                                                     message: "Credentials updated.\n" + "Please login again",
                                                     controller: self)
                    let updatedLoggedInUser = UserAuthenticationResponse(userId: updated.userId, validUntil: updated.validUntil, accessToken: updated.accessToken, accountInfo: updated.accountInfo)
                    
                    homeVC?.loggedInUser = updatedLoggedInUser
                    // Save updated credentials to keychain
                    keyChain.set(newPhoneNumber, forKey: keyPhoneNumber)
                    keyChain.set(newPassword, forKey: keyPassword)
                    
                    // Set the updated credentials on the login screen
                    guard let loginVC = self.navigationController?.viewControllers.first(where: { $0 is LoginViewController }) as? LoginViewController else { return }
                    loginVC.phoneTextField.text = newPhoneNumber
                    loginVC.passwordTextField.text = newPassword
                case .failure(let error):
                    UIAlertController.showErrorAlert(title: "\(errorStatusCodeMessage) \(error.statusCode)",
                                                     message: error.localizedDescription,
                                                     controller: self)
            }
            
            
        })
        dismissKeyboard()
    }
    
    @objc private func logoutButtonTapped() {
        self.navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
}

extension SettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            submitButtonTapped()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let textWithoutSpaces = textField.text?.replacingOccurrences(of: " ", with: "")
            textField.text = textWithoutSpaces
        if textField == phoneTextField  {
            
            return textField.validatePhoneNumber(allowedCharacters: allowedCharacters, replacementString: string)
        }
        
        if textField == passwordTextField {
            let newLength = text.count + string.count - range.length
            let limit = allowedCharacters.count
            
            if newLength > limit {
                return false
            }
        }
  return true 
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneTextField || textField == passwordTextField {
            textField.backgroundColor = buttonBackgroundColor
        } else {
            textField.backgroundColor = deSelectedColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneTextField  || textField == passwordTextField {
            textField.backgroundColor = deSelectedColor
        } else {
            textField.backgroundColor = buttonBackgroundColor
        }
    }
}


