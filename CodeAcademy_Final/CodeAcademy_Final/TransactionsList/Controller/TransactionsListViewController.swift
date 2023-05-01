//
//  TransactionsListViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit
import CoreData


protocol TransactionsFetching {
    func fetchTransactions()
}

class TransactionsListViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var inAndOutTransactions: UISegmentedControl!
    
    // MARK: Properties
    
    private var filteredTransactions: [TransactionEntity] = []
    var transferVC: TransferViewController?
    var viewModel: TransactionsViewModel?
    var currentLoggedInAccount: AccountEntity?
    private var filterType: FilterType = .ingoing
    private let didReceiveTransferMoneyNotification = Notification.Name("didReceiveTransferMoneyNotification")
    var loggedInUser: UserAuthenticationResponse?
    enum FilterType: Int {
        case ingoing = 0
        case outgoing = 1
        case all = 2
    }

    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupTableView()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK: Configuration
    
    private func configureView() {
        view.backgroundColor = .systemGray6
        segmentSetup()
        setupSearchBar()
    }
    
    private func setupTableView() {
        guard let tableView = tableView else {
            return
        }
        tableView.register(ListCell.self, forCellReuseIdentifier: listIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .none
    }
    
    // MARK: Observers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTransferMoneyNotification), name: didReceiveTransferMoneyNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: didReceiveTransferMoneyNotification, object: nil)
    }
    
    //MARK: - Setup
    
    func setupSearchBar() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Setup clear button for search bar
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearSearchBar), for: .touchUpInside)
        searchBar.returnKeyType = .search
        searchBar.inputViewController?.navigationItem.hidesSearchBarWhenScrolling = true
        searchBar.searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 10))
        searchBar.searchTextField.rightView = clearButton
        searchBar.searchTextField.rightViewMode = .whileEditing
        searchBar.searchTextField.textColor = .label
        searchBar.searchTextField.tintColor = .label
        searchBar.searchTextField.backgroundColor = .systemGray5
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.tintColor = .label
        searchBar.barTintColor = .systemGray6
        searchBar.backgroundColor = .systemGray6
    }
    
    // MARK: Actions
    
    @objc private func clearSearchBar() {
        searchBar.text = ""
        //        viewModel?.filterTransactions(with: searchBar.text)
        updateTableView()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                filterType = .ingoing
            case 1:
                filterType = .outgoing
            case 2:
                filterType = .all
            default:
                break
        }
        updateTableView()
    }
    
    @objc private func handleTransferMoneyNotification() {
        updateTableView()
    }
    
    private func loadData() {
        guard let viewModel = self.viewModel else {
            return
        }
        viewModel.retrieveDataFromCoreData()
        updateTableView()
    }
    
    // MARK: Private Methods
    
    private func segmentSetup() {
        inAndOutTransactions.setTitle("Ingoing", forSegmentAt: 0)
        inAndOutTransactions.setTitle("Outgoing", forSegmentAt: 1)
        inAndOutTransactions.selectedSegmentIndex = 0 // Set the initial valu
        inAndOutTransactions.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged) // Add the segment change action
    }
    
   private func updateTableView() {
        self.tableView?.reloadData()
    }
    
    @objc private func repeatTransaction(_ transaction: TransactionEntity) {
        var fromAccount: Int
        var fromPhoneNumber: String
        var toPhoneNumber: String
        var amount: Double
        var comment: String
        
        fromAccount = Int(transaction.sendingAccountId)
        fromPhoneNumber = transaction.senderPhoneNumber ?? ""
        toPhoneNumber = transaction.receiverPhoneNumber ?? ""
        amount = transaction.amount
        comment = transaction.comment ?? ""

        // Create a new transaction entity with the same details
        guard let viewContext = CoreDataManager.sharedInstance.container?.viewContext else {
            return
        }
        
        let repeatedTransaction = TransactionEntity(context: viewContext)
        repeatedTransaction.amount = amount
        repeatedTransaction.sendingAccountId = Int32(fromAccount)
        repeatedTransaction.senderPhoneNumber = fromPhoneNumber
        repeatedTransaction.comment = comment
        repeatedTransaction.receiverPhoneNumber = toPhoneNumber
        
        // Create the alert
        let alert = UIAlertController(title: "Repeat Transaction", message: "Do you want to repeat this transaction?", preferredStyle: .alert)
        
        // Add the repeat action
        let repeatAction = UIAlertAction(title: "Repeat", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Get the authentication token from the keychain
            guard let authToken = keyChain.get(keyAccessToken) else {
                return
            }

            // Call your existing function that handles performing a transaction
            transferVC?.serviceAPI?.transferMoney(senderPhoneNumber: fromPhoneNumber, token: authToken, senderAccountId: fromAccount, receiverPhoneNumber: toPhoneNumber, amount: amount, comment: comment, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(_):
                        var currentBalance = loggedInUser?.accountInfo.balance
                        let newBalance = (currentBalance ?? 0) - amount
                        currentBalance = newBalance // update currentBalance with the new balance
                        loggedInUser?.accountInfo.balance = newBalance // update loggedInUser with the new balance
                        
                 
//
                        let message = "Transaction completed"
                        // Reload the table view
                        DispatchQueue.main.async {
                            self.transferVC?.didTransferMoneySuccessfully()
                        }
                        UIAlertController.showErrorAlert(title: "Success!", message: message, controller: self)

                    case .failure(let error):
                        UIAlertController.showErrorAlert(title: error.message ?? "",
                                                         message: "\(errorStatusCodeMessage) \(error.statusCode)",
                                                         controller: self)
                }
            })
        }
        alert.addAction(repeatAction)
        
        // Add the cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true)
    }
}

