//
//  AuthAPI.swift
//  SwiftUITest
//
//  Created by Gia Huy on 22/02/2024.
//

import Combine
import Foundation

protocol AuthAPI {
    func signUp(username: String,
                 email: String,
                 password: String)  -> Future <(statusCode:Int, data:Data), Error>
    
    func validateEmail(email: String) -> Future<Bool, Never>
}
