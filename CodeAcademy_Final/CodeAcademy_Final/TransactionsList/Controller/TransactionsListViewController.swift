//
//  TransactionsListViewController.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit
import CoreData

// MARK: - TransactionsFetching Protocol

protocol TransactionsFetching {
    func fetchTransactions()
}

// MARK: - TransactionsListViewController

class TransactionsListViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var inAndOutTransactions: UISegmentedControl!
    
    // MARK: Properties
    
    let searchBar = UISearchBar()
    var viewModel: TransactionsViewModel?
    var currentLoggedInAccount: AccountEntity!
    private let didReceiveTransferMoneyNotification = Notification.Name("didReceiveTransferMoneyNotification")
    private var filterType = "Ingoing"
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        viewModel?.retrieveDataFromCoreData()
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
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
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
    
    // MARK: Actions
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = true

        if let searchController = navigationItem.searchController {
            // Setup clear button for search bar
            let clearButton = UIButton(type: .custom)
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            clearButton.addTarget(self, action: #selector(clearSearchBar), for: .touchUpInside)

            if let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                textFieldInsideSearchBar.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 10))
                textFieldInsideSearchBar.rightView = clearButton
                textFieldInsideSearchBar.rightViewMode = .whileEditing
                textFieldInsideSearchBar.textColor = .label
                textFieldInsideSearchBar.tintColor = .label
                textFieldInsideSearchBar.backgroundColor = .systemGray5
                textFieldInsideSearchBar.layer.cornerRadius = 10
                textFieldInsideSearchBar.layer.masksToBounds = true
            }

            // Setup appearance of search bar
            let searchBarAppearance = UINavigationBarAppearance()
            searchBarAppearance.backgroundColor = .systemGray6
            searchBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            searchBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            searchController.searchBar.searchTextField.backgroundColor = .systemGray5
            searchController.searchBar.searchTextField.layer.cornerRadius = 10
            searchController.searchBar.searchTextField.layer.masksToBounds = true
            searchController.searchBar.tintColor = .label
            searchController.searchBar.barTintColor = .systemGray6
        }
    }

    @objc func clearSearchBar() {
        searchBar.text = ""
//        viewModel?.filterTransactions(with: searchBar.text)
        tableView.reloadData()
    }
    
    @objc func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filterType = "Ingoing"
        case 1:
            filterType = "Outgoing"
        default:
            break
        }

        // Reload the table view with the filtered transactions
        tableView.reloadData()
    }
    
    @objc private func handleTransferMoneyNotification() {
        viewModel?.retrieveDataFromCoreData()
        tableView.reloadData()
    }
    
    // MARK: Private Methods
    
    private func segmentSetup() {
        inAndOutTransactions.setTitle("Ingoing", forSegmentAt: 0)
        inAndOutTransactions.setTitle("Outgoing", forSegmentAt: 1)
        inAndOutTransactions.selectedSegmentIndex = 0 // Set the initial valu
        inAndOutTransactions.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged) // Add the segment change action
    }
    
    // MARK: Public Methods
    
    func updateTableView() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension TransactionsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else {
            print("ViewModel != ViewModel")
            return 0
        }
        
        let transactions = viewModel.fetchedResultsController?.fetchedObjects ?? []
        
        switch filterType {
                
            case "Ingoing":
                return transactions.filter { $0.receivingAccountId == currentLoggedInAccount.id }.count
            case "Outgoing":
                return transactions.filter { $0.sendingAccountId == currentLoggedInAccount.id  }.count
            default:
                return transactions.filter { $0.receivingAccountId == currentLoggedInAccount.id  || $0.sendingAccountId == currentLoggedInAccount.id  }.count
        }
    }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            print("cellForRowAt() called for indexPath: \(indexPath)")
            guard let viewModel = self.viewModel else {
                print("ViewModel != ViewModel")
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier, for: indexPath) as! ListCell
    
            let transactions = viewModel.fetchedResultsController?.fetchedObjects ?? []
            let filteredTransactions: [TransactionEntity]
    
            switch filterType {
            case "Ingoing":
                filteredTransactions = transactions.filter { $0.receivingAccountId == currentLoggedInAccount.id }
            case "Outgoing":
                filteredTransactions = transactions.filter { $0.sendingAccountId == currentLoggedInAccount.id }
            default:
                filteredTransactions = transactions.filter { $0.sendingAccountId == currentLoggedInAccount.id || $0.receivingAccountId == currentLoggedInAccount.id }
            }
    
            if indexPath.row < filteredTransactions.count {
                let transaction = filteredTransactions[indexPath.row]
                cell.configure(with: transaction)
    
                cell.backgroundColor = .systemGray6
            } else {
                cell.textLabel?.text = "No data"
            }
    
            return cell
        }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 64
    
        }
}

