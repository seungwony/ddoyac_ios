//
//  Drug.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/26.
//

import RealmSwift
class Drug: Object {
    @objc dynamic var id = -1
    
    @objc dynamic var p_no = -1
    @objc dynamic var p_name: String = ""
    
    @objc dynamic var c_no = -1
    @objc dynamic var c_name = ""
    
    
    @objc dynamic var des = ""
    @objc dynamic var img = ""
    @objc dynamic var mark_front = ""
    @objc dynamic var mark_back = ""
    
    @objc dynamic var shape = ""
    
    @objc dynamic var color_front = ""
    @objc dynamic var color_back = ""
    
    @objc dynamic var div_front = ""
    @objc dynamic var div_back = ""
    
    @objc dynamic var major_axis = ""
    @objc dynamic var minor_axis = ""
    
    
    @objc dynamic var thickness = ""
    
    @objc dynamic var img_created = -1
    
    
    @objc dynamic var class_no = ""
    @objc dynamic var class_name = ""
    
    @objc dynamic var mark_img_front = ""
    @objc dynamic var mark_img_back = ""
    
    @objc dynamic var mark_img_des_front = ""
    @objc dynamic var mark_img_des_back = ""
    
    
    @objc dynamic var specialization = ""
    @objc dynamic var approval = -1
    
    @objc dynamic var shape_code = ""
    @objc dynamic var updated = ""
    
    @objc dynamic var searchable :String?
    
//    @objc dynamic var descriptor_front :String?
    
    
//    @objc dynamic var descriptor_back :String?
    
    @objc dynamic var matched_count_front = 0
    @objc dynamic var matched_count_back = 0
    
    override static func ignoredProperties() -> [String] {
          return ["matched_count_front", "matched_count_back"]
      }
    override static func primaryKey() -> String? {
            return "id"
        }
//    convenience init(name: String,
//                     descriptor_front: String,
//                     descriptor_back: String,
//                     searchable: String,
//                     matched_count_front: Int,
//                     matched_count_back: Int) {
//            self.init()
//            self.name = name
//            self.address = address
//        }
    func jsonRepresentatio() -> String {

        let dict = ["id" : id,
                    "p_no" : p_no,
                    "p_name" : p_name,
                    "c_no" : c_no,
                    "c_name" : c_name,
                    "des" : des,
                    "img" : img,
                    "mark_front" : mark_front,
                    "mark_back" : mark_back,
                    "shape" : shape,
                    "color_front" : color_front,
                    "color_back" : color_back,
                    "div_front" : div_front,
                    "div_back" : div_back,
                    "major_axis" : major_axis,
                    "minor_axis" : minor_axis,
                    "thickness" : thickness,
                    "img_created" : img_created,
                    "class_no" : class_no,
                    "class_name" : class_name,
                    "specialization" : specialization,
                    "approval" : approval,
                    "searchable" : searchable,
                    "shape_code" : shape_code,
                    "updated" : updated
                    
                     ] as [String : Any]
        
        let data =  try! JSONSerialization.data(withJSONObject: dict, options: [])
        
        return String(data:data, encoding:.utf8)!
    }
}
