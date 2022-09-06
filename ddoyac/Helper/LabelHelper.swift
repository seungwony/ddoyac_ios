//
//  LabelHelper.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/10.
//

import Foundation
class LabelHelper {
    
    static let shapes = ["원형", "타원형", "장방형", "사각형", "기타", "오각형", "삼각형", "마름모형", "육각형", "반원형"]
    class func convertShapeLabelFromOriginal(labelName :String) -> String{
        var name = ""
        if labelName == "circle" {
            name = "원형"
        } else if labelName == "oval" {
            name = "타원형"
        } else if labelName == "oblong" {
            name = "정방형"
        } else if labelName == "other_shape" {
            name = "기타"
        }
        
        return name
    }
    
    
    class func getShapesForFilter(shape:String) -> [String] {
        var shapes : [String] = []
        
        if shape == "circle" {
            shapes.append("원형")
        }else if shape == "oval" {
            shapes.append("타원형")
        }else if shape == "oblong" {
            shapes.append("장방형")
        }else if shape == "other_shape" {
            shapes.append("사각형")
            shapes.append("기타")
            shapes.append("오각형")
            shapes.append("삼각형")
            shapes.append("마름모형")
            shapes.append("육각형")
            shapes.append("반원형")
        }
        
        return shapes
    }
}
