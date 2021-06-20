//
//  ItemTableViewCell.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 20.06.2021.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    static let identifier = "ItemTableViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "ItemTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
