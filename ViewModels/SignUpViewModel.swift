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
    
    private var emailRequiredPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        return $email
            .map { (email: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    private var emailValidPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        return emailRequiredPublisher
            .filter{ $0.isValid }
            .map { (email: $0.email, isValid: $0.email.isValidEmail()) }
            .eraseToAnyPublisher()
    }
    
    private var passwordRequiredPublisher: AnyPublisher<(password: String, isValid: Bool), Never> {
        return $password
            .map { (password: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidPublisher: AnyPublisher<(password: String, isValid: Bool), Never> {
        return passwordRequiredPublisher
            .filter { $0.isValid }
            .map { (password: $0.password, isValid: $0.password.isValidPassword()) }
            .eraseToAnyPublisher()
    }
    
    private var confirmPasswordRequiredPublisher: AnyPublisher<(confirmPassword: String, isValid: Bool), Never> {
        return $confirmPassword
            .map { (confirmPassword: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }

    private var passwordEqualValidPublisher: AnyPublisher<(password: String, isValid: Bool), Never> {
        return Publishers.CombineLatest($password, $confirmPassword)
            .filter { !$0.0.isEmpty && !$0.1.isEmpty}
            .map { password, confirm in
                return (password: password, isValid: password == confirm)
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Username is missing" }
            .assign(to: \.usernameError, on: self)
            .store(in: &cancelableBag)
        
        emailRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Email is missing" }
            .assign(to: \.emailError, on: self)
            .store(in: &cancelableBag)
        
        emailValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Email is not valid" }
            .assign(to: \.emailError, on: self)
            .store(in: &cancelableBag)
        
        passwordRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Password is missing" }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancelableBag)
        
        passwordValidPublisher
            .receive(on: RunLoop.main)
            .map { $0.isValid ? "" : "Password must be 8 characters with 1 alphabet and 1 number" }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancelableBag)

        confirmPasswordRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Confirm password is missing" }
            .assign(to: \.confirmPasswordError, on: self)
            .store(in: &cancelableBag)
        
       passwordEqualValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Password confirmed does not match"}
            .assign(to: \.confirmPasswordError, on: self)
            .store(in: &cancelableBag)
    }
    
    deinit {
        cancelableBag.removeAll()
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[!-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidPassword(pattern: String = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$") -> Bool {
        let passwordRegEx = pattern
        return NSPredicate(format: "SELF MATCHES %@", passwordRegEx).evaluate(with: self)
    }
}
