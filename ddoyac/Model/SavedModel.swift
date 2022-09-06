//
//  SavedModel.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/20.
//

import Foundation

struct SavedModel {
    var id : Int
    var priority: Int
    
    var name: String
    var created: String
    
    init(id:Int, priority:Int, name:String, created:String){
        self.id = id
        self.priority = priority
        
        self.name = name
        self.created = created
        
    }
}
