//
//  EditTrailView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 02.12.2023.
//

import SwiftUI

struct EditTrailView: View {
    @State var trail : Trail
    var body: some View {
        Text("Editing trail \(trail.TrailName)")
    }
}

#Preview {
    EditTrailView(trail: Trail())
}
