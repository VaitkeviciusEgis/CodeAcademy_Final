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
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        return label
    }()
    
    private  let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8, weight: .bold)
        return label
    }()
    
    private  let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    private  let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
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
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            phoneNumberLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 0),
            phoneNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            commentLabel.leadingAnchor.constraint(equalTo: phoneNumberLabel.trailingAnchor, constant: 12),
            commentLabel.centerYAnchor.constraint(equalTo: phoneNumberLabel.centerYAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            dateLabel.widthAnchor.constraint(equalToConstant: 40),
            commentLabel.widthAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func setupTextFields() {
        amountLabel.font = .boldSystemFont(ofSize: 13)
        phoneNumberLabel.lineBreakMode = .byTruncatingHead
        phoneNumberLabel.numberOfLines = 1
        commentLabel.textAlignment = .center
        dateLabel.textAlignment = .left
        phoneNumberLabel.textAlignment = .left
    }
    
    
    
    func configureCell(with transaction: TransactionEntity) {
        
        let amount = transaction.amount
        let formatter = currencyFormatter()
        
        amountLabel.text = formatter.string(from: NSNumber(value: amount))
        phoneNumberLabel.text = "\(String(describing: transaction.receiverPhoneNumber ?? ""))"
        commentLabel.text = "\(String(describing: transaction.comment ?? ""))"
        
        let date = Date(timeIntervalSince1970: TimeInterval(transaction.transactionTime) / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)
        dateLabel.text = dateString
        
        
    }
    
}
