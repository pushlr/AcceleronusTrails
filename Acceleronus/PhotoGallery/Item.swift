/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import FirebaseStorage

struct PhotoItem: Identifiable {
    let id = UUID()
    var downloaded = false
    var downloadError = false
    var name: String
    var url: URL?

}

extension PhotoItem: Equatable {
    static func ==(lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}

