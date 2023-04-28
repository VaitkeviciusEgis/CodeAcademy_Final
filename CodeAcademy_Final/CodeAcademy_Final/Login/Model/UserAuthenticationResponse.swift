//
//  LoginResponse.swift
//  CodeAcademy_Final-Egidijus
//
//  Created by Egidijus Vaitkevičius on 2023-04-08.
//

import UIKit

struct UserAuthenticationResponse: Decodable {
    let userId: Int
    let validUntil: Int
    let accessToken: String
    var accountInfo: AccountInfo
}

