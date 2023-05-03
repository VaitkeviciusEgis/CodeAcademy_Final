//
//  HomeViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit


class HomeViewController: UIViewController, CoreDataLoading {
    
    //MARK: Properties
    
    var loggedInUser: UserAuthenticationResponse?
    var serviceAPI: ServiceAPI?
    var viewModel: TransactionsViewModel?
    let tableView = UITableView(frame: .zero, style: .plain)
    private  let addMoneyButton = UIButton(type: .system)
    private var showHideButton = UIButton(type: .system)
    private var isTableViewHidden = false
    private let cardView = UIView()
    private let balanceLabel = UILabel()
    private let cardholderLabel = UILabel()
    private let companyLabel = UILabel()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(transactionSuccessful(_:)), name: NSNotification.Name("TransactionSuccessful"), object: nil)
    }
    
    @objc func transactionSuccessful(_ notification: Notification) {
        // Reload table view data
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayNewBalance()
        setupCardHolderLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadCoreData()
        tableView.reloadData()
        
    }
    
    //MARK: - Action
    
    private func setupShowHideButton() {
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        showHideButton.setTitle("Hide Last Transactions", for: .normal)
        showHideButton.setTitleColor(UIColor(red: 18/255, green: 184/255, blue: 218/255, alpha: 1), for: .normal)
        showHideButton.addTarget(self, action: #selector(toggleTableView), for: .touchUpInside)
        view.addSubview(showHideButton)
        
        NSLayoutConstraint.activate([
            showHideButton.centerXAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -100),
            showHideButton.topAnchor.constraint(equalTo:  cardView.topAnchor, constant: 16)
        ])
    }
    
    internal func loadCoreData() {
        guard let viewModel else {
            return
        }
        viewModel.retrieveDataFromCoreData()
    }
    
    private func hideButton() {
        showHideButton.isHidden = true
    }
    
    private func setupUI() {
        view.backgroundColor = cardPayBackgroundColor
        setupTableView()
        setupCardView()
        setupAddMoneyButton()
    }
    
    private func displayNewBalance() {
        let balance = loggedInUser?.accountInfo.balance ?? 0
        balanceLabel.text = currencyFormatter().string(from: NSNumber(value: balance))
    }
    
    private func setupDelegates() {
        tableView.dataSource = self
        tableView.register(ListCell.self, forCellReuseIdentifier: listIdentifier)
    }
    
    private func setupTableView() {
        tableView.layer.opacity = 0
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 6
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        tableView.backgroundColor = UIColor(red: 78/255, green: 129/255, blue: 123/255, alpha: 1)
        view.addSubViews([tableView, cardView])
        setupTableViewConstrains()
        setupDelegates()
    }
    
    private func setupTableViewConstrains() {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 6),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -6),
            tableView.heightAnchor.constraint(equalToConstant: 220),
        ])
    }
    
    private func setupCardHolderLabel() {
        guard let loggedInUser = loggedInUser, let phoneNumber = loggedInUser.accountInfo.ownerPhoneNumber else {
            return
        }
        let cardholder = "Cardholder: "
        cardholderLabel.text = "\(cardholder) \(String(describing: phoneNumber))"
        cardholderLabel.textColor = UIColor(ciColor: .gray)
    }
    
    private func setupCardBalanceLabelConstraints() {
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            balanceLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            balanceLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            balanceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            balanceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBalanceLabel() {
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.minimumScaleFactor = 0.5
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 32)
        balanceLabel.textColor = UIColor(red: 235/255, green: 242/255, blue: 250/255, alpha: 1)
        balanceLabel.textAlignment = .center
    }
    
    private func setupCardViewConstraints() {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    private func setupCardView() {
        setupBalanceLabel()
        cardView.addSubview(balanceLabel)
        setupCardBalanceLabelConstraints()
        setupCardViewConstraints()
        cardView.backgroundColor = cardViewBackgroundColor
        cardView.layer.cornerRadius = 10
        cardView.layer.borderColor = borderColor
        cardView.layer.borderWidth = 1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        setupCardHolder()
        setupCardHolderConstraints()
        setupCompanyLabel()
        setupCompanyLabelConstraints()
        
        cardView.layer.shadowColor = CGColor(red: 41/255, green: 44/255, blue: 53/255, alpha: 1)
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 4
        cardView.layer.masksToBounds = false
        
    }
    
    private func setupCompanyLabel() {
        companyLabel.font = UIFont.boldSystemFont(ofSize: 18)
        companyLabel.textColor = UIColor(red: 135/255, green: 179/255, blue: 122/255, alpha: 1)
        companyLabel.textAlignment = .left
        companyLabel.text = "CardPay"
        cardView.addSubview(companyLabel)
    }
    
    private func setupCompanyLabelConstraints() {
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            companyLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            companyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            companyLabel.widthAnchor.constraint(equalToConstant: 100),
            companyLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupCardHolder() {
        cardholderLabel.font = UIFont.systemFont(ofSize: 16)
        cardholderLabel.textAlignment = .left
        cardholderLabel.text = "Cardholder: \(loggedInUser?.accountInfo.ownerPhoneNumber ?? "")"
        cardholderLabel.adjustsFontSizeToFitWidth = true
        cardholderLabel.minimumScaleFactor = 0.5
        cardView.addSubview(cardholderLabel)
    }
    
    private func setupCardHolderConstraints() {
        cardholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardholderLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            cardholderLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardholderLabel.widthAnchor.constraint(equalToConstant: 400),
            cardholderLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupAddMoneyButton() {
        addMoneyButton.setTitle("Add Money", for: .normal)
        addMoneyButton.setTitleColor(UIColor(red: 41/255, green: 44/255, blue: 53/255, alpha: 1), for: .normal)
        addMoneyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addMoneyButton.layer.cornerRadius = 8
        addMoneyButton.layer.borderWidth = 1
        addMoneyButton.layer.borderColor = borderColor
        addMoneyButton.backgroundColor = buttonBackgroundColor
        addMoneyButton.layer.opacity = 0.5
        addMoneyButton.addTarget(self, action: #selector(addMoneyButtonTapped), for: .touchUpInside)
        view.addSubview(addMoneyButton)
        setupAddMoneyButtonConstraints()
    }
    
    private func setupAddMoneyButtonConstraints() {
        addMoneyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addMoneyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addMoneyButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            addMoneyButton.widthAnchor.constraint(equalToConstant: 120),
            addMoneyButton.heightAnchor.constraint(equalToConstant: 40),
            addMoneyButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -8),
            
        ])
    }
    
    @objc private func addMoneyButtonTapped() {
        let alertController = UIAlertController(title: "CardPay", message: "Please enter the amount:", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter amount"
            textField.keyboardType = .decimalPad
            textField.delegate = self
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { action in
            
            guard let amountText = alertController.textFields?.first?.text,
                  let amount = Double(amountText),
                  let userId = self.loggedInUser?.accountInfo.id else {
                UIAlertController.showErrorAlert(title: "Declined", message: "Amount can'be empty, have negative numbers or symbols. Please try again", controller: self)
                
                return
            }
            
            self.serviceAPI?.addMoney(accountId: userId, amountToAdd: amount) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    case .success(let response):
                        UIAlertController.showErrorAlert(title: "Success!",
                                                         message: "Your deposit was successful!",
                                                         controller: self)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let balance = response.balance
                            self.balanceLabel.text = currencyFormatter().string(from: NSNumber(value: balance))
                            self.loggedInUser?.accountInfo.balance = response.balance
                        }
                        
                    case .failure(let error):
                        
                        UIAlertController.showErrorAlert(title: "\(errorStatusCodeMessage) \(error.statusCode)",
                                                         message: "Amount can't be negative or have symbols",
                                                         controller: self)
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    @objc private func toggleTableView() {
        UIView.animate(withDuration: 0.1) { // Change the duration as needed
            self.tableView.alpha = self.tableView.alpha == 0 ? 1 : 0
        }
        isTableViewHidden = !isTableViewHidden
        let title = isTableViewHidden ? "Show Last Transactions" : "Hide Last Transactions"
        showHideButton.setTitle(title, for: .normal)
        tableView.isHidden = isTableViewHidden
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else {
            return 0
        }
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: listIdentifier, for: indexPath) as? ListCell
        guard let transaction = viewModel.fetchedResultsController?.object(at: indexPath), let cell = cell else {
            return UITableViewCell()
        }
        tableView.layer.opacity = 0.8
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(red: 78/255, green: 129/255, blue: 123/255, alpha: 1)
        
        
        cell.configureCell(with: transaction)
        setupShowHideButton()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewHeightForRow
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        let newLength = currentText.count + string.count - range.length
        if newLength >= allowedCharacters.count || currentText == "0" ||  currentText.isEmpty && string == "0" {
            return false
        }
        return textField.validatePhoneNumber(allowedCharacters: allowedCharacters, replacementString: string)
    }
    
    private func textFieldShouldPaste(_ textField: UITextField) -> Bool {
        return false
    }
    
}


