//
//  SwiftUITestApp.swift
//  SwiftUITest
//
//  Created by Gia Huy on 19/02/2024.
//

import SwiftUI

@main
struct SwiftUITestApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = SignUpViewModel(authApi: AuthService.shared, authServiceParser: AuthServiceParser.shared)
            SignUpView(viewModel: viewModel)
        }
    }
}
