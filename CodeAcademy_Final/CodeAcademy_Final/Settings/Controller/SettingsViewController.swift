//
//  SettingsViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    let phoneTextField = UITextField()
    let passwordTextField = UITextField()
    let titleLabel = UILabel()
    let submitButton = UIButton(type: .system)
    let logoutButton = UIButton(type: .system)
    var loggedInUser: UserAuthenticationResponse?
    var serviceAPI: ServiceAPI?
    var homeVC: HomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        setupUI()
        setupLogoutButton()
        setupSubmitButton()
    }
    
    func setupUI() {
        
        view.backgroundColor = .systemGray6
        // Add tap gesture recognizer to dismiss keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Set up title label
            titleLabel.text = "Settings"
            titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(titleLabel)
            
            // Add constraints for title label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
            
            // Set up phone text field
            phoneTextField.placeholder = "Phone number"
            phoneTextField.borderStyle = .roundedRect
            phoneTextField.keyboardType = .phonePad
            view.addSubview(phoneTextField)
            
            // Set up password text field
            passwordTextField.placeholder = "Password"
            passwordTextField.borderStyle = .roundedRect
            passwordTextField.isSecureTextEntry = true
            view.addSubview(passwordTextField)
            
            // Add constraints for phoneTextField
            phoneTextField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                phoneTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                phoneTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                phoneTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
                phoneTextField.heightAnchor.constraint(equalToConstant: 40)
            ])
            
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
                logoutButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 100),
                logoutButton.widthAnchor.constraint(equalToConstant: 120),
                logoutButton.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    
    func setupSubmitButton() {
        
        // Set up Submit button
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Change settings", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        submitButton.backgroundColor = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        submitButton.layer.cornerRadius = 8
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            submitButton.widthAnchor.constraint(equalToConstant: 200),
            submitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
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

    // Called when editing ends for the textfield
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Hide the keyboard
        textField.resignFirstResponder()
    }
    
    // Called when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
}

