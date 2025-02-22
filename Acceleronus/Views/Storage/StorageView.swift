//
//  StorageView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 01.12.2023.
//

import SwiftUI

struct StorageView: View {
    @EnvironmentObject var userData : UserData
    @State var cacheSize : UInt64 = 0
    @State var isShowingConfirmationDialog = false
    
    var body: some View {
        VStack(){
            Text("Memory Usage").font(.title).frame(alignment: .top).padding(.bottom,10)
            
            Divider()
            HStack{
                Image(systemName: "photo").foregroundStyle(.gray)
                Text("Images Cache")
                Text(formatBytesSize(cacheSize))
                    .onAppear{
                        do { cacheSize = try FileManager.default.allocatedSizeOfDirectory(at: FileManager.default.documentDirectory)
                        }catch{}
                    }
                    .frame(maxWidth:.infinity, alignment: .trailing)
                
            }.frame(maxWidth:.infinity, alignment: .leading)
            Divider()
            
//            Text("* Clearing cash during Trail Recording cause lost all Waypoints photos!").font(.footnote)
//            .frame(maxWidth: .infinity,alignment: .leading)
//            .foregroundStyle(.red)
//            .padding(.bottom,10)
            
            Button{isShowingConfirmationDialog=true}
            label: {Label("Clear cache", systemImage: "paintbrush") }  .padding(.top,10)
                .buttonStyle(ButtonDefault(ButtonColor: .green,width: (UIScreen .main.bounds.width / 3) * 2.0))
            .confirmationDialog("Are you sure?",
                                isPresented: $isShowingConfirmationDialog,
                                titleVisibility: .visible) {
                Button("Clear cache", role: .destructive) {
                    userData.clearTempFolder();
                    cacheSize = 0
                }
                Button("Cancel", role: .cancel) {}
            }
            
            
            Spacer()
        }
        .padding()
        .navigationTitle("Storage")
        
    }
}

#Preview {
    StorageView()
}
