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
        print("numberOfRowsInSection() called")
//        let transactions = viewModel.fetchedResultsController?.fetchedObjects ?? []
//            return transactions.count
        print("numberOfRowsInSection() called")
        return viewModel.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt() called")
        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier, for: indexPath) as! ListCell
        guard let transaction = viewModel.fetchedResultsController?.object(at: indexPath) else {
            return UITableViewCell() }
        cell.configure(with: transaction)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier, for: indexPath) as! ListCell
//
//        if let transaction = viewModel.fetchedResultsController?.object(at: indexPath) {
//            cell.titleLabel.text = transaction.receiverPhoneNumber
//            cell.amountLabel.text = "\(transaction.amount)"
//        }
//
//        return cell
//    }
}

class TransactionsListViewController: UIViewController, UpdateTableViewDelegate, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
//    var transactions: [TransactionInfo] = []
    private var viewModel = TransactionsViewModel()
    
    private func loadData() {
        viewModel.retrieveDataFromCoreData()
    }
    
    // Update the tableView if changes have been made
    func reloadData(sender: TransactionsViewModel) {
        self.tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemTeal
        setupSearchBar()
        segmentSetup()
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
    }
//
//    private func loadTransactionsData() {
//
//        // Fetch data from the server
//        guard let currentAccountId = loggedInUser?.accountInfo.id else  {
//
//            return
//        }
//
//        serviceAPI?.fetchingTransactions(url: URLBuilder.getTaskURL(withId: currentAccountId), completion: { [weak self] (result) in
//
//
//            guard let self = self else {
//                return
//            }
//
//            switch result {
//
//                case .success(let transactions):
//                    CoreDataManager.sharedInstance.saveDataOf(transactions: transactions)
//
//                    self.tableView.reloadData()
//                case .failure(let error):
//                    print("Error processing json data: \(error)")
//            }
//
//
//            self.tableView.reloadData()
//
//        })
//    }
    
//-------------------------------------------------//
    
    @IBOutlet weak var inAndOutTransactions: UISegmentedControl!
    
    var loggedInUser: UserAuthenticationResponse?
//    var currentAccount: AccountEntity?
    let searchBar = UISearchBar()
    var serviceAPI: ServiceAPI?

    func loadTransactionsData() {
        print("loadTransactionsData called")
        guard !viewModel.isDataLoaded else {
            return
        }
         // Fetch data from the server
         guard let currentAccountId = loggedInUser?.accountInfo.id else  {
          
             return
         }
         
         serviceAPI?.fetchingTransactions(url: URLBuilder.getTaskURL(withId: currentAccountId), completion: { [weak self] (result) in
             
             
             guard let self = self else {
                 return
             }
             
             switch result {
                 
                 case .success(let transactions):
                     CoreDataManager.sharedInstance.saveDataOf(transactions: transactions)
                     viewModel.retrieveDataFromCoreData()
                     self.tableView.reloadData()
                     print("Is this reload ?")
               
                 case .failure(let error):
                     print("Error processing json data: \(error)")
             }
             
            
 
            
         })
     }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           print("viewDidLoad() called")
           tableView.delegate = self
           tableView.dataSource = self
           tableView.backgroundColor = .systemTeal
           setupSearchBar()
           segmentSetup()

        

        
        
        // Reload the table view data
//        tableView.reloadData()
       }
       
       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           tableView.reloadData()
           print("ViewDidAppear")
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           // Register table view cell class
           tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
           loadTransactionsData()
           print("viewWillAppear() called")
       }
    
    func segmentSetup() {
        inAndOutTransactions.setTitle("Ingoing", forSegmentAt: 0)
        inAndOutTransactions.setTitle("Outgoing", forSegmentAt: 1)
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
