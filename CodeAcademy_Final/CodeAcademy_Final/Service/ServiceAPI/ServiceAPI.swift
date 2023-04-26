////
////  ServiceAPI.swift
////  ViperTaskAPI
////
////  Created by Egidijus Vaitkevičius on 2023-04-01.
////

import UIKit


protocol Registering {
    func registerUser(phoneNumber: String, password: String, currency: String, completion: @escaping (Result<UserRegisterResponse, NetworkError>) -> Void)
}

protocol Logging {
    func loginUser(phoneNumber: String, password: String, completion: @escaping (Result<UserAuthenticationResponse, NetworkError>) -> Void)
}

class ServiceAPI: Registering, Logging {
    
    //MARK: - Properties
    
    let baseURL = "http://134.122.94.77:7000/api/"
    let loginPath = "User/login"
    let registerPath = "User/register"
    
    init(networkService: NetworkRequesting) {
        self.networkService = networkService
    }
    let networkService: NetworkRequesting
    
    //MARK: Action
    
    func registerUser(phoneNumber: String, password: String, currency: String, completion: @escaping (Result<UserRegisterResponse, NetworkError>) -> Void) {
        let url = URL(string: "http://134.122.94.77:7000/api/User/register")!
        let registerRequest = UserRegisterRequest(phoneNumber: phoneNumber, password: password, currency: currency)
        let data = try! JSONEncoder().encode(registerRequest)
        
        networkService.postRequest(url: url, body: data) { result in
            switch result {
                case .success(let data):
                    
                    guard let userResponse = try? JSONDecoder().decode(UserRegisterResponse.self, from: data) else {
                        completion(.failure(.init(statusCode: -1, errorType: .decodingFailed)))
                        return
                    }
                    
                    let user = UserRegisterResponse(userId: userResponse.userId)
                    completion(.success(user))
                    print(user.userId)
                    
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func loginUser(phoneNumber: String, password: String, completion: @escaping (Result<UserAuthenticationResponse, NetworkError>) -> Void) {
        let url = URL(string: "http://134.122.94.77:7000/api/User/login")!
        let loginRequest = UserAuthorizationRequest(phoneNumber: phoneNumber, password: password)
        let data = try! JSONEncoder().encode(loginRequest)
        print("DATA \(data)")
        networkService.postRequest(url: url, body: data) { result in
            switch result {
                case .success(let data):
                    guard let userResponse = try? JSONDecoder().decode(UserAuthenticationResponse.self, from: data) else {
                        completion(.failure(.init(statusCode: -1, errorType: .decodingFailed)))
                        return
                    }
                    let loggedUser = UserAuthenticationResponse(userId: userResponse.userId, validUntil: userResponse.validUntil, accessToken: userResponse.accessToken, accountInfo: userResponse.accountInfo)
                    completion(.success(loggedUser))
                case .failure(let error):
                    completion(.failure(error))
                    print("ERROR \(error.localizedDescription)")
                    
            }
        }
    }
    
    func addMoney(accountId: Int, amountToAdd: Double, completion: @escaping (Result<UpdateBalanceResponse, NetworkError>) -> Void) {
        let url = URL(string: "http://134.122.94.77:7000/api/Accounts")!
        let updateBalanceRequest = UpdateBalanceRequest(accountId: accountId, amountToAdd: amountToAdd)
        let data = try! JSONEncoder().encode(updateBalanceRequest)
        
        networkService.putRequest(url: url, body: data) { result in
            switch result {
                case .success(let data):
                    guard let requestResponse = try? JSONDecoder().decode(UpdateBalanceResponse.self, from: data) else {
                        completion(.failure(.init(statusCode: -1, errorType: .decodingFailed)))
                        return
                    }
                    let newUpdatedBalance = UpdateBalanceResponse(id: requestResponse.id, currency: requestResponse.currency, balance: requestResponse.balance, ownerPhoneNumber: requestResponse.ownerPhoneNumber)
                    completion(.success(newUpdatedBalance))
                case .failure(let error):
                    completion(.failure(error))
                    print("error updating task: \(error.localizedDescription) Error ServiceAPI AddMoney() -> networkService.putRequest()")
            }
        }
        
    }
    
    func updateUser(currentPhoneNumber: String, newPhoneNumber: String, newPassword: String, accessToken: String, completion: @escaping (Result<UpdateUserResponse, NetworkError>) -> Void) {
        let url = URL(string: "http://134.122.94.77:7000/api/User")!
        let updateUserRequest = UpdateUserRequest(currentPhoneNumber: currentPhoneNumber, newPhoneNumber: newPhoneNumber, newPassword: newPassword, token: accessToken)
        let data = try! JSONEncoder().encode(updateUserRequest)
        networkService.putRequest(url: url, body: data) { result in
            switch result {
                case .success(let data):
                    guard let requestResponse = try? JSONDecoder().decode(UpdateUserResponse.self, from: data) else {
                        completion(.failure(.init(statusCode: -1, errorType: .decodingFailed)))
                        return
                    }
                    let newUpdatedUser =
                    UpdateUserResponse(userId: requestResponse.userId, validUntil: requestResponse.validUntil, accessToken: requestResponse.accessToken, accountInfo: requestResponse.accountInfo)
                    completion(.success(newUpdatedUser))
                case .failure(let error):
                    print("error updating task: \(error.localizedDescription) Error ServiceAPI UpdateUser() -> networkService.putRequest()")
            }
        }
    }
    
    func transferMoney(senderPhoneNumber: String, token: String, senderAccountId: Int, receiverPhoneNumber: String, amount: Double, comment: String, completion: @escaping (Result<Void, NetworkError>) -> Void)  {
        let url = URL(string: "http://134.122.94.77:7000/api/Transactions")!
        let transferRequest = Transfer(senderPhoneNumber: senderPhoneNumber, token: token, receiverPhoneNumber: receiverPhoneNumber, senderAccountId: senderAccountId, amount: amount, comment: comment)
        
        let data = try! JSONEncoder().encode(transferRequest)
        networkService.postRequest(url: url, body: data) { result in
            switch result {
                case .success(_):
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                    print("ERROR TRANSFERMoney Failure on Post Request \(error.localizedDescription)")
                    
            }
        }
    }

    func fetchingTransactions(url: URL, completion: @escaping (Result<[TransactionInfo],Error>) -> Void) {
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            
            guard let data = data else { return }
            if let error = error {
                completion(.failure(error))
                print("DataTask error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            DispatchQueue.main.async {
                
                do {
                    let transactions = try JSONDecoder().decode([TransactionInfo].self, from: data)
                    completion(.success(transactions))
                    
                    CoreDataManager.sharedInstance.saveDataOf(transactions: transactions)
                    
                } catch let error {
                    print("Error decoding JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        dataTask.resume()
    }
    
    func buildURL(urlPath: String) -> URL? {
        let baseURL = URL(string: baseURL)
        let createdURL = baseURL?.appending(path: urlPath)
        
        return createdURL
    }
}

struct URLBuilder {
    private static let kURLStringTransaction = "http://134.122.94.77:7000/api/Transactions/"
    static func getTaskURL() -> URL {
        URL(string: kURLStringTransaction)!
    }
    
    static func getTaskURL(withId id: Int) -> URL {
        URL(string: kURLStringTransaction + "?accountId=\(id)")!
    }
}
