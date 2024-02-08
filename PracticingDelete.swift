//
//  PracticingDelete.swift
//  Abel-Translator-App
//
//  Created by Efai De leon on 1/13/24.
//
// Just practicing
import SwiftUI

struct PracticingDelete: View {
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geometry in
                VStack {
                    Text("Testing some stuff")
                    Text("Testing some stuff")
                    Text("Testing some stuff")
                    Text("Testing some stuff")
                }
            }.background(Color.blue)
        }
    }
}

#Preview {
    PracticingDelete()
}
