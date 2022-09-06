//
//  FilterInfo.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/10.
//

import Foundation
struct FilterInfo {
    var type: String
    var name: String
    var img_path: String?
    var selected = false
    var hexCode : Int?
    var order:Int = 0
    init(type:String, name:String, img_path:String? = nil){
        self.type = type
        self.name = name
        self.img_path = img_path
    }
}
