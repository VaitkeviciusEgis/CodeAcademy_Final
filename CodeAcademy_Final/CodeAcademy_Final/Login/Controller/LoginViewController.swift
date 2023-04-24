//
//  LoginViewController.swift
//  AssignmentApp
//
//  Created by Egidijus Vaitkevičius on 2022-11-24.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet private weak var signButtonOutlet: UIButton!
    @IBOutlet private weak var loginRegisterLabel: UILabel!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var actionButtonOutlet: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
//    @IBOutlet private weak var maxMinCharactersLabel: UILabel!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
        currencyPickerView.isHidden = true 
    }
    
    //MARK: Properties
    let serviceAPI = ServiceAPI(networkService: NetworkService())
    let taskBarNav = TabBarViewController()
    let currencies = ["EUR", "USD"]
    var selectedCurrency: Currency = .EUR
    var transactions: [TransactionInfo] = []
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
    
    @IBAction private func signButtonTapped(_ sender: Any) {
        
        if currentState == .login {
            currentState = .register
        } else if currentState == .register {
            currentState = .login
        }
        confirmPasswordTextField.isHidden = currentState != .register
        currencyPickerView.isHidden = currentState != .register
//        maxMinCharactersLabel.isHidden = currentState != .register
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
    
    //MARK: Action
    func setupUI() {
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        signButtonOutlet.layer.masksToBounds = true
        signButtonOutlet.layer.cornerRadius = 8
        
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        signButtonOutlet.layer.masksToBounds = true
        signButtonOutlet.layer.cornerRadius = 8
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        // Implement the editingChanged event handler
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Remove all non-numeric characters from the text field's text
        let modifiedPhoneNumber = String(textField.text?.filter { "0123456789+".contains($0) } ?? "")
        
        // Update the text field's text to only include numeric characters
        phoneNumberTextField.text = modifiedPhoneNumber
        
        // Print the numeric characters as a string
        print(modifiedPhoneNumber)
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
        serviceAPI.registerUser(phoneNumber: phoneNumberTextField.text!,
                                password: passwordTextField.text!, currency: selectedCurrency.description) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(_):
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
//                    print(loggedUser.userId)
//                    print(loggedUser.accountInfo.ownerPhoneNumber)
//                    print("ZIRUETI CIA")
//                    
//                    
                    
                    taskBarNav.setUser(loggedUser, serviceAPI: serviceAPI)
                    
                   
                        print("loadTransactionsData called")
         

                    
                    
                    self.navigationController?.setViewControllers([self.taskBarNav], animated: true)
                case .failure(let error):
                    UIAlertController.showErrorAlert(title: error.message ?? "",
                                                     message: "Error with status code: \(error.statusCode)",
                                                     controller: self)
            }
        }
    }
    
}

extension LoginViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           return currencies.count
       }
       
       // MARK: - UIPickerViewDelegate
       
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return currencies[row]
       }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           selectedCurrency = row == 0 ? .EUR : .USD
           print("Selected currency: \(selectedCurrency.description)")
       }
    
}
