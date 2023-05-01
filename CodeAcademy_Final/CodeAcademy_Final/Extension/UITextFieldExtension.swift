//
//  UITextFieldExtension.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-05-01.
//

import UIKit

extension UITextField {
    func validatePhoneNumber(allowedCharacters: String, replacementString: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let replacementStringCharacterSet = CharacterSet(charactersIn: replacementString)
        return allowedCharacterSet.isSuperset(of: replacementStringCharacterSet)
    }
    
    func validateDecimalInput(replacementString: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: replacementString)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
