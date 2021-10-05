//
//  ReposListTableViewCell.swift
//  DI_Sample
//
//  Created by sdk on 30.09.2021.
//

import UIKit

class ReposListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    func fill(with model: RepoModel) {
        lblName.text = model.name
        lblDescription.text = model.description
    }
}
