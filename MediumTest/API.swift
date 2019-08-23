//
//  API.swift
//  MediumTest
//
//  Created by 黃建程 on 2019/8/23.
//  Copyright © 2019 Spark. All rights reserved.
//

import Foundation
import Alamofire

struct GetedTokenData: Codable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct PostToGetToken: Codable {
    let grantType, clientID, clientSecret: String
    
    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientID = "client_id"
        case clientSecret = "client_secret"
    }
}
// client_credentials

//  a4cbff9718efe676986fe5686c92021a


// d33e964f54fe04218ca40aaa24b38f56

class GetTokenAPI {
    let grantTypeValue = "client_credentials"
    
    let clientID = "a4cbff9718efe676986fe5686c92021a"
    
    let clientSecret = "d33e964f54fe04218ca40aaa24b38f56"
    
    let url = URL(string: "https://account.kkbox.com/oauth2/token")
    
    let parameters:[String:Any] = [

            "grant_type": "client_credentials",
            "client_id": "a4cbff9718efe676986fe5686c92021a",
            "client_secret": "d33e964f54fe04218ca40aaa24b38f56"

    ]
//    let parameters = [
//        [
//            "name": "grant_type",
//            "value": "client_credentials"
//        ],
//        [
//            "name": "client_id",
//            "value": "a4cbff9718efe676986fe5686c92021a"
//        ],
//        [
//            "name": "client_secret",
//            "value": "d33e964f54fe04218ca40aaa24b38f56"
//        ]
//    ]
    
    func gettokenTwo() {
        AF.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default ,headers: .init([HTTPHeader(name: "Content-Type", value: "multipart/form-data")])).responseJSON { (response) in
            
            switch response.result {
            case.failure(let error):
                print(error)
            case .success(let susses):
                print(susses)
            }
            
        }
        
        
    }
    
    
    
    weak var delegate: GetTokenAPIDelegate?
    
    func getToken() {
        let encoder = JSONEncoder()
        var request = URLRequest(url: url!)
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        
        request.httpMethod = "POST"
        
//        request.allHTTPHeaderFields = ["Content-Type": "multipart/form-data"]
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        var body = Data()
        
        for (key, value) in parameters {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        body.appendString(string: "--\(boundary)--\r\n")
        print(body)
        request.httpBody = body
        
//        let body = PostToGetToken(grantType: grantTypeValue, clientID: clientID, clientSecret: clientSecret)
//        do {
//            let data = try encoder.encode(body)
//            request.httpBody = data
//            print(data)
//        } catch {
//            print("ENCODER FAIL")
//        }
//        print(body)
//        print(request.allHTTPHeaderFields)
        
        
        URLSession.shared.dataTask(with: request) { [weak self](data, reponse, error) in
            if error != nil {
                print(error)
                return
            }
            guard let httpResponse = reponse as? HTTPURLResponse else { return }
            
            let statustCode = httpResponse.statusCode
            
            if statustCode >= 200 && statustCode <= 300 {
                
                //Success
                
                guard let data = data, let utf8Text = String(data: data, encoding: .utf8) else {
                    print("no data")
                    return
                }
                                print(data)
                                print(utf8Text)
                
                //這個方法可以印出不合規定的 data，用來檢查
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                print(json)
                
                do {
                    let decoder = JSONDecoder()
                    let decodeData = try decoder.decode(GetedTokenData.self, from: data)
                    let token = decodeData.accessToken //Stylish 的 access token
                    print(token)
                    
                    //savetoken
//                    self.keychain["STYLISHaccessToken"] = token
                    
                    self?.delegate?.didGetToken()
                    
                    print("呼叫API")
                    
                } catch {
                    print(utf8Text) //就是靠這個才發現，我在 EndPoint 中 case .productForMen: return "products/men" 多加一個斜線
                    print("解析錯誤")
                }
                
                print("success")
            } else if statustCode >= 400 && statustCode < 500 {
                
                print("Client Error")
            } else {
                
                print("server error")
            }
        }.resume()
        
    }
    
}

protocol GetTokenAPIDelegate: AnyObject {
    func didGetToken()
}

extension Data{
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


