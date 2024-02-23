//
//  AuthHttpRouter.swift
//  SwiftUITest
//
//  Created by Gia Huy on 22/02/2024.
//

import Alamofire

enum AuthHttpRouter {
    case signUp(user: AuthModel)
    case validateEmail(email: String)
}

extension AuthHttpRouter: HttpRouter {
    
    var baseUrlString: String {
        return "https://letscodeeasy.com/groceryapi/public/api"
    }
    
    var path: String{
        switch (self) {
        case .signUp:
            return "register"
        case .validateEmail:
            return "validate/email"
        default:
            return ""
        }
    }
    
    var method: HTTPMethod {
        switch (self) {
        case .signUp, .validateEmail:
            return .post
        default:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        switch (self) {
        case .signUp, .validateEmail:
            return [
                "Content-Type:": "application/json; charset=UTF-8"
            ]
        }
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    func body() throws -> Data? {
        switch (self) {
        case .signUp(let user):
            return try JSONEncoder().encode(user)
        case .validateEmail(let email):
            return try JSONEncoder().encode(["email": email])
        }
    }
    
}
