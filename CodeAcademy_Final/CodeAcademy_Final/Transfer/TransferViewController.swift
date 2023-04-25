//
//  SendMoneyViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit
//var loggedInUser: UserAuthenticationResponse?
//view.backgroundColor = .blue


class TransferViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    private let recipientPhoneNumberTextField = UITextField()
    private let senderCurrencyTextField = UITextField()
    private let commentTextField = UITextField()
    private let enterSumTextField = UITextField()
    let titleLabel = UILabel()
    var loggedInUser: UserAuthenticationResponse?
    var serviceAPI: ServiceAPI?
    var viewModel: TransactionsViewModel?
    let sendMoneyButton = UIButton(type: .system)
    let normalColor = UIColor(red: 49/255, green: 49/255, blue: 54/255, alpha: 1)
     let selectedColor = UIColor(red: 105/255, green: 105/255, blue: 112/255, alpha: 1)
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSendButton()
        // Set delegates
        
        recipientPhoneNumberTextField.backgroundColor = normalColor
            senderCurrencyTextField.backgroundColor = selectedColor
            commentTextField.backgroundColor = normalColor
            enterSumTextField.backgroundColor = normalColor

        
        recipientPhoneNumberTextField.delegate = self
        senderCurrencyTextField.delegate = self
        commentTextField.delegate = self
        enterSumTextField.delegate = self
          senderCurrencyTextField.backgroundColor = UIColor(red: 105/255, green: 105/255, blue: 112/255, alpha: 1)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Remove observer for didTransferMoneySuccessfully notification
