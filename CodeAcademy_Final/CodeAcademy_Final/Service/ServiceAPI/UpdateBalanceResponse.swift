//
//  UpdateBalanceResponse.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit

struct UpdateBalanceResponse: Decodable {
    let id: Int
    let currency: String
    let balance: Double
    let ownerPhoneNumber: String
}
 
