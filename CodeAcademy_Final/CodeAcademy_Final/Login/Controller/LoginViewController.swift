//
//  LoginViewController.swift
//  AssignmentApp
//
//  Created by Egidijus Vaitkevičius on 2022-11-24.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet private weak var signButtonOutlet: UIButton!
    @IBOutlet private weak var loginRegisterLabel: UILabel!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var actionButtonOutlet: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
        currencyPickerView.isHidden = true
        setupUI()

    }
    
    //MARK: - Properties
    
    let serviceAPI = ServiceAPI(networkService: NetworkService())
    let taskBarNav = TabBarViewController()
    let currencies = ["EUR", "USD"]
    var selectedCurrency: Currency = .EUR
    var transactions: [TransactionInfo] = []
    let selectedColor = UIColor(red: 105/255, green: 105/255, blue: 112/255, alpha: 1)
    var managedContext: NSManagedObjectContext!
    {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }
    
    enum Currency {
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
                signButtonOutlet.setTitle("Sign Up", for: .normal)
                loginRegisterLabel.text = "Login"
                questionLabel.text = "Don't have an account ?"
                actionButtonOutlet.setTitle("Login", for: .normal)
            case .register:
                signButtonOutlet.setTitle("Sign In", for: .normal)
                loginRegisterLabel.text = "Register"
                questionLabel.text = "Already have an account ?"
                actionButtonOutlet.setTitle("Register", for: .normal)
        }
    }
    
    
    func setupUI() {
        passwordTextField.delegate = self
        phoneTextField.delegate = self
        confirmPasswordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
//        passwordTextField.backgroundColor = normalColor
        passwordTextField.borderStyle = .roundedRect
//        phoneTextField.backgroundColor = normalColor
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .phonePad
//        confirmPasswordTextField.backgroundColor = normalColor
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        signButtonOutlet.layer.masksToBounds = true
        signButtonOutlet.layer.cornerRadius = 8
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        // Remove all non-numeric characters from the text field's text
        let modifiedPhoneNumber = String(textField.text?.filter { "0123456789+".contains($0) } ?? "")
        // Update the text field's text to only include numeric characters
        phoneTextField.text = modifiedPhoneNumber
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        switch currentState {
            case .register:
                register()
            case .login:
                login()
        }
    }
    
    func register() {
        serviceAPI.registerUser(phoneNumber: phoneTextField.text!,
                                password: passwordTextField.text!, currency: selectedCurrency.description) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let userId):
                    
                    signButtonTapped(self)
                    // make user to login after registration !!
                    currentState = .login
                case .failure(let error):
                    
                    UIAlertController.showErrorAlert(title: error.message ?? "",
                                                     message: "Error with status code: \(error.statusCode)",
                                                     controller: self)
            }
        }
    }
    
    func login() {
        serviceAPI.loginUser(phoneNumber: "0963", password: "q") { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let loggedUser):
                    taskBarNav.setUser(loggedUser, serviceAPI: serviceAPI)
                    self.navigationController?.setViewControllers([self.taskBarNav], animated: true)
                case .failure(let error):
                    UIAlertController.showErrorAlert(title: error.message ?? "",
                                                     message: "Error with status code: \(error.statusCode)",
                                                     controller: self)
            }
        }
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        textField.backgroundColor = .systemGray6
    }
}


// MARK: - UIPickerView

extension LoginViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = row == 0 ? .EUR : .USD
    }
    
}