//            NotificationCenter.default.removeObserver(self, name: Notification.Name("didTransferMoneySuccessfully"), object: nil)
        }
    let didTransferMoneyNotification = Notification.Name("didTransferMoneyNotification")

    // MARK: - UI Setup
    
    private func setupUI() {
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.backgroundColor = .systemGray6
        titleLabel.text = "Make Transaction"
        // Set up text fields
        recipientPhoneNumberTextField.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 54/255, alpha: 1)
        senderCurrencyTextField.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 54/255, alpha: 1)
        commentTextField.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 54/255, alpha: 1)
        enterSumTextField.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 54/255, alpha: 1)
        // selected UIColor(red: 105/255, green: 105/255, blue: 112/255, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.addSubview(titleLabel)
        
        // Add constraints for title label
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        
        recipientPhoneNumberTextField.placeholder = "Recipient phone number"
        recipientPhoneNumberTextField.textAlignment = .center
        senderCurrencyTextField.text = loggedInUser?.accountInfo.currency
        senderCurrencyTextField.isUserInteractionEnabled = false
        senderCurrencyTextField.textAlignment = .center
        commentTextField.placeholder = "Add a comment"
        commentTextField.textAlignment = .center
        enterSumTextField.placeholder = "Enter amount"
        enterSumTextField.textAlignment = .center
        enterSumTextField.keyboardType = .decimalPad
        recipientPhoneNumberTextField.keyboardType = .phonePad
        
        recipientPhoneNumberTextField.layer.cornerRadius = 8
        senderCurrencyTextField.layer.cornerRadius = 8
        commentTextField.layer.cornerRadius = 8
        enterSumTextField.layer.cornerRadius = 8
        
        // Set delegate for text fields
        recipientPhoneNumberTextField.delegate = self
        enterSumTextField.delegate = self
        
        // Add subviews
        view.addSubview(recipientPhoneNumberTextField)
        view.addSubview(senderCurrencyTextField)
        view.addSubview(commentTextField)
        view.addSubview(enterSumTextField)
        
        // Add constraints
        recipientPhoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        senderCurrencyTextField.translatesAutoresizingMaskIntoConstraints = false
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        enterSumTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recipientPhoneNumberTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            recipientPhoneNumberTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recipientPhoneNumberTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            recipientPhoneNumberTextField.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
            
            senderCurrencyTextField.topAnchor.constraint(equalTo: recipientPhoneNumberTextField.bottomAnchor, constant: 20),
            senderCurrencyTextField.leadingAnchor.constraint(equalTo: recipientPhoneNumberTextField.leadingAnchor),
            senderCurrencyTextField.widthAnchor.constraint(equalTo: recipientPhoneNumberTextField.widthAnchor),
            senderCurrencyTextField.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
            
            commentTextField.topAnchor.constraint(equalTo: senderCurrencyTextField.bottomAnchor, constant: 20),
            commentTextField.leadingAnchor.constraint(equalTo: senderCurrencyTextField.leadingAnchor),
            commentTextField.widthAnchor.constraint(equalTo: senderCurrencyTextField.widthAnchor),
            commentTextField.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
            
            enterSumTextField.topAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: 20),
            enterSumTextField.leadingAnchor.constraint(equalTo: commentTextField.leadingAnchor),
            enterSumTextField.widthAnchor.constraint(equalTo: commentTextField.widthAnchor),
            enterSumTextField.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
        ])
    }

    func didTransferMoneySuccessfully() {
        // Transfer money code here...
        serviceAPI?.fetchingTransactions(url: URLBuilder.getTaskURL(withId: loggedInUser?.accountInfo.id ?? 0), completion: { [weak self] (result) in
            guard self != nil else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                    case .success(_): break
//                        print("\(transactions)")
                        
                    case .failure(let error):
                        print("Error processing json data: \(error)")
                }
                    }
            
            })
        // Post a notification
        NotificationCenter.default.post(name: didTransferMoneyNotification, object: nil)
    }
    
    func setupSendButton() {
        // create a button and add it to the view

        sendMoneyButton.setTitle("Send Money", for: .normal)
        sendMoneyButton.addTarget(self, action: #selector(sendMoneyTapped), for: .touchUpInside)
        sendMoneyButton.translatesAutoresizingMaskIntoConstraints = false
        sendMoneyButton.setTitleColor(.white, for: .normal)
        sendMoneyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        sendMoneyButton.backgroundColor = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        sendMoneyButton.layer.borderWidth = 1
        sendMoneyButton.layer.borderColor = UIColor.white.cgColor
        sendMoneyButton.layer.cornerRadius = 8
        view.addSubview(sendMoneyButton)
        
        // set constraints for the button
        NSLayoutConstraint.activate([
            sendMoneyButton.topAnchor.constraint(equalTo: enterSumTextField.bottomAnchor, constant: 60),
            sendMoneyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendMoneyButton.widthAnchor.constraint(equalToConstant: 120),
            sendMoneyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    // called when user taps the send money buttontableView.separatorStyle = .nonec
    @objc func sendMoneyTapped() {
        let senderPhoneNumber = loggedInUser?.accountInfo.ownerPhoneNumber
        let token = loggedInUser?.accessToken
        let senderAccountId = Int(loggedInUser?.accountInfo.id ?? -1)
        let receiverPhoneNumber = recipientPhoneNumberTextField.text
        let amount = Double(enterSumTextField.text ?? "")
        let comment = commentTextField.text
        
        guard let senderPhoneNumber = senderPhoneNumber, let token = token, let receiverPhoneNumber = receiverPhoneNumber, let amount = amount, let comment = comment
        else {
            return
        }
        // TODO: implement code to send money
        serviceAPI?.transferMoney(senderPhoneNumber: senderPhoneNumber,
                                  token: token, senderAccountId: senderAccountId,
                                  receiverPhoneNumber: receiverPhoneNumber,
                                  amount: amount,
                                  comment: comment) { [weak self] result in
            guard let self = self else { return }
            switch result {
                    
                case .success(_):
                    let formattedAmount = String(format: "%.2f", amount)
                     let message = "Transferred amount: \(formattedAmount) Receiver: \(receiverPhoneNumber)"
                     UIAlertController.showErrorAlert(title: "Success!", message: message, controller: self)
                     
                     recipientPhoneNumberTextField.text = ""
                     senderCurrencyTextField.text = loggedInUser?.accountInfo.currency
                     senderCurrencyTextField.isUserInteractionEnabled = false
                     commentTextField.text = ""
                     enterSumTextField.text = ""
                     var currentBalance = loggedInUser?.accountInfo.balance
                     let newBalance = (currentBalance ?? 0) - amount
                     currentBalance = newBalance // update currentBalance with the new balance
                     loggedInUser?.accountInfo.balance = newBalance // update loggedInUser with the new balance

                    
                    didTransferMoneySuccessfully()
                case .failure(let error):
                    UIAlertController.showErrorAlert(title: error.message ?? "",
                                                     message: "Error with status code: \(error.statusCode)",
                                                     controller: self)
                    // for testing purpose
//                    let url = URL(string: "http://134.122.94.77:7000/api/User/")!
//                    serviceAPI?.fetchingUsers(url: url) { [weak self] user in
//                        guard let self = self else {
//                            return
//                        }
//                        var usersArray = [Transaction]()
//                        usersArray = user
//                        for user in usersArray {
//                            print("id: \(user.id), phone: \(user.phoneNumber)")
//                            // Replace "username" and "email" with the actual properties of your User type
//                        }
//                    }
            }
        }
    }
    
    
    // MARK: - Keyboard Handling
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == recipientPhoneNumberTextField {
            senderCurrencyTextField.becomeFirstResponder()
        } else if textField == senderCurrencyTextField {
            commentTextField.becomeFirstResponder()
        } else if textField == commentTextField {
            enterSumTextField.becomeFirstResponder()
        } else {
            enterSumTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == recipientPhoneNumberTextField {
            let allowedCharacterSet = CharacterSet(charactersIn: "0123456789+")
            let replacementStringCharacterSet = CharacterSet(charactersIn: string)
            return allowedCharacterSet.isSuperset(of: replacementStringCharacterSet)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == senderCurrencyTextField || textField == sendMoneyButton {
            textField.backgroundColor = selectedColor
        } else {
            textField.backgroundColor = UIColor(red: 105/255, green: 105/255, blue: 112/255, alpha: 1)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = normalColor
    }
}

