//
//  NumberFormatter.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-04-30.
//

import UIKit

func currencyFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = eurSymbol
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    return formatter
}
