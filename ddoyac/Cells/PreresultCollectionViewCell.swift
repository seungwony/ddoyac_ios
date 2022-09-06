//
//  PreresultCollectionViewCell.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/14.
//

import UIKit

class PreresultCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    

    override func prepareForReuse() {
           super.prepareForReuse()
        previewImg?.image = nil
    }
}
