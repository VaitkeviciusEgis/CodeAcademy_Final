//
//  ListCell2.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-04-24.
//

import Foundation
import UIKit

//class ListCell: UITableViewCell {
//
//static let identifier = "listCell"
//}
//

class ListCell2: UITableViewCell {
    
    static let identifier = "listCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        addSubview(amountLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            amountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with transaction: TransactionEntity) {
        titleLabel.text = transaction.receiverPhoneNumber
        amountLabel.text = "\(transaction.amount)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
