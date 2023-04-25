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

class TransactionsListViewController: UIViewController, UpdateTableViewDelegate, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    
   
    let didReceiveTransferMoneyNotification = Notification.Name("didReceiveTransferMoneyNotification")

    var viewModel: TransactionsViewModel?
    
    var currentLoggedInAccount: AccountEntity!
    var filterType = "Ingoing"
//    private var viewModel = TransactionsViewModel()
    
    private func loadData() {
        guard let viewModel = self.viewModel else {
            print("ViewModel != ViewModel")
            return
        }
        viewModel.retrieveDataFromCoreData()
    }
    

    
    // Update the tableView if changes have been made
    func reloadData(sender: TransactionsViewModel) {
        self.tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .none
        
    }
    
    @IBOutlet weak var inAndOutTransactions: UISegmentedControl!
    
    var loggedInUser: UserAuthenticationResponse?
    let searchBar = UISearchBar()
    var serviceAPI: ServiceAPI?
    

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupSearchBar()
        segmentSetup()
//        NotificationCenter.default.addObserver(self, selector: #selector(handleTransferMoneyNotification), name: didReceiveTransferMoneyNotification, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppear")
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTransferMoneyNotification), name: didReceiveTransferMoneyNotification, object: nil)
        loadData()
        tableView.reloadData()
    }


    func segmentSetup() {
        
        inAndOutTransactions.setTitle("Ingoing", forSegmentAt: 0)
           inAndOutTransactions.setTitle("Outgoing", forSegmentAt: 1)
           inAndOutTransactions.selectedSegmentIndex = 0 // Set the initial value
           
           inAndOutTransactions.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged) // Add the segment change action

        
        
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
    
    @objc func handleTransferMoneyNotification() {
        // Reload data here...
        loadData()
        tableView.reloadData()
    }
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
    
    
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = true
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearSearchBar), for: .touchUpInside)
        searchBar.addSubview(clearButton)
        
    }
    
    @objc func clearSearchBar() {
        searchBar.text = ""
    }
    
}

extension TransactionsListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        // Perform search here
    }
}
