//
//  NetworkService.swift
//  CodeAcademy_Final-Egidijus
//
//  Created by Egidijus Vaitkevičius on 2023-04-01.
//

import UIKit

protocol NetworkRequesting {
    func postRequest(url: URL, body: Data?, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func getRequest(url: URL, completion: @escaping (Data?) -> Void)
    func putRequest(url: URL, body: Data?, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

class NetworkService: NetworkRequesting {
    /// POST method
    /// - Parameters:
    ///   - url: "base url"
    ///   - body: data
    ///   - completion: Inserts data into the server
    func postRequest(url: URL, body: Data?, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            
            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                guard let data = data else {
                    completion(.failure(.init(statusCode: statusCode, errorType: .unknown)))
                    return
                }
                
                let dataString = String(data: data, encoding: .utf8)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.init(statusCode: statusCode, errorType: .unknown)))
                    return
                }
                
                switch httpResponse.statusCode {
                    case 200:
                        completion(.success(data))
                    case 400:
                        // If the request is incorrect
                        completion(.failure(.init(message: dataString, statusCode: statusCode, errorType: .badRequest)))
                    case 401:
                        // If the token is invalid
                        completion(.failure(.init(message: dataString, statusCode: statusCode, errorType: .notFound)))
                    case 409:
                        // If the receiver does not have an account with the provided currency or there's not enough money in senders account
                        completion(.failure(.init(message: dataString, statusCode: statusCode, errorType: .notFound)))
                    default:
                        print("Completion was not handled")
                }
            }
        }.resume()
    }
    
    /// GET method
    /// - Parameters:
    ///   - url: base URL
    ///   - completion: Fetches data from the server
    func getRequest(url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            data,
            response,
            error in
            guard let data else {
                completion(nil)
                return
            }
            
            completion(data)
        }.resume()
    }
    
    /// PUT method
    /// - Parameters:
    ///   - url: "http://134.122.94.77:7000/api/User"
    ///   - completion: Updates data in the server
    public func putRequest(url: URL,
                           body: Data?,
                           completion: @escaping (Result<Data, NetworkError>) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            
            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                guard let data = data else {
                    completion(.failure(.init(statusCode: statusCode, errorType: .unknown)))
                    return
                }
                
                let dataString = String(data: data, encoding: .utf8)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.init(statusCode: statusCode, errorType: .unknown)))
                    return
                }
                
                switch httpResponse.statusCode {
                    case 200:
                        completion(.success(data))
                    case 400:
                        completion(.failure(.init(message: dataString, statusCode: statusCode, errorType: .badRequest)))
                    case 401:
                        completion(.failure(.init(message: dataString, statusCode: statusCode, errorType: .notFound)))
                    case 409:
                        completion(.failure(.init(message: dataString, statusCode: statusCode, errorType: .notFound)))
                    default:
                        break
                }
            }
        }.resume()
    }
}
