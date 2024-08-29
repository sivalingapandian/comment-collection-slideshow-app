import SwiftUI
import AVKit
import Combine
import UniformTypeIdentifiers

// Define the structure for the JSON response
struct MessageResponse: Decodable {
    let messages: [Message]
    let nextIndex: Int
}

struct Message: Decodable {
    let id: String
    let name: String
    let text: String
}

class VideoPlayerViewModel: ObservableObject {
    let player: AVPlayer
    @Published var overlayTexts: [String] = [
        "Loading...", "Please wait...", "Fetching data..."
    ]
    
    private var cancellable: AnyCancellable?
    private var nextIndex: Int = 0 // Store the nextIndex from the API response
    private var apiEndpoint: String // API Endpoint

    init(videoURL: URL, apiEndpoint: String) {
        self.player = AVPlayer(url: videoURL)
        self.apiEndpoint = apiEndpoint
        addLoopingObserver()
        fetchOverlayTexts() // Initial call to start fetching
    }
    
    private func addLoopingObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
    }

    // Fetch the overlay texts from the API every 20 seconds
    func fetchOverlayTexts() {
        // Build the URL with the current nextIndex
        var urlComponents = URLComponents(string: apiEndpoint)!
        urlComponents.queryItems = [URLQueryItem(name: "index", value: "\(nextIndex)")]
        
        let url = urlComponents.url!

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> [String] in
                let httpResponse = response as! HTTPURLResponse
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                // Decode the data to a MessageResponse object
                let messageResponse = try JSONDecoder().decode(MessageResponse.self, from: data)
                // Update nextIndex for the next call
                self.nextIndex = messageResponse.nextIndex
                // Combine name and text with ": " in between
                return messageResponse.messages.map { "\($0.name): \($0.text)" }
            }
            .replaceError(with: ["Error fetching data"])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTexts in
                self?.overlayTexts = newTexts
                // Fetch new data every 20 seconds
                self?.startFetchTimer()
            }
    }

    // Start a timer to call fetchOverlayTexts every 20 seconds
    private func startFetchTimer() {
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { [weak self] _ in
            self?.fetchOverlayTexts()
        }
    }
}

struct VideoOverlayView: View {
    @Binding var videoPath: String
    @Binding var apiEndpoint: String
    
    @State private var currentIndex = 0
    @State private var isFullscreen = false
    
    // Use @State to initialize and reinitialize the view model
    @State private var viewModel: VideoPlayerViewModel
    
    init(videoPath: Binding<String>, apiEndpoint: Binding<String>) {
        _videoPath = videoPath
        _apiEndpoint = apiEndpoint
        _viewModel = State(initialValue: VideoPlayerViewModel(videoURL: URL(fileURLWithPath: videoPath.wrappedValue), apiEndpoint: apiEndpoint.wrappedValue))
    }
    
    var body: some View {
        ZStack {
            VideoPlayer(player: viewModel.player)
                .onAppear {
                    viewModel.player.play()
                    startTimer()
                }
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    toggleFullscreen()
                }
            
            if !isFullscreen {
                VStack {
                    HStack {
                        FilePicker(videoPath: $videoPath, isFullscreen: $isFullscreen)
                            .padding(.leading, 20) // Padding to move button to the left
                        
                        Spacer()
                        
                        VStack {
                            TextField("API Endpoint", text: $apiEndpoint)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            Button("Refresh") {
                                viewModel = VideoPlayerViewModel(videoURL: URL(fileURLWithPath: videoPath), apiEndpoint: apiEndpoint)
                            }
                            .padding()
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 20) // Adjust top padding as needed
                }
            }
            
            // Overlay text with scrolling animation, moved to the top of the screen
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { i in
                        Text(viewModel.overlayTexts[(currentIndex + i) % viewModel.overlayTexts.count])
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .padding(.top, 50) // Adjust padding to move text out of the way
            .background(Color.black.opacity(0.1)) // Optional: Add a subtle background to improve readability
        }
        .onChange(of: videoPath) { newPath in
            viewModel = VideoPlayerViewModel(videoURL: URL(fileURLWithPath: newPath), apiEndpoint: apiEndpoint)
        }
    }
    
    // Timer function to update the current index every 5 seconds
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            currentIndex = (currentIndex + 1) % viewModel.overlayTexts.count
        }
    }
    
    // Toggle fullscreen mode
    private func toggleFullscreen() {
        if let window = NSApplication.shared.windows.first {
            window.toggleFullScreen(nil)
            isFullscreen.toggle()
        }
    }
}

struct FilePicker: View {
    @Binding var videoPath: String
    @Binding var isFullscreen: Bool
    
    var body: some View {
        Button("Select Video File") {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [UTType.movie] // Use UTType.movie for video files
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            
            if panel.runModal() == .OK {
                videoPath = panel.url?.path ?? ""
                isFullscreen = true // Set fullscreen mode after file selection
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Align button to the left
    }
}


@main
struct VideoOverlayAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
