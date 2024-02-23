//
//  TokenResponseModel.swift
//  SwiftUITest
//
//  Created by Gia Huy on 22/02/2024.
//

struct TokenResponseModel: Decodable {
    
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
