//
//  UpdateUser_Tests.swift
//  CodeAcademy_FinalTests
//
//  Created by Egidijus Vaitkevičius on 2023-05-03.
//

import XCTest
@testable import CodeAcademy_Final

class MockNetworkRequester: NetworkRequesting {
    
    
    func getRequest(url: URL, completion: @escaping (Data?) -> Void) {
        completion(nil)
    }
    
    func postRequest(url: URL, body: Data?, completion: @escaping (Result<Data, CodeAcademy_Final.NetworkError>) -> Void) {
//        completion(nil)
    }
    
    var didCallPutRequest = false
    
    func putRequest(url: URL, body: Data?, completion: @escaping (Result<Data, CodeAcademy_Final.NetworkError>) -> Void) {
        didCallPutRequest = true
    }

}

final class UpdateUser_Tests: XCTestCase {

    func test_unit_update_user_put_request() {
        let expectation = expectation(description: "Did 'update'")
        let serviceAPI = ServiceAPI(networkService: NetworkService())
        
        let currentPhone = "1"
        let newPhone = "2"
        let newPassword = "2"
        let accessToken = "0"
        
        serviceAPI.updateUser(currentPhoneNumber: currentPhone, newPhoneNumber: newPhone, newPassword: newPassword, accessToken: accessToken, completion: { result in
           
            
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1.0)
    }

}
