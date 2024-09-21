import SwiftUI
import AVFoundation

enum KeyType {
    case regular, space, enter
}

class KeyPressHandler: ObservableObject {
    private var regularPlayers: [AVAudioPlayer] = []
    private var spacePlayers: [AVAudioPlayer] = []
    private var enterPlayers: [AVAudioPlayer] = []
    private var currentPlayerIndex = 0
    private let numberOfPlayers = 10
    
    init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        setupPlayers(for: &regularPlayers, soundName: "mechanical_key")
        setupPlayers(for: &spacePlayers, soundName: "mechanical_key_space")
        setupPlayers(for: &enterPlayers, soundName: "mechanical_key_enter")
    }
    
    private func setupPlayers(for players: inout [AVAudioPlayer], soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        for _ in 0..<numberOfPlayers {
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.prepareToPlay()
                players.append(player)
            } catch {
                print("Error setting up audio player: \(error.localizedDescription)")
            }
        }
    }
    
    func playSound(for keyType: KeyType) {
        let players: [AVAudioPlayer]
        switch keyType {
        case .regular:
            players = regularPlayers
        case .space:
            players = spacePlayers
        case .enter:
            players = enterPlayers
        }
        
        players[currentPlayerIndex].play()
        currentPlayerIndex = (currentPlayerIndex + 1) % numberOfPlayers
    }
}


struct ContentView: View {
    @State private var noteText = ""
    @State private var previousText = ""
    @StateObject private var keyPressHandler = KeyPressHandler()
    
    var body: some View {
        VStack {
            Text("Try it here")
                .font(.largeTitle)
                .padding()
            
            TextEditor(text: $noteText)
                .font(.system(size: 14))
                .padding(4)
                .border(Color.gray, width: 1)
                .onChange(of: noteText) { newValue in
                    handleTextChange(newValue)
                }
            
            HStack {
                Button("Clear") {
                    noteText = ""
                    previousText = ""
                }
                Spacer()
                Button("Save") {
                    // Here you would implement saving functionality
                    print("Note saved: \(noteText)")
                }
            }
            .padding()
        }
        .padding()
        .frame(minWidth: 300, minHeight: 400)
    }
    
    private func handleTextChange(_ newValue: String) {
        if newValue.count > previousText.count {
            let newCharacter = newValue.last!
            switch newCharacter {
            case " ":
                keyPressHandler.playSound(for: .space)
            case "\n":
                keyPressHandler.playSound(for: .enter)
            default:
                keyPressHandler.playSound(for: .regular)
            }
        }
        previousText = newValue
    }
}

#Preview {
    ContentView()
}