extension TransactionsListViewController: UITableViewDelegate {
    
    
}
//import UIKit
//import CoreData
//
//protocol TransactionsFetching {
//    func fetchTransactions()
//}
//
//extension TransactionsListViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let viewModel = self.viewModel else {
//            print("ViewModel != ViewModel")
//            return 0
//        }
//
//        let transactions = viewModel.fetchedResultsController?.fetchedObjects ?? []
//
//        switch filterType {
//
//        case "Ingoing":
//                return transactions.filter { $0.receivingAccountId == currentLoggedInAccount.id }.count
//        case "Outgoing":
//            return transactions.filter { $0.sendingAccountId == currentLoggedInAccount.id  }.count
//        default:
//            return transactions.filter { $0.receivingAccountId == currentLoggedInAccount.id  || $0.sendingAccountId == currentLoggedInAccount.id  }.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cellForRowAt() called for indexPath: \(indexPath)")
//        guard let viewModel = self.viewModel else {
//            print("ViewModel != ViewModel")
//            return UITableViewCell()
//        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier, for: indexPath) as! ListCell
//
//        let transactions = viewModel.fetchedResultsController?.fetchedObjects ?? []
//        let filteredTransactions: [TransactionEntity]
//
//        switch filterType {
//        case "Ingoing":
//            filteredTransactions = transactions.filter { $0.receivingAccountId == currentLoggedInAccount.id }
//        case "Outgoing":
//            filteredTransactions = transactions.filter { $0.sendingAccountId == currentLoggedInAccount.id }
//        default:
//            filteredTransactions = transactions.filter { $0.sendingAccountId == currentLoggedInAccount.id || $0.receivingAccountId == currentLoggedInAccount.id }
//        }
//
//        if indexPath.row < filteredTransactions.count {
//            let transaction = filteredTransactions[indexPath.row]
//            cell.configure(with: transaction)
//
//            cell.backgroundColor = .systemGray6
//        } else {
//            cell.textLabel?.text = "No data"
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 64
//
//    }
//
//}
//
//class TransactionsListViewController: UIViewController, UpdateTableViewDelegate, UITableViewDelegate, NSFetchedResultsControllerDelegate {
//
//
//
//
//    let didReceiveTransferMoneyNotification = Notification.Name("didReceiveTransferMoneyNotification")
//
//    var viewModel: TransactionsViewModel?
//
//    var currentLoggedInAccount: AccountEntity!
//    var filterType = "Ingoing"
//
//    private func loadData() {
//        guard let viewModel = self.viewModel else {
//            print("ViewModel != ViewModel")
//            return
//        }
//        viewModel.retrieveDataFromCoreData()
//    }
//
//
//
//    // Update the tableView if changes have been made
//    func reloadData(sender: TransactionsViewModel) {
//        self.tableView.reloadData()
//    }
//
//    func setupTableView() {
//        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.backgroundColor = .systemGray6
//        tableView.separatorStyle = .none
//
//    }
//
//    @IBOutlet weak var inAndOutTransactions: UISegmentedControl!
//
//    var loggedInUser: UserAuthenticationResponse?
//    let searchBar = UISearchBar()
//    var serviceAPI: ServiceAPI?
//
//
//    @IBOutlet weak var tableView: UITableView!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemGray6
//        setupSearchBar()
//        segmentSetup()
////        NotificationCenter.default.addObserver(self, selector: #selector(handleTransferMoneyNotification), name: didReceiveTransferMoneyNotification, object: nil)
//
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("ViewDidAppear")
//        setupTableView()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(false)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleTransferMoneyNotification), name: didReceiveTransferMoneyNotification, object: nil)
//        loadData()
//        tableView.reloadData()
//    }
//
//
//    func segmentSetup() {
//
//        inAndOutTransactions.setTitle("Ingoing", forSegmentAt: 0)
//           inAndOutTransactions.setTitle("Outgoing", forSegmentAt: 1)
//           inAndOutTransactions.selectedSegmentIndex = 0 // Set the initial value
//
//           inAndOutTransactions.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged) // Add the segment change action
//
//
//
//    }
//
//
//    @objc func segmentValueChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            filterType = "Ingoing"
//        case 1:
//            filterType = "Outgoing"
//        default:
//            break
//        }
//
//        // Reload the table view with the filtered transactions
//        tableView.reloadData()
//    }
//
//    @objc func handleTransferMoneyNotification() {
//        // Reload data here...
//        loadData()
//        tableView.reloadData()
//    }
//    // for testing purpose
//    //                    let url = URL(string: "http://134.122.94.77:7000/api/User/")!
//    //                    serviceAPI?.fetchingUsers(url: url) { [weak self] user in
//    //                        guard let self = self else {
//    //                            return
//    //                        }
//    //                        var usersArray = [Transaction]()
//    //                        usersArray = user
//    //                        for user in usersArray {
//    //                            print("id: \(user.id), phone: \(user.phoneNumber)")
//    //                            // Replace "username" and "email" with the actual properties of your User type
//    //                        }
//    //                    }
//
//
//
//    func setupSearchBar() {
//        searchBar.delegate = self
//        searchBar.placeholder = "Search"
//        navigationItem.searchController = UISearchController(searchResultsController: nil)
//        navigationItem.hidesSearchBarWhenScrolling = true
//
//        let clearButton = UIButton(type: .custom)
//        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
//        clearButton.addTarget(self, action: #selector(clearSearchBar), for: .touchUpInside)
//        searchBar.addSubview(clearButton)
//
//    }
//
//    @objc func clearSearchBar() {
//        searchBar.text = ""
//    }
//
//}
//
//extension TransactionsListViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        // Perform search here
//    }
//}
