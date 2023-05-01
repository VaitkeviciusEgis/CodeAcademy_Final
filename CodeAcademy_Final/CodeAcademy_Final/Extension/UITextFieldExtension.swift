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
    
    func validatePassword(replacementString: String) -> Bool {
        let allowedCharactersCount = allowedCharacters.count
           let keyboard = UIKeyboardType.namePhonePad
           let allowedCharacters = CharacterSet.alphanumerics
           let characterSet = CharacterSet(charactersIn: replacementString)
           
           if self.keyboardType != keyboard {
               self.keyboardType = keyboard
           }
           
           if self.text?.count == allowedCharactersCount && !replacementString.isEmpty {
               return false
           }
           
           return allowedCharacters.isSuperset(of: characterSet)
       }
}
