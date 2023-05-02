//
//  FilterViewController.swift
//  CodeAcademy_Final
//
//  Created by Egidijus Vaitkevičius on 2023-05-02.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ filterViewController: FilterViewController, didSelectStartDate startDate: Int64?, endDate: Int64?)
}


class FilterViewController: UIViewController {

    weak var delegate: FilterViewControllerDelegate?

    let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Start Date:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let startPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "End Date:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let endPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Filter", for: .normal)
        button.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        view.addSubview(startDateLabel)
        view.addSubview(startPicker)
        view.addSubview(endDateLabel)
        view.addSubview(endPicker)
        view.addSubview(filterButton)
        
        setupConstraints()
    }
    
    @objc func filterButtonPressed() {
        let startDate = startPicker.date
        let endDate = endPicker.date
        let startDateTimestamp = Int64(startDate.timeIntervalSince1970 * 1000)
        let endDateTimestamp = Int64(endDate.timeIntervalSince1970 * 1000)
        delegate?.filterViewController(self, didSelectStartDate: startDateTimestamp, endDate: endDateTimestamp)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startDateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 124),
            
            startPicker.leadingAnchor.constraint(equalTo: startDateLabel.trailingAnchor, constant: 16),
            startPicker.centerYAnchor.constraint(equalTo: startDateLabel.centerYAnchor),
            startPicker.widthAnchor.constraint(equalToConstant: 240),
            
            endDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            endDateLabel.topAnchor.constraint(equalTo: startPicker.bottomAnchor, constant: 24),
            
            endPicker.leadingAnchor.constraint(equalTo: endDateLabel.trailingAnchor, constant: 16),
            endPicker.centerYAnchor.constraint(equalTo: endDateLabel.centerYAnchor),
            endPicker.widthAnchor.constraint(equalToConstant: 240),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.topAnchor.constraint(equalTo: endPicker.bottomAnchor, constant: 48),
        ])
    }
}
