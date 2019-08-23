//
//  API.swift
//  MediumTest
//
//  Created by 黃建程 on 2019/8/23.
//  Copyright © 2019 Spark. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess

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

class APIManager { // GetTokenAPI
    let grantTypeValue = "client_credentials"
    
    let clientID = "a4cbff9718efe676986fe5686c92021a"
    
    let clientSecret = "d33e964f54fe04218ca40aaa24b38f56"
    
    let url = URL(string: "https://account.kkbox.com/oauth2/token")
    
    let hotID = "DZrC8m29ciOFY2JAm3"
    let urlHot = URL(string: "https://api.kkbox.com/v1.1/new-hits-playlists/DZrC8m29ciOFY2JAm3/tracks")
    
    var keychain = Keychain()
    
    let parameters:[String:Any] = [
            "grant_type": "client_credentials",
            "client_id": "a4cbff9718efe676986fe5686c92021a",
            "client_secret": "d33e964f54fe04218ca40aaa24b38f56"
    ]
    
    let hotParameters:[String: Any] = [
        "territory" : "TW"
    ]
    
    
    weak var delegate: GetTokenAPIDelegate?
    
    func getHotList() {
        let encoder = JSONEncoder()
        var urlComponents = URLComponents(string: "https://api.kkbox.com/v1.1/new-hits-playlists/DZrC8m29ciOFY2JAm3/tracks" )
        urlComponents?.queryItems = [
            URLQueryItem(name: "territory", value: "TW"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "offset", value: "0")
        ]
        var url = urlComponents?.url
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        guard let token = keychain["accessToken"] else { return}

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

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
                //                                print(data)
                //                                print(utf8Text)
                //這個方法可以印出不合規定的 data，用來檢查
//                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
//                print(json)
                
                do {
                    let decoder = JSONDecoder()
                    let decodeData = try decoder.decode(PurpleData.self, from: data)
                    
                    self?.delegate?.didGetHotList(didGet: decodeData)
                    
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


    func getToken() {
        //原本打算沒有 token再打API 但是 token 會過期 所以也有點危險
//        if keychain != nil {
//            return
//        }
        
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
//                                print(data)
//                                print(utf8Text)
                
                //這個方法可以印出不合規定的 data，用來檢查
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                print(json)
                
                do {
                    let decoder = JSONDecoder()
                    let decodeData = try decoder.decode(GetedTokenData.self, from: data)
                    let token = decodeData.accessToken //Stylish 的 access token
                
                    self?.keychain["accessToken"] = token
                    
                    self?.delegate?.didGetToken()
                    
                    print("呼叫TokenAPI")
                    
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
    
    func didGetHotList(didGet data: PurpleData)
}

extension Data{
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


