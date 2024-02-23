//
//  SignUpErrorModel.swift
//  SwiftUITest
//
//  Created by Gia Huy on 22/02/2024.
//

import Foundation

struct SignUpErrorModel: Codable {
    let validationErrors: ValidationErrors
    
    enum CodingKeys: String, CodingKey {
        case validationErrors = "validation_errors"
    }
}

struct ValidationErrors: Codable {
    let name, email, password: [String]?
}
