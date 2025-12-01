//
//  DeleteAccountView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 02.02.2024.
//

import SwiftUI

struct DeleteAccountView: View {
    @Binding var deleteAccountView : Bool
    @State private var password = ""
    @State private var invalidPassword = false
    @State var logText = ""
    
    @State var deletingIsStarted = false
    @State var deletingIsDone = false
    
    @EnvironmentObject var  auth : SignInViewModel
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var dataStorage : DataStorage
 
    func appendLog(_ str: String){
        withAnimation{
            logText += str
        }
    }
    func addLog(_ str: String){
      appendLog("\n")
      appendLog(str)     
    }
    
    var body: some View {
        NavigationStack {
                VStack {
                    ScrollView{
                        Text("Delete Account")
                        .font(.title)
                        .padding()
                        .padding(.top,20)
                        
                        Text("Are you sure you want to delete your account? This action is irreversible and will permanently delete all your data.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                        Text("All recorded trails will be permanently deleted. This action cannot be undone.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                        SecureField("Enter your password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .disabled(deletingIsStarted)
                    
                    if(invalidPassword){
                        Text("Invalid Password")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    
                    Text(logText)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding()
                        .font(.footnote)

                    
                    }//scrolll
                                        
                    
                    Spacer()
                    
                    
                    //CONTROL BUTTONS BOTTOM
                    if(!deletingIsStarted){
                        HStack {
                            Button("Cancel") { deleteAccountView = false }
                            .buttonStyle(ButtonDefault(ButtonColor: Color.black, width: 100,height: 40))
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button("Delete") {
                                invalidPassword = false
                                logText = ""
                                
                                auth.ConfirmPassword(password: password){ result in
                                    switch result {
                                    case .success :
                                        Task.detached{
                                            await performAccountDeletion()
                                        }
                                    case .failure : invalidPassword = true
                                    }
                                }
                            }.disabled(password.isEmpty)
                            .buttonStyle(
                                    ButtonDefault(
                                        Disabled: false,
                                        ButtonColor: password.isEmpty ? .pastelGray : .red,
                                        width: 150,
                                        height: 40
                                    ))
                            .foregroundColor(.red)
                        }
                        .padding()
                    }
                    
                    
                    
                    

                    
                    if(deletingIsDone){
                        Button{auth.SignOut()}
                        label:{Text("Close")}
                        .buttonStyle(ButtonDefault(ButtonColor: Color.black, width: UIScreen.main.bounds.width-40,height: 40))
                        .padding()
                    }
                    
                }
                .navigationBarTitle("", displayMode: .inline)
            }
        }
    
    
    
    
    
    func performAccountDeletion() async  {
        Task{
            deletingIsStarted = true
            addLog("Initializing account deletion")
            addLog("Getting trails list" + " : ")
            userData.db_GetMyTrailsCount()
            await Task.sleep(1 * 1_000_000_000) // wait to myTrailsIsLoading be setted
            while(userData.myTrailsCountIsLoading){print("waiting myTrailsCountIsLoading")}
            
            while(userData.myTrailsCount != userData.mytrails.count){
                print(userData.myTrailsCount)
                print(userData.mytrails.count)
                // while(userData.myTrailsIsLoading){print("waiting myTrailsIsLoading")}
                userData.db_GetMyTrails()
                await Task.sleep(1 * 1_000_000_000) // wait to myTrailsIsLoading be setted
                while(userData.myTrailsIsLoading){print("waiting myTrailsIsLoading")}
            }
            
            appendLog("OK")
            
            if(userData.mytrails.count>0){
                addLog("Removing" + " " + String(userData.mytrails.count) + " trails : ")
                for i in 0...userData.mytrails.count - 1 {
                    dataStorage.removeTrailImages(trail: userData.mytrails[i])
                    userData.db_RemoveTrail(trailID: userData.mytrails[i].id)
                }
                appendLog("OK")
            }
            
                        
            addLog("Deleting Account Info" + " : ")
            if(userData.friendsList.list.count>0){
                for i in 0...userData.friendsList.list.count - 1 {
                    userData.db_deleteFriend(friend: userData.friendsList.list[i])
                }
            }
            userData.db_removeAccountInfo()
            appendLog("OK")
            
            addLog("Waiting for server response" + " : ")
            await userData.waitForFinish()
            appendLog("OK")
            
            addLog("Unregistering" + " : ")
            auth.unregister()
            appendLog("OK")
            
            userData.SignOut()
            
            addLog("Account successfully deleted!")
            
            
            deletingIsDone = true
        }
    }
    
}


#Preview {
    DeleteAccountView(deleteAccountView: .constant(true))
}
