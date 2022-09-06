//
//  UIImageView.swift
//  plant2
//
//  Created by SEUNGWON YANG on 03/05/2019.
//  Copyright © 2019 kr.co.plantraining. All rights reserved.
//

import UIKit

@IBDesignable class RoundImageView: UIImageView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}


extension UIImageView {
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
  
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
//    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
//
//        if link != "" {
//            guard let url = URL(string: link) else { return }
//            downloaded(from: url, contentMode: mode)
//        }else {
//            self.image = UIImage(named: "img_placeholder")
//        }
//
//
//    }
    
    
    func youtubeThumbnail(from yid: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        
        if yid != "" {
            
            let imgurl = "https://img.youtube.com/vi/\(yid)/maxresdefault.jpg"
            
//            debugPrint("youtube img thumb : \(imgurl)")
            guard let url = URL(string: imgurl) else { return }
            downloaded(from: url, contentMode: mode)
        }else {
            self.image = UIImage(named: "offline_img2")
        }
        
        
    }
}
