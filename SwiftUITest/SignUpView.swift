//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Gia Huy on 19/02/2024.
//

import SwiftUI

struct SignUpView: View {
    
    @State var username = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    var usernameError = "Required"
    var emailError = "Required"
    var passwordError = "Required"
    var confirmPasswordError = ""
    
    var body: some View {
        ZStack {
            ColorCodes.primary.color().edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Text("Green Glocery")
                    .font(Font.custom("Noteworthy-Bold", size: 40.0))
                    .foregroundColor(.white)
                    .padding(.bottom, 60.0)
                    
                AuthTextfield(title: "Username", textValue: $username, errorValue: usernameError)
                AuthTextfield(title: "Email", textValue: $email, errorValue: emailError, keyboardType: .emailAddress)
                AuthTextfield(title: "Password", textValue: $password, errorValue: passwordError, isSecured: true)
                AuthTextfield(title: "Confirm Password", textValue: $confirmPassword, errorValue: confirmPasswordError, isSecured: true)
            }
            .padding(60.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
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
            }
            else {
                TextField(title, text: $textValue)
                    .padding()
                    .background(ColorCodes.background.color())
                    .cornerRadius(5.0)
                    .keyboardType(keyboardType)
            }
            Text(errorValue)
                .fontWeight(.light)
                .foregroundColor(ColorCodes.failure.color())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
    }
}
