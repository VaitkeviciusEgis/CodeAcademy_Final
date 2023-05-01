//
//  ViewController.swift
//  CodeAcademy_Final-Egidijus
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
        let color = UIColor(red: 42/255, green: 175/255, blue: 134/255, alpha: 1)
        let titleColor = UIColor(red: 42/255, green: 175/255, blue: 134/255, alpha: 1)
        
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
            return
        }
        
        guard let container = CoreDataManager.sharedInstance.container?.viewContext else {
            return
        }
        
        let loggedInAccount = AccountEntity(context: container)
        
        loggedInAccount.id = Int64(loggedInUser.accountInfo.id)
        
        CoreDataManager.sharedInstance.saveAccountToCoreData(accountEntity: loggedInAccount)
        serviceAPI.fetchingTransactions(url: URLBuilder.getTransactionURL(withId: loggedInUser.accountInfo.id), completion: { [weak self] (result) in
            guard self == self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        UIAlertController.showErrorAlert(title: "\(error)",
                                                         message: "Error saving data to CoreData",
                                                         controller: UIViewController())
                }
            }
        })
        
        transactionsVC.currentLoggedInAccount = loggedInAccount
        transactionsVC.viewModel = viewModel
        homeVC.serviceAPI = serviceAPI
        homeVC.viewModel = viewModel
        homeVC.loggedInUser = loggedInUser
        settingsVC.serviceAPI = serviceAPI
        settingsVC.homeVC = homeVC
        settingsVC.loggedInUser = loggedInUser
        transferVC.loggedInUser = loggedInUser
        transferVC.viewModel = viewModel
        transferVC.serviceAPI = serviceAPI
    }
    
}
