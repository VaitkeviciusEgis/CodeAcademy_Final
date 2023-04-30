//
//  LoginViewController.swift
//  AssignmentApp
//
//  Created by Egidijus Vaitkevičius on 2022-11-24.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var stateButton: UIButton!
    @IBOutlet private weak var loginRegisterLabel: UILabel!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var currencyPickerView: UIPickerView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        pickerViewSetup()
//        attemptAutoLogin()
    }

    //MARK: - Properties

    let serviceAPI = ServiceAPI(networkService: NetworkService())
    let tabBarNav = TabBarViewController()
    var selectedCurrency: Currency = .EUR
    var transactions: [TransactionInfo] = []
    let selectedColor = UIColor(red: 235/255, green: 242/255, blue: 250/255, alpha: 1)
    
    let deSelectedColor = UIColor(red: 0/255, green: 178/255, blue: 149/255, alpha: 1)
    
    enum Currency: CaseIterable {
        case EUR
        case USD
        
        var description: String {
            switch self {
            case .EUR:
                return "EUR"
            case .USD:
                return "USD"
            }
        }
    }
    
    enum State {
        case register
        case login
    }
    private var currentState: State = .login
    
    //MARK: -  Action
    
    @IBAction private func signButtonTapped(_ sender: Any) {
        
        if currentState == .login {
            currentState = .register
        } else if currentState == .register {
            currentState = .login
        }
        confirmPasswordTextField.isHidden = currentState != .register
        currencyPickerView.isHidden = currentState != .register
        
        switch currentState {
            case .login:
                stateButton.setTitle("Sign Up", for: .normal)
                loginRegisterLabel.text = "Login"
                questionLabel.text = "Don't have an account ?"
                actionButton.setTitle("Login", for: .normal)
            case .register:
                stateButton.setTitle("Sign In", for: .normal)
                loginRegisterLabel.text = "Register"
                questionLabel.text = "Already have an account ?"
                actionButton.setTitle("Register", for: .normal)
        }
    }
    
    
    func setupUI() {
        actionButton.tintColor = .white
        passwordTextField.delegate = self
        phoneTextField.delegate = self
        confirmPasswordTextField.delegate = self

        passwordTextField.backgroundColor = deSelectedColor
        confirmPasswordTextField.backgroundColor = deSelectedColor
        phoneTextField.backgroundColor = deSelectedColor
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .phonePad
        passwordTextField.keyboardType = .namePhonePad
        confirmPasswordTextField.keyboardType = .namePhonePad
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        stateButton.layer.masksToBounds = true
        stateButton.layer.cornerRadius = 8
        stateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        let modifiedPhoneNumber = String(textField.text?.filter { "0123456789+".contains($0) } ?? "")
        phoneTextField.text = modifiedPhoneNumber
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        switch currentState {
            case .register:
             confirmPassword(password: passwordTextField.text ?? "", confirmation: confirmPasswordTextField.text ?? "", phoneNumber: phoneTextField.text ?? "", currency: selectedCurrency.description)
            
            case .login:
                login()
        }
    }
    
    func confirmPassword(password: String, confirmation: String, phoneNumber: String, currency: String) {
        if password != confirmation {
            UIAlertController.showErrorAlert(title: "Try again!", message: "This time make sure that passwords do match!", controller: self)

        } else {
            register(phoneNumber: phoneNumber, password: password, currency: currency)
      
        }
    }
    
    func register(phoneNumber: String, password: String, currency: String) {
        guard let password = passwordTextField.text, let phone = phoneTextField.text else {
            return
        }
        serviceAPI.registerUser(phoneNumber: phone,
                                password: password, currency: selectedCurrency.description) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(_):
                    UIAlertController.showErrorAlert(title: "Registered!", message: "Please login", controller: self)
                    signButtonTapped(self)
                    currentState = .login
                case .failure(let error):
                    
                    UIAlertController.showErrorAlert(title: error.message ?? "",
                                                     message: "\(errorStatusCodeMessage) \(error.statusCode)",
                                                     controller: self)
            }
        }
    }

    
    func login() {
        guard let password = passwordTextField.text, let phone = phoneTextField.text else {
            return
        }
        
        serviceAPI.loginUser(phoneNumber: phone, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let loggedUser):
                    let defaults = UserDefaults.standard
                    defaults.set(password, forKey: uDefaultsPassword)
                    defaults.set(phone, forKey: uDefaultsPhone)

//         
//                    let keychain = KeychainSwift()
//                    keychain.set(loggedUser.accessToken, forKey: keyAccessToken)

                    tabBarNav.setUser(loggedUser, serviceAPI: serviceAPI)
              
                    self.navigationController?.setViewControllers([tabBarNav], animated: true)
                case .failure(let error):
                    UIAlertController.showErrorAlert(title: error.message ?? "",
                                                         message: "\(errorStatusCodeMessage) \(error.statusCode)",
                                                         controller: self)
            }
        }
    }

    func attemptAutoLogin() {
        let defaults = UserDefaults.standard
        guard let phoneNumber = defaults.string(forKey: "phoneNumber"), let password = defaults.string(forKey: "password") else {
            return
        }
        serviceAPI.loginUser(phoneNumber: phoneNumber, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let loggedUser):
                tabBarNav.setUser(loggedUser, serviceAPI: serviceAPI)
                self.navigationController?.setViewControllers([tabBarNav], animated: false)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func pickerViewSetup() {
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
        currencyPickerView.isHidden = true
    }
}


// MARK: - UIPickerView

extension LoginViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Currency.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let currency = Currency.allCases[row]
        return currency.description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _ = Currency.allCases[row]
        // Do something with the selected currency
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    
    // MARK: - Text Field Delegate
    
    
    func textFieldShouldPaste(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            actionButtonTapped(self)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        
        if textField == passwordTextField || textField == phoneTextField {
            let newLength = text.count + string.count - range.length
            let limit = 12
            
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
        if textField == phoneTextField || textField == passwordTextField || textField == confirmPasswordTextField {
            textField.backgroundColor = selectedColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = deSelectedColor
        
    }
}


