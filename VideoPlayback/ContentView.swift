//
//  ContentView.swift
//  VideoPlayback
//
//  Created by Sergii Dankevych on 11/19/23.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation
import WorldAssets

struct Video: Identifiable {
    var id: Int

    let name: String
}

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    @State private var playVideo = false
    private let videos = [Video(id: 1, name: "1"), Video(id: 2, name: "2")]
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    public func makeVideoEntity() -> Entity {
        let entity = Entity()

        let asset = AVURLAsset(url: Bundle.main.url(forResource: "1",
                                                    withExtension: "mp4")!)
        let playerItem = AVPlayerItem(asset: asset)

        let player = AVPlayer()
        entity.components[VideoPlayerComponent.self] = .init(avPlayer: player)

        entity.scale *= 0.4

        player.replaceCurrentItem(with: playerItem)
        player.play()

        return entity
    }

    var body: some View {
        if playVideo {
            RealityView { content in
                let videoEntity = makeVideoEntity()
                content.add(videoEntity)
                if let earth = await WorldAssets.entity(named: "Earth") {
                    content.add(earth)
                    earth.scale = SIMD3(repeating: 0.4)
                    earth.move(to: Transform(AffineTransform3D(translation: Vector3D(x: 0, y: 0, z: -0.5))), relativeTo: videoEntity)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                        earth.move(to: Transform(AffineTransform3D(translation: Vector3D(x: 0, y: 0, z: -0.3))), relativeTo: videoEntity)
                        earth.move(to: Transform(AffineTransform3D(translation: Vector3D(x: 0, y: 0, z: 0.1))), relativeTo: videoEntity, duration: 5)
                    }
                }
            }
        }
        if !playVideo {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    ForEach(videos) { video in
                        Button {
                            showImmersiveSpace = true
                        } label: {
                            Text("Play \(video.name)")
                        }
                    }
                }
            }
            .padding()
            .onChange(of: showImmersiveSpace) { _, newValue in
                Task {
                    if newValue {
                        playVideo.toggle()
                        switch await openImmersiveSpace(id: "ImmersiveSpace") {
                        case .opened:
                            immersiveSpaceIsShown = true
                        case .error, .userCancelled:
                            fallthrough
                        @unknown default:
                            immersiveSpaceIsShown = false
                            showImmersiveSpace = false
                        }
                    } else if immersiveSpaceIsShown {
                        await dismissImmersiveSpace()
                        immersiveSpaceIsShown = false
                    }
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
