//
//  ContentView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 26.09.2023.
//

import SwiftUI





struct StartView: View {
    
    @EnvironmentObject var  auth : SignInViewModel
      
    
    var body: some View {
        
        if(auth.isSignedIn){
            MainView()
        }else
        {
            SignInView()
        }
    }
    
   
}
 
#Preview {
    StartView().environmentObject(SignInViewModel()).environmentObject(UserModel())
    
}


