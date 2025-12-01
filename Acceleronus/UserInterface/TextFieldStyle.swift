//
//  TextFieldStyle.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 15.10.2023.
//

import Foundation
import SwiftUI



struct TextField_Default: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
           configuration
        //    .frame(width: UIScreen.main.bounds.width * 0.8)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .font(.footnote)
//            .onTapGesture {
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//               
//            }
    }
}



struct TextField_Small: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
           configuration
        //    .frame(width: UIScreen.main.bounds.width * 0.8)
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .font(.footnote)

    }
}



struct TextField_WithTextLabel: View {
    var title : LocalizedStringKey
    @Binding var inputText : String
    @FocusState private var fieldIsFocused: Bool  // new
    
    var body: some View {
        Text(title)//+":"
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.caption)
        
        TextField(title, text: $inputText) //, axis: .vertical
            .textFieldStyle(TextField_Small())
            .focused($fieldIsFocused)
            .onSubmit {
                fieldIsFocused = false
            }
            .submitLabel(.done)
            .onTapGesture { //hide keyboard on tap anywhere
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

            }
            
    }
    
}

struct TextFiled_Multiline: View {
    var title : LocalizedStringKey
    @Binding var inputText : String
    @FocusState private var fieldIsFocused: Bool
    var body: some View {
        
        Text(title)//+":"
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.caption)
        

        TextField(title, text: $inputText, axis: .vertical)
            .lineLimit(5, reservesSpace: true)
          //  .frame(width: UIScreen.main.bounds.width * 0.8)
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .focused($fieldIsFocused)
//            .onChange(of: inputText) { newValue in
//                guard let newValueLastChar = newValue.last else { return }
//                if newValueLastChar == "\n" {
//                    inputText.removeLast()
//                    fieldIsFocused = false
//                }
//            }
            
            .submitLabel(.done)
            .font(.footnote)
            .onTapGesture { //hide keyboard on tap anywhere
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

            }

        
    }
}





   
