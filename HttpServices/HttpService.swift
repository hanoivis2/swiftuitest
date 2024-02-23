//
//  HttpService.swift
//  SwiftUITest
//
//  Created by Gia Huy on 22/02/2024.
//

import Alamofire

protocol HttpService {
    var sessionManager: Session { get set }
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest
}
