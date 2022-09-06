//
//  SavedListTableViewCell.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/20.
//

import UIKit

class SavedListTableViewCell: UITableViewCell {

    @IBOutlet weak var countLabel: RoundButton!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
