//
//  InputTableViewCell.swift
//  dojo-ios-sdk_Example
//
//  Created by Deniss Kaibagarovs on 29/03/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit


enum InputTableViewCellType {
    case cardholderName
    case cardNumber
    case cvv
    case expiry
    
    case token
}

class InputTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textFieldInput: UITextField!
    
    public static let identifier: String = "InputTableViewCell"
    public static let nib: String = "InputTableViewCell"
    
    public var inputType: InputTableViewCellType! = .token
    
    public static func register(tableView: UITableView) {
        tableView.register(UINib(nibName: InputTableViewCell.nib,
                                 bundle: nil),
                           forCellReuseIdentifier: InputTableViewCell.identifier)
    }
    
    func setValue(_ value: String) {
        self.textFieldInput.text = value
    }
    
    func getValue() -> String {
        textFieldInput.text ?? ""
    }
    
    func setup(_ type: InputTableViewCellType) {
        self.inputType = type
        textFieldInput.delegate = self
        switch type {
        case .cardholderName:
            labelTitle.text = "Cardholder name"
            textFieldInput.keyboardType = .default
        case .cardNumber:
            labelTitle.text = "Card number"
            textFieldInput.keyboardType = .numberPad
        case .cvv:
            labelTitle.text = "CVV"
            textFieldInput.keyboardType = .numberPad
        case .expiry:
            labelTitle.text = "Expiry (MM / YY)"
            textFieldInput.keyboardType = .default
        case .token:
            labelTitle.text = "Token"
            textFieldInput.keyboardType = .default
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension InputTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentView.endEditing(true)
        return false
    }
}
