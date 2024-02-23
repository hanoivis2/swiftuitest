//
//  AuthHttpService.swift
//  SwiftUITest
//
//  Created by Gia Huy on 22/02/2024.
//

import Alamofire

final class AuthHttpService: HttpService {
    var sessionManager: Session = Session.default
    
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return sessionManager.request(urlRequest).validate(statusCode: 200..<400)
    }
}
