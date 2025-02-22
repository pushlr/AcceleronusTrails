//
//  SignInView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 08.10.2023.
//

import SwiftUI


struct SignInView: View {
    @EnvironmentObject var  auth : SignInViewModel
    @State var mail = UserDefaults.standard.string(forKey: "mail") ?? ""
    @State var password = UserDefaults.standard.string(forKey: "password") ?? ""
    
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
            
            
            
            Text(auth.progressMsg.isEmpty ? " " : auth.progressMsg)
            Text(auth.errorMsg.isEmpty ? " " : "Error!".localized + " " + auth.errorMsg)
                .foregroundStyle(.red)
            
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
            
        }
        .background(Color.white)
        
        
    
    }
}


#Preview {
    SignInView().environmentObject(SignInViewModel())
}
