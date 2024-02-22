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
     @StateObject var authHandler: AuthViewModel = AuthViewModel()
    
    var body: some View {
        VStack {
            Text("Sign In").font(.system(size: 30)).bold()
            Text("Click Sign Up to Create Account").padding(.bottom)
            Spacer().frame(height: 10)
            TextField("email", text: $email)
                .autocapitalization(.none)
                .padding(10)
                .background(Color.gray.opacity(0.1)) // Set background color to white
                .cornerRadius(10)
            SecureField("password", text: $password)
                .padding(10)
                .background(Color.gray.opacity(0.1)) // Set background color to white
                .cornerRadius(10)
                .padding(.bottom)
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
            .background(.pink.opacity(0.9))
            .cornerRadius(10)
            
            Button("Sign Up") {
                Task {
                    await authHandler.createUser(email: email, password: password)
                    self.email = ""
                    self.password = ""
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(10)
            .background(Color.gray.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(10)
            
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
