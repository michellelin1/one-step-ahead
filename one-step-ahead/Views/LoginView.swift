//
//  LoginView.swift
//  one-step-ahead
//
//  Created by michelle on 2/6/24.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
//    @EnvironmentObject var authHandler: AuthViewModel
     @StateObject var authHandler: AuthViewModel = AuthViewModel()
    
    var body: some View {
        VStack {
            TextField("email", text: $email)
                .autocapitalization(.none)
            SecureField("password", text: $password)
            Button(action: {
                Task {
                    await authHandler.signIn(email: email, password: password)
                    self.email = ""
                    self.password = ""
                }
            }) {
                Text("Login")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .font(.system(size: 18))
                    .padding(10)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white, lineWidth: 1.5)
                )
            }
            .background(.pink) // If you have this
            .cornerRadius(10)
            
            Button("Sign Up") {
                Task {
                    await authHandler.createUser(email: email, password: password)
                    self.email = ""
                    self.password = ""
                }
            }
            
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
