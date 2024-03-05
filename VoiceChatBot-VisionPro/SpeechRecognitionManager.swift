//
//  SpeechRecognitionManager.swift
//  VoiceChatBot-VisionPro
//
//  Created by Siddanth Raja on 2/28/24.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognitionManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var recognizedText = ""

    func startRecording() throws {
        // Check if recognitionTask is running, if so, stop it
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Setup audio session for recording
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Initialize the recognitionRequest
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode // Corrected this line

        // Check if the recognitionRequest object is instantiated and is not nil
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            
            var isFinal = false
            
            if let result = result {
                // Update the recognizedText variable with the latest results
                self.recognizedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            // If error occurred or the result is final, stop the audioEngine (microphone) and recognition task
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.isRecording = false
            }
        }
        
        // Configure the microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        // Prepare and start the audioEngine (microphone)
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking
        recognizedText = "(Go ahead, I'm listening)"
        isRecording = true
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle the authorization status
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    break // Good to go, you can start recording
                case .denied:
                    // User denied access. Explain that you need audio access for the feature.
                    break
                case .restricted:
                    // Speech recognition restricted on this device
                    break
                case .notDetermined:
                    // Speech recognition not yet authorized
                    break
                @unknown default:
                    break // Handle future enum cases
                }
            }
        }
    }
}
