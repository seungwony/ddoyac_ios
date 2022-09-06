//
//  ApiManager.swift
//  plant2
//
//  Created by SEUNGWON YANG on 2019/07/05.
//  Copyright © 2019 kr.co.plantraining. All rights reserved.
//

import Alamofire

class ApiManager {
    
    static let REST_SERVER_URL = "http://apis.data.go.kr"
 

    static let SERVICE_KEY = "SxFlIFuuam1GbQpirOoR%2FSkLZRJN9Qwf4a3%2FI3QkmE%2Fij6u07joiJ6DgZmToQElFA32HgCgMTZ%2BEaayfFLXthg%3D%3D"
    public static func getHeader()->HTTPHeaders{
        
        let headers: HTTPHeaders = [
         
            "Content-Type": "text/xml;charset=UTF-8"
        ]
        
        return headers
    }
    
    
    
    
}
