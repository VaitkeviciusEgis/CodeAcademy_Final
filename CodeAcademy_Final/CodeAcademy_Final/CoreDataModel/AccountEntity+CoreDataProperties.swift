//
//  AccountEntity+CoreDataProperties.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-04-25.
//
//

import UIKit
import CoreData


extension AccountEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountEntity> {
        return NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension AccountEntity {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: TransactionEntity)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: TransactionEntity)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

extension AccountEntity : Identifiable {

}
