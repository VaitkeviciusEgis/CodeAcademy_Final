//
//  Transfer.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-19.
//

import UIKit

struct Transfer: Encodable {
    let senderPhoneNumber: String
    let token: String
    let receiverPhoneNumber: String
    let senderAccountId: Int
    let amount: Double
    let comment: String
}
