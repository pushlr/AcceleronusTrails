//
//  LabelTemplates.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 29.11.2023.
//

import Foundation
import SwiftUI


struct EditableLabel: View{
    enum FocusField: Hashable {
       case field
     }
    
    @Binding var text: String
    @Binding private var editing : Bool 
    
    @State private var value : String
    @FocusState private var focusedField: FocusField?

    init(text: Binding<String>,editing: Binding<Bool>) {
        self._text = text
        self._editing = editing 
        self.value = (text.wrappedValue.isEmpty ? "enter text here" : text.wrappedValue)
        
        
    }
   

    var body: some View{

        if editing == true{
            HStack{
                TextField("", text: $value, onCommit: {
                    //Catches escape
                    print("onCommit")
                    text = value
                    editing = false
                })
                .textFieldStyle(.roundedBorder)
                .font(.avenirNext(size: 17))
                .focused($focusedField,equals: .field)
                .onAppear {
                    focusedField = .field
                }
                
                Button{ text = value; editing = false;}
                label:{ Image(systemName: "checkmark")}
                    .padding(.trailing,15)
                
                Button{editing = false; value = text}
                label:{ Image(systemName: "xmark")}
            }
        }else{
            
                Text(value).font(.avenirNext(size: 17))
                .onTapGesture(count: 2, perform: { editing = true } )
                
                
          
            


        }

    }

}

