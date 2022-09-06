//
//  Contraindicant.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/26.
//

import Foundation
import RealmSwift
class PillRealm: Object {
    
    @objc dynamic var name :String?
    
    @objc dynamic var descriptor :String?
    @objc dynamic var matched = 0
    

}
