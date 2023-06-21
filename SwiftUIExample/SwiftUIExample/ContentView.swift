//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by QuintGao on 2023/6/21.
//

import SwiftUI

struct PageView: UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UIView {
        GKPageView(frame: UIScreen.main.bounds)
    }
}

struct ContentView: View {
    var body: some View {
        PageView().ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
