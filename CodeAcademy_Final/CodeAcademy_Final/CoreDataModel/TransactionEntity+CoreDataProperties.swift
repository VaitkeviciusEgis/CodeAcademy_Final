//
//  TransactionEntity+CoreDataProperties.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-04-25.
//
//

import Foundation
import CoreData


extension TransactionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        return NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }

    @NSManaged public var amount: Double
    @NSManaged public var comment: String?
    @NSManaged public var receiverPhoneNumber: String?
    @NSManaged public var receivingAccountId: Int32
    @NSManaged public var senderPhoneNumber: String?
    @NSManaged public var sendingAccountId: Int32
    @NSManaged public var transactionTime: Int64
    @NSManaged public var account: AccountEntity?

}

extension TransactionEntity : Identifiable {

}
