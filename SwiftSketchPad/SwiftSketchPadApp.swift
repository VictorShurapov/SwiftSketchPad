//
//  SwiftSketchPadApp.swift
//  SwiftSketchPad
//
//  Created by Yaro4ka on 08.04.2025.
//

import SwiftUI

@main
struct SwiftSketchPadApp: App {
    // To share or access the state across application:
    // Initialize CanvasViewModel in app's entry point and inject it as an environment object.
    @State private var viewModel = CanvasViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
