//
//  NetworkManager.swift
//  Car Data
//
//  Created by itay gervash on 04/06/2022.
//

import Foundation
import Promises
import Alamofire

struct HTTPRequest {
    
    static func get<T: Codable>(from url: URL?, with headers: HTTPHeaders? = nil, decodeWith: T.Type, taskID: String? = nil) -> Promise<T> {
        
        let taskID = taskID ?? UUID().uuidString
        
        return Promise { fulfill, reject in
            
            guard let url = url else {
                reject(CDError.requestError)
                return
            }
            print("get data from url: \(url)...")
            let request = AF.request(url, headers: headers).validate(statusCode: 200..<300)
            
                .responseDecodable(of: T.self) { response in
                    
                    guard response.error == nil else {
                        reject(response.error!)
                        return
                    }
                    
                    if let result = response.value {
                        fulfill(result)
                    } else {
                        reject(CDError.parseError)
                    }
                }
            

            CDTaskMonitor.main.add(activeTask: CDTask(id: taskID, request: request))
            
        }.always {
            CDTaskMonitor.main.remove(activeTasksWithID: taskID)
        }
        
    }
    
    static func post<T: Codable>(data: Dictionary<String, Any>, to url: URL?, decodeResponseWith decoder: T.Type, taskID: String? = nil) -> Promise<T> {
        
        let taskID = taskID ?? UUID().uuidString
        
        return Promise { fulfill, reject in
            
            guard let url = url else {
                reject(CDError.requestError)
                return
            }
            
            let request = AF.request(url, method: .post, parameters: data, encoding: JSONEncoding.default).validate(statusCode: 200..<300)
            
                .responseDecodable(of: decoder) { response in
                    guard response.error == nil else {
                        reject(response.error!)
                        return
                    }
                    
                    if let result = response.value {
                        fulfill(result)
                    } else {
                        reject(CDError.parseError)
                    }
                }
            
            CDTaskMonitor.main.add(activeTask: CDTask(id: taskID, request: request))
        }.always {
            CDTaskMonitor.main.remove(activeTasksWithID: taskID)
        }
        
    }
    
}
