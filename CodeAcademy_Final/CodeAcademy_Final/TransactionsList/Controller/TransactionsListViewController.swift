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
 
        print("count \( viewModel.fetchedResultsController?.fetchedObjects?.count ?? 0)")
        return viewModel.fetchedResultsController?.fetchedObjects?.count ?? 0
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
    
}

class TransactionsListViewController: UIViewController, UpdateTableViewDelegate, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
   


    var viewModel: TransactionsViewModel?
    

  
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
        tableView.backgroundColor = .systemTeal
    }
    
    @IBOutlet weak var inAndOutTransactions: UISegmentedControl!
    
    var loggedInUser: UserAuthenticationResponse?
    let searchBar = UISearchBar()
    var serviceAPI: ServiceAPI?
    

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        segmentSetup()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppear")
        setupTableView()
        loadData()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)

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
