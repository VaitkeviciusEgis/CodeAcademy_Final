//
//  HomeViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit

extension HomeViewController: UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else {
            print("ViewModel != ViewModel")
            return 0
        }
 
        print("count \( viewModel.fetchedResultsController?.fetchedObjects?.count ?? 0)")
        let lastFiveTransactions = viewModel.fetchedResultsController?.fetchedObjects?.suffix(5)
        return min(lastFiveTransactions?.count ?? 0, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt() called for indexPath: \(indexPath)")
        guard let viewModel = self.viewModel else {
            print("ViewModel != ViewModel")
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier, for: indexPath) as! ListCell
        guard let transaction = viewModel.fetchedResultsController?.object(at: indexPath) else {
            return UITableViewCell()
        }
        cell.configure(with: transaction)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
        
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


class HomeViewController: UIViewController {
    

    var tableView = UITableView()
    let cardView = UIView()
    let balanceLabel = UILabel()
    let cardholderLabel = UILabel()
    let companyLabel = UILabel()
    let eurSymbol = "\u{20AC}"
    var loggedInUser: UserAuthenticationResponse?
//    var updatedLoggedInUser: UserAuthenticationResponse?
    var serviceAPI: ServiceAPI?
    let formatter = NumberFormatter()
    private var showHideButton: UIButton!
    private var isTableViewHidden = false
    var viewModel: TransactionsViewModel?
    var transactions: [TransactionInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCardView()
        setupShowHideButton()
        setupUI()
        let balance = loggedInUser?.accountInfo.balance ?? 0
        balanceLabel.text = formatter.string(from: NSNumber(value: balance))
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCardHolderLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didTransferMoneySuccessfully(_:)), name: NSNotification.Name(rawValue: "didTransferMoneySuccessfully"), object: nil)
//        fetchTransactions()
    }
    
    
    //MARK: - Action
    private func loadData() {
        guard let viewModel = self.viewModel else {
            print("ViewModel != ViewModel")
            return
        }
        viewModel.retrieveDataFromCoreData()
    }

    private func setupShowHideButton() {
        showHideButton = UIButton(type: .system)
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        showHideButton.setTitle("Hide Last Transactions", for: .normal)
        showHideButton.addTarget(self, action: #selector(toggleTableView), for: .touchUpInside)
        view.addSubview(showHideButton)
        
        NSLayoutConstraint.activate([
            //              showHideButton.centerXAnchor.constraint(equalTo: balanceLabel.centerXAnchor),
            //              showHideButton.topAnchor.constraint(equalTo:  balanceLabel.bottomAnchor)
            showHideButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            showHideButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            
            
            
        ])
    }
    
    @objc private func toggleTableView() {
        UIView.animate(withDuration: 1) { // Change the duration as needed
            self.tableView.alpha = self.tableView.alpha == 0 ? 1 : 0
        }
        isTableViewHidden = !isTableViewHidden
        let title = isTableViewHidden ? "Show Last Transactions" : "Hide Last Transactions"
        showHideButton.setTitle(title, for: .normal)
        tableView.isHidden = isTableViewHidden
    }
    
    
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 1
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        // Add constraints to position the table view 0 points from the top safe area
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 200)
            
        ])
        // Register any necessary cells or headers/footers
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
        
        // Set the table view's data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // Add the cardView as a subview of the tableView's superview
        view.addSubview(cardView)
    }
    
    func setupCardHolderLabel() {
        guard let loggedInUser = loggedInUser, let phoneNumber = loggedInUser.accountInfo.ownerPhoneNumber else {
            return
        }
        cardholderLabel.text = "Cardholder: \(String(describing: phoneNumber))"
    }
    
    @objc func didTransferMoneySuccessfully(_ notification: Notification) {
        DispatchQueue.main.async {
            // Update balance with updated balance from notification userInfo dictionary
            if let userInfo = notification.userInfo,
               let updatedBalance = userInfo["currentBalance"] as? Double {
                // Update the balance of loggedInUser
                self.loggedInUser?.accountInfo.balance = updatedBalance
                
                // Update the balance label text
                self.balanceLabel.text = self.formatter.string(from: NSNumber(value: updatedBalance))
            }
        }
    }
    
    
    func setupCardView() {
        
        //Set up NumberFormatter
        formatter.numberStyle = .currency
        formatter.currencySymbol = eurSymbol
        
        
        // Set up the balance label
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.minimumScaleFactor = 0.5
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 24)
        balanceLabel.textColor = .white
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
        cardView.backgroundColor = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        cardView.layer.cornerRadius = 10
        //        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Set up the cardholder label
        cardholderLabel.font = UIFont.systemFont(ofSize: 16)
        cardholderLabel.textColor = .white
        cardholderLabel.textAlignment = .left
        cardholderLabel.text = "Cardholder: \(loggedInUser?.accountInfo.ownerPhoneNumber ?? "")"
        cardView.addSubview(cardholderLabel)
        cardholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardholderLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            cardholderLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardholderLabel.widthAnchor.constraint(equalToConstant: 180),
            cardholderLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        // Set up the company label
        companyLabel.font = UIFont.boldSystemFont(ofSize: 18)
        companyLabel.textColor = .white
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
    
    func setupUI() {
        
        view.backgroundColor = .systemTeal
        // Set up the Add Money button
        let addMoneyButton = UIButton(type: .system)
        addMoneyButton.setTitle("Add Money", for: .normal)
        addMoneyButton.setTitleColor(.white, for: .normal)
        addMoneyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addMoneyButton.layer.cornerRadius = 8
        addMoneyButton.layer.borderWidth = 1
        addMoneyButton.layer.borderColor = UIColor.white.cgColor
        addMoneyButton.addTarget(self, action: #selector(addMoneyButtonTapped), for: .touchUpInside)
        
        view.addSubview(addMoneyButton)
        addMoneyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addMoneyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addMoneyButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 12),
            addMoneyButton.widthAnchor.constraint(equalToConstant: 120),
            addMoneyButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    @objc func addMoneyButtonTapped() {
        let alertController = UIAlertController(title: "Amount", message: "Please enter the amount:", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter amount"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { action in
            guard let amountText = alertController.textFields?.first?.text, let amount = Double(amountText), let userId = self.loggedInUser?.accountInfo.id else {
                // Invalid input
                return
            }
            
            // Do something with the amount value, such as sending it to a server or storing it locally
            print("Amount entered: \(amount)")
            self.serviceAPI?.addMoney(accountId: userId, amountToAdd: amount) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(let response):
                        
                        UIAlertController.showErrorAlert(title: "Success!",
                                                         message: "Your deposit was successful!",
                                                         controller: self)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.formatter.numberStyle = .currency
                            self.formatter.currencySymbol = self.eurSymbol
//                            let balance = response.balance
//                            self.balanceLabel.text = self.formatter.string(from: NSNumber(value: balance))
//                            self.loggedInUser?.accountInfo.balance = response.balance

   

                        }
                        
                        
                    case .failure(let error):
                        UIAlertController.showErrorAlert(title: "Error with status code: \(error.statusCode)",
                                                         message: error.localizedDescription,
                                                         controller: self)
                }
            }
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}

//extension HomeViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
////        return 5
//
//
////        let lastFiveTransactions = transactions.suffix(5)
////        return min(lastFiveTransactions.count, 5)
//        return transactions.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier) ?? UITableViewCell()
//
//
//         let lastFiveTransactions = Array(transactions.suffix(5))
//         if indexPath.row < lastFiveTransactions.count {
//             let transaction = lastFiveTransactions[lastFiveTransactions.count - 1 - indexPath.row]
//             cell.textLabel?.text = transaction.receiverPhoneNumber
//         }
//         return cell
//     }
//
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 40    }
//}
