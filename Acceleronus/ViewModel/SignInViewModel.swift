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
    @Published var errorMsg = "";
    @Published var progressMsg = "";
    
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
        self.progressMsg = "Signing in request..".localized;
        auth.signIn(withEmail: email, password: password){
            result, error in
            guard result != nil, error == nil else {
                print("sign in error")
                let err = error as! AuthErrorCode
                
                switch err {
                case AuthErrorCode.userDisabled: self.errorMsg = "User Disabled".localized; break
                case AuthErrorCode.invalidEmail: self.errorMsg = "Invalid Email".localized; break
                case AuthErrorCode.missingEmail: self.errorMsg = "Invalid Email".localized; break
                case AuthErrorCode.wrongPassword: self.errorMsg = "Wrong password!".localized; break
                case AuthErrorCode.invalidCredential: self.errorMsg = "Invalid Credentials".localized; break
                case AuthErrorCode.userMismatch: self.errorMsg = "Invalid Credentials".localized; break
                case AuthErrorCode.userNotFound: self.errorMsg = "Invalid Credentials".localized; break
                case AuthErrorCode.internalError: self.errorMsg = "Invalid Credentials".localized; break
                
                default:
                    print(err)
                    self.errorMsg = "Unknown Error".localized
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
                self.errorMsg = "Kindly review your email for the activation link!".localized
//                result!.user.sendEmailVerification()
                self.SignOut()
            }
            
            
            
            
        }
    }
    
    
    func SignUp(email: String, password: String){
        self.errorMsg = "";
        print("creating user");
        progressMsg = "Creating user request..".localized
        auth.createUser(withEmail: email, password: password){ [self]
            result, error in
            guard result != nil, error == nil else {
                print("creating user error")
                let err = error as! AuthErrorCode
                
                switch err {
                case AuthErrorCode.invalidEmail: self.errorMsg = "Invalid Email".localized; break
                case AuthErrorCode.missingEmail: self.errorMsg = "Missing Email".localized; break
                case AuthErrorCode.emailAlreadyInUse: self.errorMsg = "Email already in use".localized; break
                case AuthErrorCode.weakPassword: self.errorMsg = "Weak password".localized; break
                    
                    
                default:
                    print(err)
                    self.errorMsg = "Unknown Error".localized
                }
                
               // self.errorMsg = String(err.code) // error?.localizedDescription ?? ""
                self.progressMsg = "";
                return
                }
            
            //success
            print("creating user success");
            progressMsg = "Success".localized
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
            progressMsg = "Kindly review your email for the activation link!".localized
            
            
        }
    }
    
    func unregister() {
        auth.currentUser?.delete()
        UserDefaults.standard.set("", forKey: "mail")
        UserDefaults.standard.set("", forKey: "password")
    }
    
    func ChangeDisplayName(DisplayName: String){
        //change display name
        if let currentUser = Auth.auth().currentUser?.createProfileChangeRequest() {
            currentUser.displayName = DisplayName
            currentUser.commitChanges(completion: {error in
                if let error = error {
                    print(error)
                } else {
                    print("DisplayName changed")
                }
            })
        }
    }
    
    func SignOut(){
        do{
            try auth.signOut()
        }catch{}
        
        self.reloadLoginStatus()
    }
    
    
  
    

    
    
    
}
