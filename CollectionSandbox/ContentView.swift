//
//  ContentView.swift
//  CollectionSandbox
//
//  Created by Mateus Rodrigues on 30/04/22.
//

import SwiftUI

struct ContentView: View {
    
    let number: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.blue)
            .padding(2)
            .overlay {
                Text("\(number)")
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(number: 0)
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
