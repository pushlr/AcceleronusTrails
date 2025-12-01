//
//  SignInView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 08.10.2023.
//

import SwiftUI


struct SignInView: View {
    @EnvironmentObject var  auth : SignInViewModel

    @State var lang = ""
    
    @State var mail = UserDefaults.standard.string(forKey: "mail") ?? ""
    @State var password = UserDefaults.standard.string(forKey: "password") ?? ""
    
    @MainActor
    private func initialize() async {
        let defaults = UserDefaults.standard
        
        if(defaults.string(forKey: "app_language") != nil){
            lang = defaults.string(forKey: "app_language") ?? ""
        }else{
            
            let preferred = Locale.preferredLanguages.first   // "ru-UA"
            let code = String(preferred?.prefix(2) ?? "en")   // "ru"
            
            if let appLang = AppLanguage(rawValue: code) {
                lang = appLang.rawValue
            } else {
                lang = AppLanguage.en.rawValue
            }
        }
        
    }
    
    var body: some View {
        VStack() {
            
            Spacer();
           
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Hello")
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .cornerRadius(15)
                .font(.largeTitle)

            
            TextField("Email", text: $mail)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textFieldStyle(TextField_Default())
                .padding(.horizontal, 20)
                
            
            SecureField("Password", text: $password,prompt: nil)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textFieldStyle(TextField_Default())
                .padding(.horizontal, 20)
            
            
            
//            Text(auth.progressMsg.isEmpty ? " " : auth.progressMsg)
//            Text(auth.errorMsg.isEmpty ? " " : "Error!" + " " + auth.errorMsg)
//                .foregroundStyle(.red)
  
            Text(
                auth.progressMsg == "" ?
                (auth.errorMsg == "" ? "\u{00A0}" : auth.errorMsg)   //\u{00A0} - keep its height even when the string is empty.
                :
                auth.progressMsg
            )
            .foregroundStyle(auth.errorMsg == "" ? .black : .red)

            
            Button{
                guard !mail.isEmpty, !password.isEmpty else {return}
                UserDefaults.standard.set(mail, forKey: "mail")
                UserDefaults.standard.set(password, forKey: "password")
                
                auth.SignIn(email: mail, password: password)
                
            }label: {
                Text("Sign In")
                
                    
            }.buttonStyle(ButtonDefault(ButtonColor: Color.green,width: UIScreen.main.bounds.width / 2))
            
            
            Text("or")
            
            Button{
                guard !mail.isEmpty, !password.isEmpty else {return}
                UserDefaults.standard.set(mail, forKey: "mail")
                UserDefaults.standard.set(password, forKey: "password")
                
                auth.SignUp(email: mail, password: password)
                
            }label: {
                Text("Create an account")
            }.buttonStyle(ButtonDefault(ButtonColor: Color.black,width: UIScreen.main.bounds.width / 2))
            
            Spacer()
            
            //Sign in with Apple
            SignInWithAppleButtonView { userId, email, token, fullName, nonce in
                auth.SignInWithApple(userId: userId, email: email, token: token, fullName: fullName, nonce: nonce)
            }
            .frame(height: 50)
            .padding(.horizontal, 20)

            
        }
        .background(Color.white)
        .environment(\.locale, Locale(identifier: lang))
        .task {
               await initialize()
           
        }

        
        
    
    }
}


#Preview {
    SignInView().environmentObject(SignInViewModel())
}
