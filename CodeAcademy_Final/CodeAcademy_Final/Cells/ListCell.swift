//
//  ListCell.swift
//  APITask-Egidijus
//
//  Created by Egidijus Vaitkevičius on 2023-03-02.
//

import UIKit

//class ListCell: UITableViewCell {
//
//static let identifier = "listCell"
//}
//

class ListCell: UITableViewCell {
    

    static let identifier = "listCell"
    let phoneNumberLabel: UILabel = {
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
        
        addSubview(phoneNumberLabel)
        addSubview(amountLabel)

        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            phoneNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            phoneNumberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            phoneNumberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            amountLabel.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 4),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            amountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with transaction: TransactionEntity) {
       
            phoneNumberLabel.text = transaction.receiverPhoneNumber
            amountLabel.text = "\(transaction.amount)"
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
