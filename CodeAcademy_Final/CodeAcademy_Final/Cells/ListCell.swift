//
//  ListCell.swift
//  CodeAcademy_Final-Egidijus
//
//  Created by Egidijus Vaitkevičius on 2023-03-02.
//

import UIKit


class ListCell: UITableViewCell {
    
    
    //MARK: - Properties
    
    static let identifier = "listCell"
    let formatter = NumberFormatter()
    let eurSymbol = "\u{20AC}"
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
    
    
    //MARK: - Initialisation
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(phoneNumberLabel)
        addSubview(amountLabel)
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            phoneNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            phoneNumberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            phoneNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)
        ])
        amountLabel.lineBreakMode = .byTruncatingTail
        amountLabel.numberOfLines = 1
        phoneNumberLabel.lineBreakMode = .byTruncatingHead
        phoneNumberLabel.numberOfLines = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Action
    
    func configure(with transaction: TransactionEntity) {
        
//        self.formatter.numberStyle = .currency
//        self.formatter.currencySymbol = self.eurSymbol
//        let balance = response.balance
//        self.balanceLabel.text = self.formatter.string(from: NSNumber(value: balance))
//        self.loggedInUser?.accountInfo.balance = response.balance
//        balanceLabel.text = formatter.string(from: NSNumber(value: balance))

//    }
        
        
        let amount = transaction.amount
        amountLabel.text = formatter.string(from: NSNumber(value: amount))
        formatter.numberStyle = .currency
        formatter.currencySymbol = eurSymbol
        
        phoneNumberLabel.text = "+370 \(String(describing: transaction.receiverPhoneNumber ?? ""))"
        phoneNumberLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .light)
        amountLabel.text = formatter.string(from: NSNumber(value: amount))
        amountLabel.font = .boldSystemFont(ofSize: 13)
    }
    
}
