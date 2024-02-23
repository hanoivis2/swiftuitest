//
//  SignUpViewModel.swift
//  SwiftUITest
//
//  Created by Gia Huy on 20/02/2024.
//

import Foundation
import Combine

class StatusViewModel: ObservableObject {
    
    var title: String
    var color: ColorCodes
    
    init(title: String, color: ColorCodes) {
        self.title = title
        self.color = color
    }
}

class SignUpViewModel: ObservableObject {
    
    private let authApi: AuthAPI
    private let authServieParser: AuthServiceParser
    private var cancellableBag = Set<AnyCancellable>()
    
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var usernameError = ""
    @Published var emailError = ""
    @Published var passwordError = ""
    @Published var confirmPasswordError = ""
    @Published var enableSignUpButton:Bool = false
    @Published var statusViewModel: StatusViewModel = StatusViewModel(title: "", color: .success)
    
    private var usernameValidPublisher: AnyPublisher<Bool, Never> {
        return $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    private var emailRequiredPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        return $email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { (email: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    private var emailValidPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        return emailRequiredPublisher
            .filter{ $0.isValid }
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { (email: $0.email, isValid: $0.email.isValidEmail()) }
            .eraseToAnyPublisher()
    }
    
    private var emailServerValidPublisher: AnyPublisher<Bool, Never> {
        return emailValidPublisher
            .filter{ $0.isValid }
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { $0.email }
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { [authApi] in authApi.validateEmail(email: $0) }
            .eraseToAnyPublisher()
    }
    
    private var passwordRequiredPublisher: AnyPublisher<(password: String, isValid: Bool), Never> {
        return $password
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { (password: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidPublisher: AnyPublisher<Bool, Never> {
        return passwordRequiredPublisher
            .filter { $0.isValid }
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { $0.password.isValidPassword() }
            .eraseToAnyPublisher()
    }
    
    private var confirmPasswordRequiredPublisher: AnyPublisher<(confirmPassword: String, isValid: Bool), Never> {
        return $confirmPassword
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { (confirmPassword: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }

    private var passwordEqualValidPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($password, $confirmPassword)
            .filter { !$0.0.isEmpty && !$0.1.isEmpty}
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { password, confirm in
                return password == confirm
            }
            .eraseToAnyPublisher()
    }
    
    
    
    init(authApi: AuthAPI, authServiceParser: AuthServiceParser) {
        
        self.authApi = authApi
        self.authServieParser = authServiceParser
        
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Username is missing" }
            .assign(to: \.usernameError, on: self)
            .store(in: &cancellableBag)
        
        emailRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Email is missing" }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        
        emailValidPublisher
            .receive(on: RunLoop.main)
            .map { $0.isValid ? "" : "Email is not valid" }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        
        emailServerValidPublisher
            .receive(on: RunLoop.main)
            .map { $0 ? "" : "Email is already used" }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        
        passwordRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Password is missing" }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)
        
        passwordValidPublisher
            .receive(on: RunLoop.main)
            .map { $0 ? "" : "Password must be 8 characters with 1 alphabet and 1 number" }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)

        confirmPasswordRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Confirm password is missing" }
            .assign(to: \.confirmPasswordError, on: self)
            .store(in: &cancellableBag)
        
       passwordEqualValidPublisher
            .receive(on: RunLoop.main)
            .map { $0 ? "" : "Password confirmed does not match"}
            .assign(to: \.confirmPasswordError, on: self)
            .store(in: &cancellableBag)
        
        Publishers.CombineLatest4(usernameValidPublisher,
                                  emailServerValidPublisher,
                                  passwordValidPublisher,
                                  passwordEqualValidPublisher)
        .map { username, email, password, confirm in
            return username && email && password && confirm
        }
        .receive(on: RunLoop.main)
        .assign(to: \.enableSignUpButton, on: self)
        .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
    }
}

extension SignUpViewModel {
    
    func signUp() -> Void {
        authApi
            .signUp(username: username, email: email, password: password)
            .flatMap { [authServieParser] in
                authServieParser.parseSignUpResponse(statusCode: $0.statusCode, data: $0.data)
            }
            .map { result -> StatusViewModel in
                switch (result) {
                case .success(let value):
                    return StatusViewModel(title: "Sign up successfful!", color: ColorCodes.success)
                case .failure(let message):
                    return StatusViewModel(title: "Sign up failed!", color: ColorCodes.failure)
                }
            }
            .receive(on: RunLoop.main)
            .replaceError(with: StatusViewModel(title: "Sign up failed!", color: ColorCodes.failure))
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.username = ""
                self?.email = ""
                self?.password = ""
                self?.confirmPassword = ""
            })
            .assign(to: \.statusViewModel, on: self)
            .store(in: &cancellableBag)
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
