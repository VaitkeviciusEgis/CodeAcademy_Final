//
//  SettingsViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Properties
    
    let phoneTextField = UITextField()
    let passwordTextField = UITextField()
    let titleLabel = UILabel()
    let submitButton = UIButton(type: .system)
    let logoutButton = UIButton(type: .system)
    var loggedInUser: UserAuthenticationResponse?
    var serviceAPI: ServiceAPI?
    var homeVC: HomeViewController?
    let normalColor = UIColor(red: 49/255, green: 49/255, blue: 54/255, alpha: 1)
    let selectedColor = UIColor(red: 105/255, green: 105/255, blue: 112/255, alpha: 1)
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPhoneTextField()
        setupPasswordTextField()
        setupSubmitButton()
        setupLogoutButton()
    }
    
    //MARK: - Setup UI
    
    func setupUI() {
        view.backgroundColor = .systemGray6
        // Add tap gesture recognizer to dismiss keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Set up title label
        titleLabel.text = "Change Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Add constraints for title label
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray6])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray6])
        
    }
    
    func setupPhoneTextField() {
        // Set up phone text field
        phoneTextField.placeholder = "Phone number"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .phonePad
        phoneTextField.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 54/255, alpha: 1)
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
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
    
    func setupPasswordTextField() {
        // Set up password text field
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        passwordTextField.delegate = self
        passwordTextField.backgroundColor = normalColor
        // Add constraints for passwordTextField
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupLogoutButton() {
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logoutButton.backgroundColor = .systemRed
        logoutButton.layer.cornerRadius = 8
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.white.cgColor
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
    
    func setupSubmitButton() {
        // Set up Submit button
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit Changes", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        submitButton.layer.cornerRadius = 8
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = CGColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
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
    
    @objc func submitButtonTapped() {
        print("Submit tapped!")
        guard let currentPhoneNumber = loggedInUser?.accountInfo.ownerPhoneNumber, let currentToken = loggedInUser?.accessToken else {
            print("nil in current token or phone number")
            return
        }
        
        let newPhoneNumber = phoneTextField.text
        let newPassword = passwordTextField.text
        
        
        guard let newPhoneNumber = newPhoneNumber, let newPassword = newPassword, !newPhoneNumber.isEmpty || !newPassword.isEmpty else {
            print("Field is empty in update user")
            return
        }
        
        serviceAPI?.updateUser(currentPhoneNumber: currentPhoneNumber, newPhoneNumber: newPhoneNumber, newPassword: newPassword, accessToken: currentToken, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
                case .success(let updated):
                    UIAlertController.showErrorAlert(title: "Success!",
                                                     message: "Your task was updated",
                                                     controller: self)
                    let updatedLoggedInUser = UserAuthenticationResponse(userId: updated.userId, validUntil: updated.validUntil, accessToken: updated.accessToken, accountInfo: updated.accountInfo)
                    
                    homeVC?.loggedInUser = updatedLoggedInUser
                    
                    phoneTextField.text = ""
                    passwordTextField.text = ""
                case .failure(let error):
                    UIAlertController.showErrorAlert(title: "Error with status code: \(error.statusCode)",
                                                     message: error.localizedDescription,
                                                     controller: self)
            }
        })
        dismissKeyboard()
    }
    
    @objc func logoutButtonTapped() {
        // Perform logout action
        print("Logout button tapped!")
        self.navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        if textField == passwordTextField || textField == phoneTextField {
            let newLength = text.count + string.count - range.length
            let limit = 10
            
            if newLength > limit {
                return false
            }
        }
        
        if textField == phoneTextField {
            let allowedCharacterSet = CharacterSet(charactersIn: "0123456789+")
            let replacementStringCharacterSet = CharacterSet(charactersIn: string)
            return allowedCharacterSet.isSuperset(of: replacementStringCharacterSet)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneTextField || textField == submitButton || textField == passwordTextField {
            textField.backgroundColor = selectedColor
        } else {
            textField.backgroundColor = normalColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = normalColor
    }
}

