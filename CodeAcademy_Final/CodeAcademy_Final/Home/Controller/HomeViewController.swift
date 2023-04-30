//
//  HomeViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit


class HomeViewController: UIViewController {
    
    //MARK: Properties
    
    let cardView = UIView()
    let balanceLabel = UILabel()
    let cardholderLabel = UILabel()
    let companyLabel = UILabel()
    var loggedInUser: UserAuthenticationResponse?
    var serviceAPI: ServiceAPI?
    let formatter = currencyFormatter()
    private var showHideButton = UIButton(type: .system)
    private var isTableViewHidden = false
    var viewModel: TransactionsViewModel?
    var transactions: [TransactionInfo] = []
    let addMoneyButton = UIButton(type: .system)
    let cardViewBackgroundColor = UIColor(red: 42/255, green: 175/255, blue: 134/255, alpha: 1)
    let viewBackgroundColor = UIColor(red: 0/255, green: 59/255, blue: 60/255, alpha: 1)
    
    let tableView = UITableView(frame: .zero, style: .plain)
//    let tableViewHeight = 220
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCardView()
        setupAddMoneyButton()
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
    
    private func loadCoreData() {
        guard let viewModel else {
            return
        }
        viewModel.retrieveDataFromCoreData()
    }
    
    private func displayNewBalance() {
        let balance = loggedInUser?.accountInfo.balance ?? 0
        balanceLabel.text = formatter.string(from: NSNumber(value: balance))
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 1
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        // Add constraints to position the table view 0 points from the top safe area
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
//            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 220),
//            tableView.topAnchor.constraint(equalTo: addMoneyButton.bottomAnchor, constant: 60)
        ])
        // Register any necessary cells or headers/footers
        tableView.register(ListCell.self, forCellReuseIdentifier: identifier)
        
        // Set the table view's data source and delegate
        tableView.dataSource = self

        // Add the cardView as a subview of the tableView's superview
        view.addSubview(cardView)
    }
    
    func setupCardHolderLabel() {
        guard let loggedInUser = loggedInUser, let phoneNumber = loggedInUser.accountInfo.ownerPhoneNumber else {
            return
        }
        let cardholder = "Cardholder: "
       
        cardholderLabel.text = "\(cardholder) \(String(describing: phoneNumber))"
        cardholderLabel.textColor = UIColor(ciColor: .gray)
        
    }
    
    func setupCardView() {
        
        //Set up NumberFormatter
        formatter.numberStyle = .currency
        formatter.currencySymbol = eurSymbol
        
        // Set up the balance label
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.minimumScaleFactor = 0.5
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 32)
        
        if loggedInUser?.accountInfo.balance ?? 0 > 0 {
            balanceLabel.textColor = UIColor(red: 31/255, green: 223/255, blue: 100/255, alpha: 1)
        }
        else {
            balanceLabel.textColor = .white
        }
        balanceLabel.textAlignment = .center
        
        cardView.addSubview(balanceLabel)
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            balanceLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            balanceLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            balanceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            balanceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
        // Set up the card view
        
        cardView.backgroundColor = cardViewBackgroundColor
        cardView.layer.cornerRadius = 10
        cardView.layer.borderColor = CGColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        cardView.layer.borderWidth = 1
        //        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 200)
            
        ])
        
        // Set up the cardholder label
        cardholderLabel.font = UIFont.systemFont(ofSize: 16)
        cardholderLabel.textAlignment = .left
        cardholderLabel.text = "Cardholder: \(loggedInUser?.accountInfo.ownerPhoneNumber ?? "")"
        cardholderLabel.adjustsFontSizeToFitWidth = true // Add this line
        cardholderLabel.minimumScaleFactor = 0.5 // Add this line to set the minimum font scale factor
        cardView.addSubview(cardholderLabel)
        cardholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardholderLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            cardholderLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardholderLabel.widthAnchor.constraint(equalToConstant: 400),
            cardholderLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        // Set up the company label
        companyLabel.font = UIFont.boldSystemFont(ofSize: 18)
        companyLabel.textColor = UIColor(red: 214/255, green: 160/255, blue: 86/255, alpha: 1)
        companyLabel.textAlignment = .left
        companyLabel.text = "Card Pay"
        cardView.addSubview(companyLabel)
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            companyLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            companyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            companyLabel.widthAnchor.constraint(equalToConstant: 100),
            companyLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setupAddMoneyButton() {
        
        view.backgroundColor = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        addMoneyButton.setTitle("Add Money", for: .normal)
        addMoneyButton.setTitleColor(.opaqueSeparator, for: .normal)
        addMoneyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addMoneyButton.titleLabel?.textColor = .systemGray6
        addMoneyButton.layer.cornerRadius = 8
        addMoneyButton.layer.borderWidth = 1
        addMoneyButton.layer.borderColor = CGColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        addMoneyButton.addTarget(self, action: #selector(addMoneyButtonTapped), for: .touchUpInside)
        view.addSubview(addMoneyButton)
        addMoneyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addMoneyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addMoneyButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            addMoneyButton.widthAnchor.constraint(equalToConstant: 120),
            addMoneyButton.heightAnchor.constraint(equalToConstant: 40),
            addMoneyButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -8),

        ])
    }
    
    @objc func addMoneyButtonTapped() {
        let alertController = UIAlertController(title: "Card Pay", message: "Please enter the amount:", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter amount"
            textField.keyboardType = .decimalPad
            
            
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
                            self.balanceLabel.text = self.formatter.string(from: NSNumber(value: balance))
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
    
    func hideButton() {
        showHideButton.isHidden = true
    }
    
    //MARK: - Private method
    
    private func setupShowHideButton() {
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        showHideButton.setTitle("Hide Last Transactions", for: .normal)
//        showHideButton.tintColorDidChange()
        showHideButton.addTarget(self, action: #selector(toggleTableView), for: .touchUpInside)
        view.addSubview(showHideButton)
        
        NSLayoutConstraint.activate([
            showHideButton.centerXAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -100),
            showHideButton.topAnchor.constraint(equalTo:  cardView.topAnchor, constant: 16)
        ])
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
        
        let lastFiveTransactions = viewModel.fetchedResultsController?.fetchedObjects?.suffix(5)

        return min(lastFiveTransactions?.count ?? 0, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else {
            hideButton()
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ListCell
        guard let transaction = viewModel.fetchedResultsController?.object(at: indexPath), let cell = cell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configureCell(with: transaction)
//        cell.backgroundColor = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        cell.backgroundColor = UIColor(red: 0/255, green: 59/255, blue: 60/255, alpha: 1)
        setupShowHideButton()
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false for the cells that you want to be non-editable
        return false
    }
}


