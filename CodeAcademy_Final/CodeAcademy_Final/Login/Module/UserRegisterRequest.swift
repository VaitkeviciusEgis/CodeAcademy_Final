//
//  AccessRequest.swift
//  CodeAcademy_Final-Egidijus
//
//  Created by Egidijus Vaitkevičius on 2023-04-08.
//

import UIKit

struct UserRegisterRequest: Encodable {
  let phoneNumber: String
  let password: String
  let currency: String
}
