//
//  ListCell.swift
//  CodeAcademy_Final-Egidijus
//
//  Created by Egidijus Vaitkevičius on 2023-03-02.
//

import UIKit


class ListCell: UITableViewCell {
    
    //MARK: - Initialisation
    
    private let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private  let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private  let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    private  let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let subViews: [UIView] = [phoneNumberLabel, amountLabel, commentLabel, dateLabel]
        addSubViews(subViews)
        
        setupCellConstraints()
        setupTextFields()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Action
    
    private func setupCellConstraints() {
        NSLayoutConstraint.activate([
            phoneNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            phoneNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: phoneNumberLabel.trailingAnchor, constant: 32),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
//            commentLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -16),
            commentLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func setupTextFields() {
        amountLabel.lineBreakMode = .byTruncatingTail
        amountLabel.numberOfLines = 1
        amountLabel.font = .boldSystemFont(ofSize: 13)
        
        phoneNumberLabel.lineBreakMode = .byTruncatingHead
        phoneNumberLabel.numberOfLines = 1
        phoneNumberLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .light)
    }
    
    func configureCell(with transaction: TransactionEntity) {
        
        let amount = transaction.amount
        let formatter = currencyFormatter()
        
        amountLabel.text = formatter.string(from: NSNumber(value: amount))
        phoneNumberLabel.text = "\(String(describing: transaction.receiverPhoneNumber ?? ""))"
        commentLabel.text = "\(String(describing: transaction.comment ?? ""))"
        
        let date = Date(timeIntervalSince1970: TimeInterval(transaction.transactionTime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)
        dateLabel.text = dateString
        
        
    }
    
}
