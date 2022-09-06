//
//  Contraindicant.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/26.
//

import Foundation
import RealmSwift
class Contraindicant: Object {
    
    @objc dynamic var conType :String?
    
    @objc dynamic var A_ingreCode :String?
    @objc dynamic var A_productCode :String?
    @objc dynamic var A_productName :String?
    @objc dynamic var A_entpName :String?
    @objc dynamic var A_pay :String?
   
    @objc dynamic var B_ingreCode :String?
    @objc dynamic var B_productCode :String?
    @objc dynamic var B_productName :String?
    @objc dynamic var B_entpName :String?
    @objc dynamic var B_pay :String?
    
    @objc dynamic var created_no :String?
    @objc dynamic var created_date :String?
    @objc dynamic var des :String?
    
}
