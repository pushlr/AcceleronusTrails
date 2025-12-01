//
//  ActivitySelectorView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 30.10.2023.
//

import SwiftUI

struct ActivitySelectorView: View {
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: 3)
    @Binding var selectedActivity : ActivityType
    @Binding var isPresented : Bool 
    @State var selectedFlavor : AcitivityCategory = .Drive
   // var lastCategory : AcitivityCategory = .Walk
    
    var body: some View {
       
        ScrollView {
            
            Picker("Flavor", selection: $selectedFlavor) {
                ForEach(AcitivityCategory.allCases,id: \.self) { flavor in
                    Text(flavor.rawValue)
                  }
            }.pickerStyle(.segmented)
            
           
            LazyVGrid(columns: gridColumns) {
                ForEach(ActivityType.allCases,id: \.self) {item in
                    let activity = GetActivity(item)
                
                    if((activity.category == selectedFlavor) && (item != .UNKNOWN) ){
                        Button{
                            selectedActivity = item
                            isPresented = false
                            UserDefaults.standard.set(item.rawValue, forKey: "currentActivity")
                        }
                        label: {
                        VStack(spacing: 0){
                            Image(activity.image)
                                .resizable()
                                .frame(width: 50, height: 50)
                               
                                    .foregroundColor(.white)
                            Text(activity.name)
                                .foregroundStyle(Color.secondary)
                        }
                        }}
                }
            }
            .padding(.top,20)
            
            
        }
        .padding(5)
        .padding(.top,25)
        
       
    }
    
}

#Preview {
    ActivitySelectorView(
        selectedActivity: .constant(.ATV),
        isPresented: .constant(true)
    )
}
