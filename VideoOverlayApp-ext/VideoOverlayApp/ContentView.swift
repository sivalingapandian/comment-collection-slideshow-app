//
//  ContentView.swift
//  VideoOverlayApp
//
//  Created by Pandian on 8/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var videoPath: String = ""
    @State private var apiEndpoint: String = "https://xxxxxx.amazonaws.com/default/messageAPI"
    
    var body: some View {
        VideoOverlayView(videoPath: $videoPath, apiEndpoint: $apiEndpoint)
    }
}

#Preview {
    ContentView()
}
