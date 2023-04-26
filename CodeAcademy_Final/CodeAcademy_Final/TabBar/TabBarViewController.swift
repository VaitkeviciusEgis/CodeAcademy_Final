//
//  ViewController.swift
//  APITask-Egidijus
//
//  Created by Egidijus Vaitkevičius on 2023-03-01.
//

import UIKit
import CoreData


class TabBarViewController: UITabBarController {
    
    // MARK: - Properties
    
    private let homeVC = HomeViewController()
    private let transactionsVC = TransactionsListViewController()
    private let settingsVC = SettingsViewController()
    private let transferVC = TransferViewController()
    private let viewModel = TransactionsViewModel()
    private var serviceAPI: ServiceAPI?
    private var loggedInAccount: AccountEntity?
    
    lazy var managedContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get the shared app delegate.")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarUI()
    }
    
    // MARK: - Private methods
    
    private func setupTabBarUI() {
        let transactionsViewControllerNavigation = UINavigationController(rootViewController: transactionsVC)
        setViewControllers([homeVC, transactionsViewControllerNavigation, transferVC, settingsVC], animated: true)
        guard let items = tabBar.items else { return }
        let images = ["house.fill", "arrow.left.arrow.right","list.bullet.clipboard.fill", "gearshape.fill"]
        let color = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        let titleColor = UIColor(red: 18/255, green: 79/255, blue: 80/255, alpha: 1)
        
        
        for image in 0...3 {
            let origImage = UIImage(systemName: images[image])
            let tintedImage = origImage?.withTintColor(color, renderingMode: .alwaysOriginal)
            items[image].image = tintedImage
        }
        
        tabBar.tintColor = titleColor
        homeVC.title = "Home"
        settingsVC.title = "Settings"
        transferVC.title = "Transfer"
        transactionsVC.title = "Transactions"
    }
    
    
    func setUser(_ loggedInUser: UserAuthenticationResponse, serviceAPI: ServiceAPI?) {
        self.serviceAPI = serviceAPI
        
        guard let serviceAPI = serviceAPI else {
            print("Reference of serviceAPI was not transferred")
            return
        }
        // Create a new AccountEntity instance
        guard let container = CoreDataManager.sharedInstance.container?.viewContext else {
            return
        }
        
        let loggedInAccount = AccountEntity(context: container)
        
        // Set the properties of the AccountEntity instance
        loggedInAccount.id = Int64(loggedInUser.accountInfo.id)
        
        // Save the changes to Core Data
        CoreDataManager.sharedInstance.saveAccountToCoreData(accountEntity: loggedInAccount)
        serviceAPI.fetchingTransactions(url: URLBuilder.getTaskURL(withId: loggedInUser.accountInfo.id), completion: { [weak self] (result) in
            
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
             break
                    case .failure(let error):
                        print("Error processing json data: \(error)")
                }
            }
            
        })
        transactionsVC.currentLoggedInAccount = loggedInAccount
        homeVC.serviceAPI = serviceAPI
        settingsVC.serviceAPI = serviceAPI
        settingsVC.homeVC = homeVC
        transferVC.serviceAPI = serviceAPI
        transactionsVC.viewModel = viewModel
        homeVC.viewModel = viewModel
        transferVC.viewModel = viewModel
        homeVC.loggedInUser = loggedInUser
        settingsVC.loggedInUser = loggedInUser
        transferVC.loggedInUser = loggedInUser
    }
    
}
