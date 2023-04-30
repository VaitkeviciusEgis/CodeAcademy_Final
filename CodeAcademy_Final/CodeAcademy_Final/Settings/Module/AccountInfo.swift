//
//  AccountInfo.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit

class AccountInfo: Decodable {
    let id: Int
    let currency: String
    var balance: Double?
    let ownerPhoneNumber: String?
}

