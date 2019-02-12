//
//  NetworkService.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/14/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import Foundation

typealias Completion = (_ forecast: Int?) -> Void

private let projectId = "backme-35aa8"

struct NetworkService {
    static func forecast(_ completion: @escaping Completion) {
        let forecastUrl = URL(string: "https://\(projectId).firebaseio.com/forecast.json?print=pretty")!
        let request = URLRequest(url: forecastUrl)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                        print("OK1")
                        completion(nil)
                        return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data!) as! [String: Any]
                let forecast = json["Dnipro"] as! Int
                print("OK2")
                completion(forecast)
            }
        }
        
        task.resume()
    }
    
    static func uploadImage(withName name: String,
                            url: URL,
                            sessionDelegate: URLSessionDelegate) -> URLSessionUploadTask {
        
        let string = "https://firebasestorage.googleapis.com/v0/b/\(projectId).appspot.com/o/" + name
        let requestUrl = URL(string: string)!
        
        var request = URLRequest(url: requestUrl)
        request.setValue("image/png", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let configuration = URLSessionConfiguration.background(withIdentifier: name)
        let session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)
        
        let task = session.uploadTask(with: request, fromFile: url)
        task.resume()
        
        return task
    }
}
