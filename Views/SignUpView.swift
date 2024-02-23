//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Gia Huy on 19/02/2024.
//

import SwiftUI

struct SignUpView: View {
    
    @ObservedObject private var viewModel: SignUpViewModel
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            ColorCodes.primary.color().edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Text("Green Glocery")
                    .font(Font.custom("Noteworthy-Bold", size: 40.0))
                    .foregroundColor(.white)
                    .padding(.bottom, 60.0)
                    
                AuthTextfield(title: "Username", textValue: $viewModel.username, errorValue: viewModel.usernameError)
                AuthTextfield(title: "Email", textValue: $viewModel.email, errorValue: viewModel.emailError, keyboardType: .emailAddress)
                AuthTextfield(title: "Password", textValue: $viewModel.password, errorValue: viewModel.passwordError, isSecured: true)
                AuthTextfield(title: "Confirm Password", textValue: $viewModel.confirmPassword, errorValue: viewModel.confirmPasswordError, isSecured: true)
                
                Button(action: viewModel.signUp) {
                    Text("Sign Up")
                }
                .frame(minWidth: 0.0, maxWidth: .infinity)
                .foregroundColor(Color.white)
                .padding()
                .background( viewModel.enableSignUpButton ? Color.black : Color.gray)
                .cornerRadius(.infinity)
                .padding(.top, 20.0)
                .disabled(!viewModel.enableSignUpButton)
                
                Text(viewModel.statusViewModel.title)
                    .font(.headline)
                    .foregroundColor(viewModel.statusViewModel.color.color())
                    .fontWeight(.light)
                    .padding()
            }
            .padding(60.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SignUpViewModel(authApi: AuthService.shared, authServiceParser: AuthServiceParser.shared)
        return SignUpView(viewModel: viewModel)
    }
}

extension ColorCodes {
    func color() -> Color {
        switch self {
        case .primary:
            return Color(red: 79/255,
                         green: 139/255,
                         blue: 43/255)
        case .success:
            return Color(red: 0,
                         green: 0,
                         blue: 0)
        case .failure:
            return Color(red: 219/255,
                         green: 12/255,
                         blue: 12/255)
            
        case .background:
            return Color(red: 239/255,
                        green: 243/255,
                         blue: 244/255)
        }
    }
}

struct AuthTextfield: View {
    
    var title: String
    @Binding var textValue: String
    var errorValue: String
    var isSecured: Bool = false
    var keyboardType: UIKeyboardType = .default
    var body: some View {
        
        VStack(spacing: 0) {
            if (isSecured) {
                SecureField(title, text: $textValue)
                    .padding()
                    .background(ColorCodes.background.color())
                    .cornerRadius(5.0)
                    .keyboardType(keyboardType)
                    .padding(.bottom, 5.0)
            }
            else {
                TextField(title, text: $textValue)
                    .padding()
                    .background(ColorCodes.background.color())
                    .cornerRadius(5.0)
                    .keyboardType(keyboardType)
                    .padding(.bottom, 5.0)
            }
            Text(errorValue)
                .fontWeight(.light)
                .foregroundColor(ColorCodes.failure.color())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.bottom, 5.0)
    }
}
