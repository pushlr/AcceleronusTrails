//
//  Extensions.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 01.12.2023.
//

import Foundation



extension URL {
    /// Indicates whether the URL has a file extension corresponding to a common image format.
    var isImage: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic"]
        return imageExtensions.contains(self.pathExtension)
    }
}



extension String {
    func generateStringSequence() -> [String] {
        /// E.g) "Mark" yields "M", "Ma", "Mar", "Mark"
        if self.isEmpty {return []}
        
        var words: [String] = self.components(separatedBy: " ")
        var sequences: [String] = []
        for i in 0...words.count-1{
            if words[i].isEmpty {continue}
            for j in 1...words[i].count {
                sequences.append(String(words[i].prefix(j)).lowercased())
            }
        }
       
        return sequences
    }
}



extension String {

  var localized: String {
    return NSLocalizedString(self, comment: "\(self)_comment")
  }
  
  func localized(_ args: [CVarArg]) -> String {
    return localized(args)
  }
  
  func localized(_ args: CVarArg...) -> String {
    return String(format: localized, args)
  }
}
