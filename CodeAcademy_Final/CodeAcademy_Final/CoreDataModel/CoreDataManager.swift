//
//  CoreDataManager.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-20.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    //MARK: - Properties
    
    private let persistentContainerName = "CodeAcademy_Final"
    let container: NSPersistentContainer?
    let fetchRequest: NSFetchRequest<TransactionEntity>
    static let sharedInstance = CoreDataManager()
    
     init() {
        container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        fetchRequest = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }
    
    //MARK: - Public Methods
    
    func saveDataOf(transactions: [TransactionInfo]) {
        container?.performBackgroundTask { [weak self] context in
            self?.deleteObjectsfromCoreData(context: context)
            self?.saveDataToCoreData(transactions: transactions, context: context)
        }
    }
    
    func saveTransferToCoreData(transfer: TransactionInfo) {
        container?.performBackgroundTask { context in
            let transactionEntity = TransactionEntity(context: context)
            transactionEntity.senderPhoneNumber = transfer.senderPhoneNumber
            transactionEntity.receiverPhoneNumber = transfer.receiverPhoneNumber
            transactionEntity.sendingAccountId = transfer.sendingAccountId
            transactionEntity.receivingAccountId = transfer.receivingAccountId
            transactionEntity.transactionTime = transfer.transactionTime
            transactionEntity.amount = transfer.amount
            transactionEntity.comment = transfer.comment
            
            self.saveContext(context)
        }
    }
    
    func saveAccountToCoreData(accountEntity: AccountEntity) {
        container?.viewContext.insert(accountEntity)
        saveContext(container!.viewContext)
    }
    
    //MARK: - Private Methods
    
    private func deleteObjectsfromCoreData(context: NSManagedObjectContext) {
        do {
            let objects = try context.fetch(fetchRequest)
            objects.forEach { context.delete($0) }
            saveContext(context)
        } catch {
            print("Deleting Error: \(error)")
        }
    }
    
    private func saveDataToCoreData(transactions: [TransactionInfo], context: NSManagedObjectContext) {
        context.perform {
            transactions.forEach { transaction in
                let transactionEntity = TransactionEntity(context: context)
                transactionEntity.senderPhoneNumber = transaction.senderPhoneNumber
                transactionEntity.receiverPhoneNumber = transaction.receiverPhoneNumber
                transactionEntity.sendingAccountId = transaction.sendingAccountId
                transactionEntity.receivingAccountId = transaction.receivingAccountId
                transactionEntity.transactionTime = transaction.transactionTime
                transactionEntity.amount = transaction.amount
                transactionEntity.comment = transaction.comment
            }
            self.saveContext(context)
        }
    }
    
    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
