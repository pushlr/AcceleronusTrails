//
//  CustomTabBar.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 15.12.2023.
//

import SwiftUI

import SwiftUI



enum Tab: String, CaseIterable {
    case navigator
  //  case house
 //   case message
    case person
  //  case leaf
  //  case gearshape
}


struct CustomTabBar: View {
    @Binding var selectedTab: Tab
   

    private var tabColor: Color {
        switch selectedTab {
        case .navigator:
            return .green
      ///  case .house:
      //      return .blue
      //  case .message:
     //       return .indigo
        case .person:
            return .pastelBlue
//        case .leaf:
//            return .green
//        case .gearshape:
//            return .orange
        }
    }
    

    
    var body: some View {
        VStack {
            HStack {
                // ForEach(Tab.allCases, id: \.rawValue) { tab in
                
                Spacer()
                VStack{
                    Image(systemName: selectedTab == .navigator ? "globe.europe.africa.fill" : "globe.europe.africa") .scaleEffect(.navigator == selectedTab ? 1.25 : 1.0).font(.system(size: 20))
                    Text("Navigator").font(.system(size: 10))
                }
                       
                        .foregroundColor(.navigator == selectedTab ? tabColor : .gray)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                selectedTab = .navigator
                            }
                        }
                    Spacer()
               
                VStack{
                    Image(systemName: selectedTab == .person ? "person.fill" : "person").scaleEffect(.person == selectedTab ? 1.25 : 1.0).font(.system(size: 20))
                    Text("Account").font(.system(size: 10))
                }
                    
                    .foregroundColor(.person == selectedTab ? tabColor : .gray)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = .person
                        }
                    }
                    
                    Spacer()
                
               // }
            }
            .frame(width: UIScreen.main.bounds.width - 10  , height: 60)
            .background(.thinMaterial)
            .cornerRadius(20)            
            .padding([.leading,.trailing],10)
            .padding(.bottom,20)
        }
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    
    static var previews: some View {
        @State var curr = Tab.navigator
        CustomTabBar(selectedTab: $curr)
    }
}
