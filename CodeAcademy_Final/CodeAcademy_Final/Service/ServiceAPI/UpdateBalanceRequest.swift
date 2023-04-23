//
//  UpdateBalanceRequest.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit

struct UpdateBalanceRequest: Encodable {
    let accountId: Int
    let amountToAdd: Double
}
