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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        pickerViewSetup()
        saveLoginCredentials()
    }
    
    //MARK: - Properties
    
    private let serviceAPI = ServiceAPI(networkService: NetworkService())
    private let tabBarNav = TabBarViewController()
    private var selectedCurrency: Currency = .EUR
    private var selectedCurrencyRow: Int = 0
    
    
    // MARK: - Enums
    
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
    
    // MARK: - Properties
    
    private var currentState: State = .login {
        didSet {
            confirmPasswordTextField.isHidden = currentState != .register
            currencyPickerView.isHidden = currentState != .register
            
            switch currentState {
                case .login:
                    stateButton.setTitle("Sign Up", for: .normal)
                    loginRegisterLabel.text = "Login"
                    questionLabel.text = "Don't have an account?"
                    actionButton.setTitle("Login", for: .normal)
                    
                case .register:
                    stateButton.setTitle("Sign In", for: .normal)
                    loginRegisterLabel.text = "Register"
                    questionLabel.text = "Already have an account?"
                    actionButton.setTitle("Register", for: .normal)
            }
        }
    }
    
    //MARK: -  Action
    
    @IBAction private func signButtonTapped(_ sender: Any) {
        
        currentState = currentState == .login ? .register : .login
    }
    
    func setupUI() {
        setupTextFields()
        
        actionButton.tintColor = .white
        stateButton.layer.masksToBounds = true
        stateButton.layer.cornerRadius = 8
        stateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupTextFields() {
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .phonePad
        phoneTextField.backgroundColor = deSelectedColor
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneTextField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = deSelectedColor
        passwordTextField.keyboardType = .namePhonePad
        passwordTextField.delegate = self
        
        confirmPasswordTextField.keyboardType = .namePhonePad
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.backgroundColor = deSelectedColor
        confirmPasswordTextField.delegate = self
    }
    
    func saveLoginCredentials() {
        let savedPhoneNumber = keyChain.get(keyPhoneNumber) ?? ""
        let savedPassword = keyChain.get(keyPassword) ?? ""
        phoneTextField.text = savedPhoneNumber
        passwordTextField.text = savedPassword
    }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let modifiedPhoneNumber = String(textField.text?.filter { allowedCharacters.contains($0) } ?? "")
        phoneTextField.text = modifiedPhoneNumber
    }
    
    @IBAction private func actionButtonTapped(_ sender: Any) {
        switch currentState {
            case .register:
                confirmPassword(password: passwordTextField.text ?? "", confirmation: confirmPasswordTextField.text ?? "", phoneNumber: phoneTextField.text ?? "", currency: selectedCurrency.description)
                
            case .login:
                login()
        }
    }
    
    private func confirmPassword(password: String, confirmation: String, phoneNumber: String, currency: String) {
        if password != confirmation {
            UIAlertController.showErrorAlert(title: "Try again!", message: "This time make sure that passwords do match!", controller: self)
            
        } else {
            register(phoneNumber: phoneNumber, password: password, currency: currency)
            
        }
    }
    
    private func pickerViewSetup() {
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
        currencyPickerView.isHidden = true
    }
    
    private func register(phoneNumber: String, password: String, currency: String) {
        guard let password = passwordTextField.text, let phone = phoneTextField.text else {
            return
        }
        serviceAPI.registerUser(phoneNumber: phone,
                                password: password, currency: currency) { [weak self] result in
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
    
    private func login() {
        guard let password = passwordTextField.text, let phone = phoneTextField.text else {
            return
        }
        
        serviceAPI.loginUser(phoneNumber: phone, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let loggedUser):
                    keyChain.set(password, forKey: keyPassword)
                    keyChain.set(phone, forKey: keyPhoneNumber)
                    keyChain.set(loggedUser.accessToken, forKey: keyAccessToken)
                    
                    
                    tabBarNav.setUser(loggedUser, serviceAPI: serviceAPI)
                    
                    self.navigationController?.setViewControllers([tabBarNav], animated: true)
                case .failure(let error):
                    UIAlertController.showErrorAlert(title: error.message ?? "",
                                                     message: "\(errorStatusCodeMessage) \(error.statusCode)",
                                                     controller: self)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = Currency.allCases[row]
        pickerViewSetup()
    }
}

// MARK: - UIPickerView

extension LoginViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Currency.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let currency = Currency.allCases[row]
        return currency.description
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    private func textFieldShouldPaste(_ textField: UITextField) -> Bool {
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
            let limit = textFieldLimit
            
            if newLength > limit {
                return false
            }
        }
        
        if textField == phoneTextField {
            let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
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


