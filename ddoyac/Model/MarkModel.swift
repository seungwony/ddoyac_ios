//
//  MarkModel.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/14.
//

import Foundation
struct MarkModel {
    
    var des: String
    var img_src: String?
    
    init(img_src:String, des:String){
        self.img_src = img_src
        self.des = des
        
    }
}
