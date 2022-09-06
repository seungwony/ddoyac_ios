//
//  FilterBundle.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/10.
//

import Foundation
struct FilterBundle {
    var shape : String? {
        willSet(newValue){
//            shape_list
            if let shape = newValue {
                shape_list.removeAll()
                for s in LabelHelper.getShapesForFilter(shape: shape){
                    shape_list.append(s)
                }
            }
            
        }
        
       
    }
    var keyword : String?
    var mark:String?
    var detect_color : String? {
        willSet(newValue){
            if let color = newValue {
                colors.removeAll()
                for c in DBColorNames.getListOfColorInKoreanFromEngList(color: color){
                    colors.append(c)
                }
//                print("color set \(color) colors count :\(colors.count)")
            }
            
            
        }
    }
    
    var shape_list : [String] = []
    var colors:[String]  = []
    
}
