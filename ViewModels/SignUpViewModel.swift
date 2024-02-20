//
//  SignUpViewModel.swift
//  SwiftUITest
//
//  Created by Gia Huy on 20/02/2024.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    
    private var cancelableBag = Set<AnyCancellable>()
    
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    var usernameError = ""
    var emailError = ""
    var passwordError = ""
    var confirmPasswordError = ""
    
    private var usernameValidPublisher: AnyPublisher<Bool, Never> {
        return $username
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    init() {
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Username is missing" }
            .assign(to: \.usernameError, on: self)
            .store(in: &cancelableBag)
    }
}
