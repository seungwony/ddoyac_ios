//
//  DrugTableViewCell.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/26.
//

import UIKit

class DrugTableViewCell: UITableViewCell {
    
    @IBOutlet weak var previewImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
           super.prepareForReuse()
        previewImg?.image = nil
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
