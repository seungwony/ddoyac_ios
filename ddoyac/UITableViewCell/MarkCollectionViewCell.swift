//
//  MarkCollectionViewCell.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/14.
//

import UIKit

class MarkCollectionViewCell: UICollectionViewCell {
    override func prepareForReuse() {
           super.prepareForReuse()
        imgView?.image = nil
    }
    @IBOutlet weak var imgView: UIImageView!
}
