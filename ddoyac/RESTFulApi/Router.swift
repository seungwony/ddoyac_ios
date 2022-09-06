//
//  Router.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/27.
//

import Foundation
import UIKit
import Alamofire
enum Router: URLRequestConvertible {

  
    
    //이벤트 로그 디테일
    case getDrugDetail(item_seq:String)
    
  


    var method: HTTPMethod {
        switch self {
            
    
        case .getDrugDetail:
            return .get
     
        }
    }
    
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = {
            switch self {
            
            case let .getDrugDetail(item_seq):
                return (ApiCommon.GET_DETAIL, ["item_seq":item_seq])
    
            }
        }()
        
        let url = try ApiManager.REST_SERVER_URL.asURL()
        let urlRequest = try! URLRequest(url: url.appendingPathComponent(result.path), method : method,  headers: ApiManager.getHeader())
        
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
    
    
}





