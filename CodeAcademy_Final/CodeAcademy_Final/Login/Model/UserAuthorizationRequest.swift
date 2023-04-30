//
//  LoginRequest.swift
//  FinalProject-CodaAcademy
//
//  Created by Egidijus Vaitkevičius on 2023-04-18.
//

import UIKit

struct UserAuthorizationRequest: Encodable {
  let phoneNumber: String
  let password: String
}
