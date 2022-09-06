//
//  CircleButton.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/26.
//

import UIKit

@IBDesignable class CircleButton: UIButton
{
    override func layoutSubviews() {
        super.layoutSubviews()

        updateCornerRadius()
    }

    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }

    func updateCornerRadius() {
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
    }
}
