//
//  UpdateUserRequest.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-19.
//

import UIKit

struct UpdateUserRequest: Encodable {
    let currentPhoneNumber: String
    let newPhoneNumber: String
    let newPassword: String
    let token: String
}
