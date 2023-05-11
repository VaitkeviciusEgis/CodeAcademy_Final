//
//  UpdateUserResponse.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-19.
//

import UIKit

struct UpdateUserResponse: Decodable {
    let userId: Int
    let validUntil: Int
    let accessToken: String
    let accountInfo: AccountInfo
}
 
