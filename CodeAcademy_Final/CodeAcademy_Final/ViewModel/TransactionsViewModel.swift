//
//  TransactionsViewModel.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-22.
//

import UIKit
import CoreData

protocol UpdateTableViewDelegate: AnyObject {
    func reloadData(sender: TransactionsViewModel)
}

final class TransactionsViewModel: NSObject {
    
    // MARK: - Properties
    
    private var displayedTransactions = [TransactionEntity]()
    private let container: NSPersistentContainer?
    var fetchedResultsController: NSFetchedResultsController<TransactionEntity>?
    weak var delegate: UpdateTableViewDelegate?
    
    // MARK: - Initializer
    
    init(container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer) {
        self.container = container
        super.init()
    }
    
    // MARK: - Public Functions
    
    func retrieveDataFromCoreData() {
        guard let context = container?.viewContext else { return }
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "transactionTime", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            displayedTransactions = fetchedResultsController?.fetchedObjects ?? []
        } catch {
            print("Error fetching transactions: \(error.localizedDescription)")
        }
    }
}

extension TransactionsViewModel: NSFetchedResultsControllerDelegate  {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.reloadData(sender: self)
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        let lastFiveTransactions = fetchedResultsController?.fetchedObjects?.suffix(5) ?? []
        return min(lastFiveTransactions.count, 5)
    }
    
    func object(indexPath: IndexPath) -> TransactionEntity? {
        return fetchedResultsController?.object(at: indexPath)
    }
}
