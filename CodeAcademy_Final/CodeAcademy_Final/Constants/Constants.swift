//
//  Constants.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-04-28.
//

import UIKit
import KeychainSwift

let eurSymbol = "\u{20AC}"
let keyAccessToken = "accessToken"
let keyPhoneNumber = "phoneNumber"
let keyPassword = "password"
let errorStatusCodeMessage = "Error with status code: "
let listIdentifier = "listCell"
let tableViewHeightForRow: CGFloat = 48
let pickerNumberOfComponents = 1
let keyChain = KeychainSwift()
let textFieldLimit = 12
let allowedCharacters = "0123456789+"


//MARK: - Colors

let cardViewBackgroundColor = UIColor(red: 41/255, green: 44/255, blue: 53/255, alpha: 1)
let selectedColor = UIColor(red: 245/255, green: 252/255, blue: 250/255, alpha: 1)
let deSelectedColor = cardPayBackgroundColor
let cardPayBackgroundColor = UIColor(red: 215/255, green: 222/255, blue: 220/255, alpha: 1)
let textColor = UIColor(ciColor: .black)
let borderColor = CGColor(red: 41/255, green: 44/255, blue: 53/255, alpha: 1)
let buttonBackgroundColor = UIColor(red: 205/255, green: 212/255, blue: 220/255, alpha: 1)
