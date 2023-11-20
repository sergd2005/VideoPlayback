//
//  VideoPlaybackApp.swift
//  VideoPlayback
//
//  Created by Sergii Dankevych on 11/19/23.
//

import SwiftUI

@main
struct VideoPlaybackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
