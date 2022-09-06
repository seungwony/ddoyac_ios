//
//  DrugModel.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/26.
//

import Foundation
struct DrugModel {
    
    let id :Int
    
    let p_no :Int
    let p_name: String
    
    let c_no:Int
    let c_name: String
    
    
    let des : String
    let img : String
    let mark_front : String
    let mark_back : String
    
    let shape : String
    
    let color_front : String
    let color_back : String
    
    let div_front : String
    let div_back : String
    
    let major_axis : String
    let minor_axis : String
    
    
    let thickness : String
    
    let img_created : Int
    
    
    let class_no : String
    let class_name : String
    
    let mark_img_front : String
    let mark_img_back : String
    
    let mark_img_des_front : String
    let mark_img_des_back : String
    
    
    let specialization : String
    let approval : Int
    
    let shape_code : String
    let updated : String
    
    let searchable : String
    
    let descriptor_front : String
    
    
    let descriptor_back :String
    
    var matched_count_front :Int = 0
    var matched_count_back :Int = 0
    
    
    init(id:Int,
         p_no:Int,
         p_name:String,
         c_no:Int,
         c_name:String,
         des:String,
         img:String,
         mark_front:String,
         mark_back:String,
         shape:String,
         color_front:String,
         color_back:String,
         
         div_front:String,
         div_back:String,
         
         major_axis:String,
         minor_axis:String,
         
         thickness:String,
         img_created:Int,
         
         class_no:String,
         class_name:String,
         
         mark_img_front:String,
         mark_img_back:String,
         
         mark_img_des_front:String,
         mark_img_des_back:String,
         
         specialization:String,
         approval:Int,
         
         shape_code:String,
         updated:String,
         
         searchable:String,
         
         descriptor_front:String = "",
         descriptor_back:String = ""
         ) {
        
        self.id = id
        self.p_no = p_no
        self.p_name = p_name
        self.c_no = c_no
        self.c_name = c_name
        self.des = des
        self.img = img
        
        self.mark_front = mark_front
        self.mark_back = mark_back
        
        self.shape = shape
        self.color_front = color_front
        self.color_back = color_back
        
        self.div_front = div_front
        self.div_back = div_back
        
        self.major_axis = major_axis
        self.minor_axis = minor_axis
        
        self.thickness = thickness
        self.img_created = img_created
        
        self.class_no = class_no
        self.class_name = class_name
        
        self.mark_img_front = mark_img_front
        self.mark_img_back = mark_img_back
        
        self.mark_img_des_front = mark_img_des_front
        self.mark_img_des_back = mark_img_des_back
        
        self.specialization = specialization
        self.approval = approval
        
        self.shape_code = shape_code
        self.updated = updated
        
        self.searchable = searchable
        
        self.descriptor_front = descriptor_front
        self.descriptor_back = descriptor_back
        
        
        
    }
}
