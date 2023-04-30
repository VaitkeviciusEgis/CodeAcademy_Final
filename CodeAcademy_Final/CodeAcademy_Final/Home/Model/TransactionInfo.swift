//
//  TransactionInfo.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-17.
//

import UIKit

struct TransactionInfo: Decodable {
    let senderPhoneNumber: String
    let receiverPhoneNumber: String
    let sendingAccountId: Int32
    let receivingAccountId: Int32
    let transactionTime: Int64
    let amount: Double
    let comment: String
    
}


