//
//  HomeViewModel.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-04-23.
//

import Foundation
import CoreData
import UIKit


protocol CoreDataTableViewModel: AnyObject {
    associatedtype FetchedObjectType: NSFetchRequestResult
    
    var fetchedResultsController: NSFetchedResultsController<FetchedObjectType>? { get set }
    var delegate: UpdateTableViewDelegate? { get set }
    
    func retrieveDataFromCoreData()
}

class HomeViewModel: NSObject, NSFetchedResultsControllerDelegate, CoreDataTableViewModel, StoringTransactions {
    var displayedTransactions = [TransactionEntity]()
    

    var isDataLoaded = false
    private let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<TransactionEntity>?
    weak var delegate: UpdateTableViewDelegate?
    
    
    
    override init() {
        super.init()
        retrieveDataFromCoreData()
    }
    
    //MARK: - Fetched Results Controller - Retrieve data from Core Data
    func retrieveDataFromCoreData() {
           if let context = container?.viewContext {
               let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
               fetchRequest.sortDescriptors = [NSSortDescriptor(key: "transactionTime", ascending: false)]
               fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
               fetchedResultsController?.delegate = self

               do {
                   try fetchedResultsController?.performFetch()
                   if let transactions = fetchedResultsController?.fetchedObjects {
                                      displayedTransactions = transactions
                                  }

               } catch {
                   print("Failed to initialize FetchedResultsController: \(error)")
               }
           }
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }



    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.reloadData(sender: self)

    }
    
}

extension HomeViewModel: UpdateTableViewDelegate {
    func reloadData(sender: Any) {
//        tableView.reloadData()
    }
    
    typealias Sender = HomeViewModel
}
