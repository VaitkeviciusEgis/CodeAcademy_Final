//
//  UpdateBalanceResponse.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-04-24.
//

import UIKit

struct UpdateBalanceResponse: Decodable {
    let id: Int
    let currency: String
    let balance: Double
    let ownerPhoneNumber: String
}
 
