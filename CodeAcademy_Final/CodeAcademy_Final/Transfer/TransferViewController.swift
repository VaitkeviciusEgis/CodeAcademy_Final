//
//  SendMoneyViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit


class TransferViewController: UIViewController {
    
    // MARK: - Properties
    
    var loggedInUser: UserAuthenticationResponse?
    var serviceAPI: ServiceAPI?
    var viewModel: TransactionsViewModel?
    
    //MARK: -  Private Properties
    
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let sendMoneyButton = UIButton(type: .system)
    private let didTransferMoneyNotification = Notification.Name("didTransferMoneyNotification")
    private let recipientPhoneNumberTextField = UITextField()
    private let senderCurrencyTextField = UITextField()
    private let commentTextField = UITextField()
    private let enterAmountTextField = UITextField()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSendButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = cardPayBackgroundColor
        let subViews: [UIView] = [recipientPhoneNumberTextField, senderCurrencyTextField, commentTextField, enterAmountTextField]
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.addSubview(subLabel)
        view.addSubview(titleLabel)
        view.addSubViews(subViews)
        
        
        setupTitleLabel()
        setupAmountTextField()
        setupCommentTextField()
        setupPhoneTextField()
        setupCurrencyTextField()
        setupTextFieldDelegate()
        setupPhoneConstraints()
        setupCurrencyConstraints()
        setupCommentConstraints()
        setupAmountConstraints()
    }
    
    private func setupTitleLabel() {
        setupSubLabel()
        titleLabel.text = "Make Transaction"
        titleLabel.textColor = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
    }
    
    private func setupSubLabel() {
        subLabel.font = UIFont.systemFont(ofSize: 12)
        subLabel.textColor = textColor
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
    }
    
    func setupAmountTextField() {
        enterAmountTextField.layer.cornerRadius = 8
        enterAmountTextField.backgroundColor = deSelectedColor
        enterAmountTextField.placeholder = "Enter amount"
        enterAmountTextField.textAlignment = .center
        enterAmountTextField.keyboardType = .decimalPad
    }
    
    func setupCommentTextField() {
        commentTextField.backgroundColor = deSelectedColor
        commentTextField.placeholder = "Add a comment"
        commentTextField.textAlignment = .center
        commentTextField.backgroundColor = deSelectedColor
        commentTextField.layer.cornerRadius = 8
    }
    
    func setupTextFieldDelegate() {
        recipientPhoneNumberTextField.delegate = self
        senderCurrencyTextField.delegate = self
        commentTextField.delegate = self
        enterAmountTextField.delegate = self
    }
    
    func setupPhoneTextField() {
        recipientPhoneNumberTextField.backgroundColor = deSelectedColor
        recipientPhoneNumberTextField.placeholder = "Recipient phone number"
        recipientPhoneNumberTextField.textAlignment = .center
        recipientPhoneNumberTextField.layer.cornerRadius = 8
        recipientPhoneNumberTextField.keyboardType = .phonePad
    }
    
    func setupPhoneConstraints() {
        recipientPhoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipientPhoneNumberTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            recipientPhoneNumberTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recipientPhoneNumberTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            recipientPhoneNumberTextField.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
        ])
        
    }
    
    func setupCurrencyTextField() {
        senderCurrencyTextField.backgroundColor = cardPayBackgroundColor
        senderCurrencyTextField.layer.cornerRadius = 8
        senderCurrencyTextField.text = loggedInUser?.accountInfo.currency
        senderCurrencyTextField.textColor = .black
        senderCurrencyTextField.isUserInteractionEnabled = false
        senderCurrencyTextField.textAlignment = .center
        
    }
    
    func setupCurrencyConstraints() {
        senderCurrencyTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            senderCurrencyTextField.topAnchor.constraint(equalTo: recipientPhoneNumberTextField.bottomAnchor, constant: 20),
            senderCurrencyTextField.leadingAnchor.constraint(equalTo: recipientPhoneNumberTextField.leadingAnchor),
            senderCurrencyTextField.widthAnchor.constraint(equalTo: recipientPhoneNumberTextField.widthAnchor),
            senderCurrencyTextField.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
        ])
    }
    
    func setupCommentConstraints() {
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentTextField.topAnchor.constraint(equalTo: senderCurrencyTextField.bottomAnchor, constant: 20),
            commentTextField.leadingAnchor.constraint(equalTo: senderCurrencyTextField.leadingAnchor),
            commentTextField.widthAnchor.constraint(equalTo: senderCurrencyTextField.widthAnchor),
            commentTextField.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
        ])
    }
    
    func setupAmountConstraints() {
        enterAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            enterAmountTextField.topAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: 20),
            enterAmountTextField.leadingAnchor.constraint(equalTo: commentTextField.leadingAnchor),
            enterAmountTextField.widthAnchor.constraint(equalTo: commentTextField.widthAnchor),
            enterAmountTextField.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
        ])
    }
    
    func setupSendButton() {
        sendMoneyButton.setTitle("Send Money", for: .normal)
        sendMoneyButton.addTarget(self, action: #selector(sendMoneyTapped), for: .touchUpInside)
        sendMoneyButton.setTitleColor((UIColor(cgColor: borderColor)), for: .normal) 
        sendMoneyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        sendMoneyButton.layer.borderWidth = 1
        sendMoneyButton.layer.borderColor = borderColor
        sendMoneyButton.layer.cornerRadius = 8
        sendMoneyButton.backgroundColor = buttonBackgroundColor
        sendMoneyButton.layer.opacity = 0.5
        view.addSubview(sendMoneyButton)
        sendMoneyButton.isEnabled = false
        setupSendButtonConstraints()
    }
    
    func setupSendButtonConstraints() {
        sendMoneyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendMoneyButton.topAnchor.constraint(equalTo: enterAmountTextField.bottomAnchor, constant: 24),
            sendMoneyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendMoneyButton.widthAnchor.constraint(equalToConstant: 120),
            sendMoneyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("didTransferMoneySuccessfully"), object: nil)
    }
    
    func didTransferMoneySuccessfully() {
        serviceAPI?.fetchingTransactions(url: URLBuilder.getTransactionURL(withId: loggedInUser?.accountInfo.id ?? 0), completion: { [weak self] (result) in
            guard self != nil else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                    case .success(_): break
                        
                    case .failure(let error):
                        print("Error processing json data: \(error)")
                }
            }
            
        })
        NotificationCenter.default.post(name: didTransferMoneyNotification, object: nil)
    }
    
    @objc private func sendMoneyTapped() {
        let senderPhoneNumber = loggedInUser?.accountInfo.ownerPhoneNumber
        let token = loggedInUser?.accessToken
        let senderAccountId = Int(loggedInUser?.accountInfo.id ?? -1)
        let receiverPhoneNumber = recipientPhoneNumberTextField.text
        let amount = Double(enterAmountTextField.text ?? "")
        let comment = commentTextField.text
        
        if amount == nil {
            UIAlertController.showErrorAlert(title: "Amount is required", message: "Please enter amount", controller: self)
        }
        
        guard let senderPhoneNumber = senderPhoneNumber, let token = token, let receiverPhoneNumber = receiverPhoneNumber, let amount = amount, let comment = comment
        else {
            
            return
        }
        
        if comment.isEmpty {
            UIAlertController.showErrorAlert(title: "Comment is required", message: "Enter a message to receiver", controller: self)
        }
        
        if receiverPhoneNumber == senderPhoneNumber {
            UIAlertController.showErrorAlert(title: "Transfer declined", message: "Can't transfer to yourself", controller: self)
        }
        
        serviceAPI?.transferMoney(senderPhoneNumber: senderPhoneNumber,
                                  token: token, senderAccountId: senderAccountId,
                                  receiverPhoneNumber: receiverPhoneNumber,
                                  amount: amount,
                                  comment: comment) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(_):
                    
                    let message = "Transaction completed"
                    UIAlertController.showErrorAlert(title: "Success!", message: message, controller: self)
                    
                    recipientPhoneNumberTextField.text = ""
                    senderCurrencyTextField.text = loggedInUser?.accountInfo.currency
                    commentTextField.text = ""
                    enterAmountTextField.text = ""
                    var currentBalance = loggedInUser?.accountInfo.balance
                    let newBalance = (currentBalance ?? 0) - amount
                    currentBalance = newBalance // update currentBalance with the new balance
                    loggedInUser?.accountInfo.balance = newBalance // update loggedInUser with the new balance
                    
                    
                    didTransferMoneySuccessfully()
                case .failure(let error):
                    UIAlertController.showErrorAlert(title: error.message ?? "",
                                                     message: "\(errorStatusCodeMessage) \(error.statusCode)",
                                                     controller: self)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension TransferViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let currentText = textField.text else { return true }
        let newLength = currentText.count + string.count - range.length
        
        if textField == commentTextField {
            let maxCommentLength = allowedCharacters.count
            return newLength <= maxCommentLength
        }
      
        
        if textField == enterAmountTextField  {
            
            let currentText = textField.text ?? ""
            if currentText.isEmpty && string == "0" {
                return false
            }
            if currentText == "0" {
                return false
            }
            if newLength >= allowedCharacters.count {
                return false
            }
            return textField.validateDecimalInput(replacementString: string)
        }
        
        if textField == recipientPhoneNumberTextField {
            return textField.validatePhoneNumber(allowedCharacters: allowedCharacters, replacementString: string)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == recipientPhoneNumberTextField || textField == commentTextField || textField == enterAmountTextField {
            textField.backgroundColor = buttonBackgroundColor
        } else {
            textField.backgroundColor = deSelectedColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == recipientPhoneNumberTextField || textField == commentTextField || textField == enterAmountTextField {
            textField.backgroundColor = deSelectedColor
        } else {
            textField.backgroundColor = buttonBackgroundColor
        }

        if !(enterAmountTextField.text?.isEmpty ?? false) && !(recipientPhoneNumberTextField.text?.isEmpty ?? false) && !(commentTextField.text?.isEmpty ?? false) {
            sendMoneyButton.backgroundColor = UIColor(red: 135/255, green: 179/255, blue: 53/255, alpha: 1)
            sendMoneyButton.setTitleColor(UIColor.white, for: .normal)
            sendMoneyButton.isEnabled = true
        } else {
            sendMoneyButton.backgroundColor = buttonBackgroundColor
        }
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == recipientPhoneNumberTextField {
            commentTextField.becomeFirstResponder()
        } else if textField == commentTextField {
            enterAmountTextField.becomeFirstResponder()
        } else if textField == enterAmountTextField {
            sendMoneyTapped()
        }
        
        return true
    }
}


