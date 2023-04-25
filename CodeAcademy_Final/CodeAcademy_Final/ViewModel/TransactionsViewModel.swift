//
//  TransactionsViewModel.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-22.
//

import Foundation
import CoreData
import UIKit

protocol UpdateTableViewDelegate: NSObjectProtocol {
    func reloadData(sender: TransactionsViewModel)
}

class TransactionsViewModel: NSObject, NSFetchedResultsControllerDelegate {
    
    //MARK: - Properties
    
    private var displayedTransactions = [TransactionEntity]()
    private let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<TransactionEntity>?
    weak var delegate: UpdateTableViewDelegate?
    
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
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.reloadData(sender: self)
        
    }
    
    //MARK: - TableView DataSource functions
    func numberOfRowsInSection (section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func object (indexPath: IndexPath) -> TransactionEntity? {
        return fetchedResultsController?.object(at: indexPath)
    }
}
