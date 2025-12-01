//
//  SignInViewModel.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 08.10.2023.
//

import Foundation
import FirebaseAuth
import Firebase
import SwiftUI


class SignInViewModel: ObservableObject {
    
    @Published var isSignedIn = false
    @Published var errorMsg : LocalizedStringKey = "";
    @Published var progressMsg : LocalizedStringKey = "";
    
    let auth = Auth.auth()
    
    
    func reloadLoginStatus(){
        self.isSignedIn = (auth.currentUser != nil)
    }
    
   init(){
       reloadLoginStatus()
    }
    
    func getUserID() -> String{
        return auth.currentUser?.uid ?? ""
    }
    
    func getEmail() -> String{
        return auth.currentUser?.email ?? ""
    }
    
    func getCreationDate() -> Date? {
        return auth.currentUser?.metadata.creationDate
    }
    
    func getLastActivityDate() -> Date? {
        return auth.currentUser?.metadata.lastSignInDate
    }
    
    
    func getDisplayName() -> String{
        return auth.currentUser?.displayName ?? ""
    }
    
    
    func ConfirmPassword(password: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        let credential = EmailAuthProvider.credential(withEmail: getEmail(), password: password)
        auth.currentUser?.reauthenticate(with: credential){_, error in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.success(true))
            }
        }        
    }
    
    func SignIn(email: String, password: String){
        self.errorMsg = "";
        self.progressMsg = "Signing in request..";
        auth.signIn(withEmail: email, password: password){
            result, error in
            guard result != nil, error == nil else {
                print("sign in error")
                let err = error as! AuthErrorCode
                
                switch err {
                case AuthErrorCode.userDisabled: self.errorMsg = "User Disabled"; break
                case AuthErrorCode.invalidEmail: self.errorMsg = "Invalid Email"; break
                case AuthErrorCode.missingEmail: self.errorMsg = "Invalid Email"; break
                case AuthErrorCode.wrongPassword: self.errorMsg = "Wrong password!"; break
                case AuthErrorCode.invalidCredential: self.errorMsg = "Invalid Credentials"; break
                case AuthErrorCode.userMismatch: self.errorMsg = "Invalid Credentials"; break
                case AuthErrorCode.userNotFound: self.errorMsg = "Invalid Credentials"; break
                case AuthErrorCode.internalError: self.errorMsg = "Invalid Credentials"; break
                
                default:
                    print(err)
                    self.errorMsg = "Unknown Error"
                }
                self.progressMsg = "";
                return
                }
            
            //success
            print("Signed IN");
            self.progressMsg = "";
            if result!.user.isEmailVerified {
                self.reloadLoginStatus();
            }else{
                self.errorMsg = "Kindly review your email for the activation link!"
//                result!.user.sendEmailVerification()
                self.SignOut()
            }
            
            
            
            
        }
    }
    
    
    func SignUp(email: String, password: String){
        self.errorMsg = "";
        print("creating user");
        progressMsg = "Creating user request.."
        auth.createUser(withEmail: email, password: password){ [self]
            result, error in
            guard result != nil, error == nil else {
                print("creating user error")
                let err = error as! AuthErrorCode
                
                switch err {
                case AuthErrorCode.invalidEmail: self.errorMsg = "Invalid Email"; break
                case AuthErrorCode.missingEmail: self.errorMsg = "Missing Email"; break
                case AuthErrorCode.emailAlreadyInUse: self.errorMsg = "Email already in use"; break
                case AuthErrorCode.weakPassword: self.errorMsg = "Weak password"; break
                    
                    
                default:
                    print(err)
                    self.errorMsg = "Unknown Error"
                }
                
               // self.errorMsg = String(err.code) // error?.localizedDescription ?? ""
                self.progressMsg = "";
                return
                }
            
            //success
            print("creating user success");
            progressMsg = "Success"
            //get display name from email
            var displayName = ""
            for i in 0..<email.count {
                
                let index = email.index(email.startIndex, offsetBy: i)
                if(email[index] != "@"){
                    displayName.append(email[index])
                }else{break}
            }
            
            self.ChangeDisplayName(DisplayName: String(displayName))
            print("Email: \(email)")
            print("DefaultUsername setted to \(displayName)")
         
           // userModel.db_CreateUserDataDocument()
         //   userModel.db_CreateUserInfo(UserID: auth.currentUser?.uid ?? "", DisplayName: String(disName))
          //  progressMsg = "Signing in..".localized
         //  self.SignIn(email: email, password: password)
            print("sending email verification")
            result?.user.sendEmailVerification()
            progressMsg = "Kindly review your email for the activation link!"
            
            
        }
    }
    
    
    
    
    func SignInWithApple(userId: String,
                         email: String?,
                         token: String?,
                         fullName: PersonNameComponents?,
                         nonce: String) {

        self.progressMsg = "Signing in with Apple..."

        guard let token = token else {
            self.errorMsg = "Missing Apple token"
            self.progressMsg = ""
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: token,
            rawNonce: nonce,
            fullName: fullName
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                self.errorMsg = "Apple Sign In failed: \(error.localizedDescription)"
                self.progressMsg = ""
                return
            }

            guard let user = authResult?.user else { return }

            print("Firebase Apple UID: \(user.uid)")
            print("Email: \(email ?? user.email ?? "none")")
           
            self.progressMsg = "Signed in successfully!"


            let isNewUser = authResult?.additionalUserInfo?.isNewUser ?? false
            
            if isNewUser{
                // -----------------------
                // 🔥 Change Display Name for new users
                // -----------------------
                var displayName = ""
                // display name from apple
                if let fullName = fullName {
                    let formatter = PersonNameComponentsFormatter()
                    let nameString = formatter.string(from: fullName)
                    displayName = nameString
                    print("displayName from Apple : \(nameString)")
                    
                }
                // if not get from apple, random it
                if displayName == "" {
                    let randomNum = Int.random(in: 1000...9999)
                    let usernamePart = user.email?.components(separatedBy: "@").first ?? "AppleUser"
                    let nameString = "\(usernamePart)\(randomNum)"
                    displayName = nameString
                    print("displayName generated : \(nameString)")
                }
                
                print("Changing display name...")
                
                self.ChangeDisplayName(DisplayName: displayName) {
                    
                    // Clear message after a short moment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.progressMsg = ""
                        self.reloadLoginStatus()
                    }
                }
            } else{
                self.progressMsg = ""
                self.reloadLoginStatus()
            }
            
        }
    }


    
    
    func unregister() {
        auth.currentUser?.delete()
        UserDefaults.standard.set("", forKey: "mail")
        UserDefaults.standard.set("", forKey: "password")
    }
    
//    func ChangeDisplayName(DisplayName: String){
//        //change display name
//        if let currentUser = Auth.auth().currentUser?.createProfileChangeRequest() {
//            currentUser.displayName = DisplayName
//            currentUser.commitChanges(completion: {error in
//                if let error = error {
//                    print(error)
//                } else {
//                    print("DisplayName changed")
//                }
//            })
//        } else {
//            print("No current user")
//        }
//    }
    
    
    func ChangeDisplayName(DisplayName: String, completion: (() -> Void)? = nil) {
        guard let request = Auth.auth().currentUser?.createProfileChangeRequest() else {
            print("No current user")
            completion?()
            return
        }

        request.displayName = DisplayName
        request.commitChanges { error in
            if let error = error {
                print("Display name change error: \(error.localizedDescription)")
            } else {
                print("Display name changed successfully.")
            }
            completion?()   // Only called if provided
        }
    }
    
    
    func SignOut(){
        do{
            try auth.signOut()
        }catch{}
        
        self.reloadLoginStatus()
    }
    
    
  
    

    
    
    
}
