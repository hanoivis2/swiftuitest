//
//  AuthModel.swift
//  SwiftUITest
//
//  Created by Gia Huy on 22/02/2024.
//

struct AuthModel: Codable {
    
    let name: String
    let email: String
    let password: String
    
    init (name: String = "", email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
    
}
