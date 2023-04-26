//
//  UIAlertControllerExtension.swift
//  APITask-Egidijus
//
//  Created by Egidijus Vaitkevičius on 2023-03-06.
//

import UIKit

extension UIAlertController {
  static func showErrorAlert(title: String, message: String, controller: UIViewController) {
    let action = UIAlertAction(title: "Ok", style: .default)
    let alert =  UIAlertController(title:title, message: message, preferredStyle: .alert)
    alert.addAction(action)
    controller.present(alert, animated: true)
  }
}
