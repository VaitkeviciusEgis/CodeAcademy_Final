//
//  UIViewExtension.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-04-30.
//


import UIKit

extension UIView {
    
    func addSubViews(_ views: [UIView]) {
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
