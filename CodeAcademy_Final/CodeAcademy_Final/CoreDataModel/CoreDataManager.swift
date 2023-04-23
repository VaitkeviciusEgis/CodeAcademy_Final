//
//  CoreDataManager.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-20.
//

import UIKit
import CoreData


class CoreDataManager {
    
    let persistentContainerName = "CodeAcademy_Final"
    static let sharedInstance = CoreDataManager()

    
 
    
    

     let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private let fetchRequest = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    
    func saveDataOf(transactions:[TransactionInfo]) {
        
        // Updates CoreData with the new data from the server - Off the main thread
        self.container?.performBackgroundTask{ [weak self] (context) in
//            self?.deleteObjectsfromCoreData(context: context)
            self?.saveDataToCoreData(transactions: transactions, context: context)
            print("Saved data ? \(transactions)")
        }
    }
    
    
    // MARK: - Delete Core Data objects before saving new data
    private func deleteObjectsfromCoreData(context: NSManagedObjectContext) {
        do {
            // Fetch Data
            let objects = try context.fetch(fetchRequest)
            
            // Delete Data
            _ = objects.map({context.delete($0)})
            
            // Save Data
            try context.save()
        } catch {
            print("Deleting Error: \(error)")
        }
    }
    
    // MARK: - Save new data from the server to Core Data
    private func saveDataToCoreData(transactions:[TransactionInfo], context: NSManagedObjectContext) {
        // perform - Make sure that this code of block will be executed on the proper Queue
        // In this case this code should be perform off the main Queue
        context.perform {
            for transaction in transactions {
                
                let transactionEntity = TransactionEntity(context: context)
                transactionEntity.senderPhoneNumber = transaction.senderPhoneNumber
                transactionEntity.receiverPhoneNumber = transaction.receiverPhoneNumber
                transactionEntity.sendingAccountId = transaction.sendingAccountId
                transactionEntity.receivingAccountId = transaction.receivingAccountId
                transactionEntity.transactionTime = transaction.transactionTime
                transactionEntity.amount = transaction.amount
                transactionEntity.comment = transaction.comment
                
            }
            // Save Data
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    

}
 