extension TransactionsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else {
            return 0
        }
        let transactions = viewModel.fetchedResultsController?.fetchedObjects ?? []
        
        switch filterType {
            case .ingoing:
                return transactions.filter { $0.receivingAccountId == currentLoggedInAccount?.id ?? -1 }.count
            case .outgoing:
                return transactions.filter { $0.sendingAccountId == currentLoggedInAccount?.id ?? -1 }.count
            case .all:
                return transactions.filter { $0.receivingAccountId == currentLoggedInAccount?.id ?? -1 || $0.sendingAccountId == currentLoggedInAccount?.id  ?? -1}.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: listIdentifier, for: indexPath) as? ListCell
        guard let cell = cell else {
            return UITableViewCell()
        }
        let transactions = viewModel.fetchedResultsController?.fetchedObjects ?? []
        
        
        switch filterType {
            case .ingoing:
                filteredTransactions = transactions.filter { $0.receivingAccountId == currentLoggedInAccount?.id ?? -1 }
            case .outgoing:
                filteredTransactions = transactions.filter { $0.sendingAccountId == currentLoggedInAccount?.id ?? -1}
            case .all:
                filteredTransactions = transactions
        }
        
        if indexPath.row < filteredTransactions.count {
            let transaction = filteredTransactions[indexPath.row]
            
            cell.configureCell(with: transaction)
            
            cell.backgroundColor = .systemGray6
        } else {
            cell.textLabel?.text = "No data"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewHeightForRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        

        guard filterType == .outgoing else {
            // User can only repeat/cancel outgoing transactions
            return
        }

        let transaction = filteredTransactions[indexPath.row]
        repeatTransaction(transaction)
    }
}

extension TransactionsListViewController: UISearchDisplayDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true // show cancel button
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false // hide cancel button
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // dismiss keyboard
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //        print("\(searchText)")
        //        if !searchText.isEmpty {
        //            var predicate: NSPredicate = NSPredicate()
        //            predicate = NSPredicate(format: "name contains[c] '\(searchText)'")
        //            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //            let managedObjectContext = appDelegate.persistentContainer.viewContext
        //            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Contact")
        //            fetchRequest.predicate = predicate
        //            do {
        ////                contacts = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        //            } catch let error as NSError {
        //                print("Could not fetch. \(error)")
        //            }
        //        }
        //        tableView.reloadData()
        //    }
    }
}
