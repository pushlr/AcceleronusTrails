//
//  AnyLanguageBundle.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 24.11.2025.
//

import Foundation


private var bundleKey: UInt8 = 0


enum AppLanguage: String, CaseIterable {
    case en = "en"
    case fr = "fr"
    case de = "de"
    case ro = "ro"
    case ru = "ru"
    case uk = "uk"
    case it = "it"
    case zk = "zk-HK"
    // add more codes...

    var displayName: String {
        switch self {
        case .en: return "English"
        case .fr: return "Français"
        case .de: return "Deutsch"
        case .ro: return "Română"
        case .ru: return "Русский"
        case .uk: return "Українська"
        case .it: return "Italian"
        case .zk: return "中文"
        }
    }
}


class AnyLanguageBundle: Bundle {
  override func localizedString(forKey key: String,
                                value: String?,
                                table tableName: String?) -> String {
    if let path = objc_getAssociatedObject(self, &bundleKey) as? String,
       let bundle = Bundle(path: path) {
      return bundle.localizedString(forKey: key, value: value, table: tableName)
    } else {
      return super.localizedString(forKey: key, value: value, table: tableName)
    }
  }
}

extension Bundle {
  class func setLanguage(_ language: String) {
    // set the class to your custom bundle
    object_setClass(Bundle.main, AnyLanguageBundle.self)
    // store the path for this language
    let path = Bundle.main.path(forResource: language, ofType: "lproj")
    objc_setAssociatedObject(Bundle.main, &bundleKey, path,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
}
