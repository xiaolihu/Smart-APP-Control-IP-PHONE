//
//  VoiceRecognitionViewController.swift
//  Smart-APP-Control-IP-PHONE
//
//  Created by javchen on 1/3/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit

class VoiceRecognitionViewController: UIViewController, OEEventsObserverDelegate {
    
    var slt = Slt()
    var openEarsEventsObserver = OEEventsObserver()
    var fliteController = OEFliteController()
    
    var usingStartingLanguageModel = Bool()
    var startupFailedDueToLackOfPermissions = Bool()
    var restartAttemptsDueToPermissionRequests = Int()
    var pathToFirstDynamicallyGeneratedLanguageModel: String!
    var pathToFirstDynamicallyGeneratedDictionary: String!
    var pathToSecondDynamicallyGeneratedLanguageModel: String!
    var pathToSecondDynamicallyGeneratedDictionary: String!
    var timer: Timer!
    
    @IBOutlet var stopButton:UIButton!
    @IBOutlet var startButton:UIButton!
    @IBOutlet var suspendListeningButton:UIButton!
    @IBOutlet var resumeListeningButton:UIButton!
    @IBOutlet var statusTextView:UITextView!
    @IBOutlet var heardTextView:UITextView!
    @IBOutlet var pocketsphinxDbLabel:UILabel!
    @IBOutlet var fliteDbLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.openEarsEventsObserver.delegate = self
        self.restartAttemptsDueToPermissionRequests = 0
        self.startupFailedDueToLackOfPermissions = false
        
        let languageModelGenerator = OELanguageModelGenerator()
        
        let firstLanguageArray = ["backward",
                                  "change",
                                  "forward",
                                  "go",
                                  "left",
                                  "model",
                                  "right",
                                  "turn"]
        
        let firstVocabularyName = "FirstVocabulary"
        
        let firstLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: firstLanguageArray, withFilesNamed: firstVocabularyName, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if(firstLanguageModelGenerationError != nil) {
            print("Error while creating initial language model: \(firstLanguageModelGenerationError)")
        } else {
            self.pathToFirstDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: firstVocabularyName)
            self.pathToFirstDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: firstVocabularyName)
            self.usingStartingLanguageModel = true
            
            let secondVocabularyName = "SecondVocabulary"
            
            let secondLanguageArray = ["Sunday",
                                       "Monday",
                                       "Tuesday",
                                       "Wednesday",
                                       "Thursday",
                                       "Friday",
                                       "Saturday",
                                       "quidnunc",
                                       "change model"]
            
            let secondLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: secondLanguageArray, withFilesNamed: secondVocabularyName, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
            
            if(secondLanguageModelGenerationError != nil) {
                print("Error while creating second language model: \(secondLanguageModelGenerationError)")
            } else {
                self.pathToSecondDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: secondVocabularyName)
                self.pathToSecondDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: secondVocabularyName)
                
                do {
                    try OEPocketsphinxController.sharedInstance().setActive(true)
                }
                catch {
                    print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
                }
                
                if(!OEPocketsphinxController.sharedInstance().isListening) {
                    OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
                }
                startDisplayingLevels()
                
                self.startButton.isHidden = true
                self.stopButton.isHidden = true
                self.suspendListeningButton.isHidden = true
                self.resumeListeningButton.isHidden = true
            }
        }
    }
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
        if(hypothesis! == "change model") {
            
            if(self.usingStartingLanguageModel) {
                OEPocketsphinxController.sharedInstance().changeLanguageModel(toFile: self.pathToSecondDynamicallyGeneratedLanguageModel, withDictionary:self.pathToSecondDynamicallyGeneratedDictionary)
                self.usingStartingLanguageModel = false
                
            } else {
                OEPocketsphinxController.sharedInstance().changeLanguageModel(toFile: self.pathToFirstDynamicallyGeneratedLanguageModel, withDictionary:self.pathToFirstDynamicallyGeneratedDictionary)
                self.usingStartingLanguageModel = true
            }
        }
        
        self.heardTextView.text = "Heard: \"\(hypothesis!)\""
        
        self.fliteController.say(_:"You said \(hypothesis!)", with:self.slt)
    }
    
    func audioSessionInterruptionDidEnd() {
        print("Local callback:  AudioSession interruption ended.")
        self.statusTextView.text = "Status: AudioSession interruption ended."

        if(!OEPocketsphinxController.sharedInstance().isListening){
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }
    }
    
    func audioInputDidBecomeUnavailable() {
        print("Local callback:  The audio input has become unavailable")
        self.statusTextView.text = "Status: The audio input has become unavailable"
        
        if(OEPocketsphinxController.sharedInstance().isListening){
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in audioInputDidBecomeUnavailable: \(stopListeningError)")
            }
        }
        
        func audioInputDidBecomeAvailable() {
            print("Local callback: The audio input is available")
            self.statusTextView.text = "Status: The audio input is available"
            if(!OEPocketsphinxController.sharedInstance().isListening) {
                OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
            }
        }
        
        func audioRouteDidChange(toRoute newRoute: String!) {
            print("Local callback: Audio route change. The new audio route is \(newRoute)")
            self.statusTextView.text = "Status: Audio route change. The new audio route is \(newRoute)"
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in audioInputDidBecomeAvailable: \(stopListeningError)")
            }
        }
        
        if(!OEPocketsphinxController.sharedInstance().isListening) {
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }
    }
    
    func pocketsphinxRecognitionLoopDidStart() {
        
        print("Local callback: Pocketsphinx started.")
        self.statusTextView.text = "Status: Pocketsphinx started."
    }
    
    func pocketsphinxDidStartListening() {
        
        print("Local callback: Pocketsphinx is now listening.")
        self.statusTextView.text = "Status: Pocketsphinx is now listening."
        
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
        self.suspendListeningButton.isHidden = false
        self.resumeListeningButton.isHidden = true
    }
    
    func pocketsphinxDidDetectSpeech() {
        print("Local callback: Pocketsphinx has detected speech.")
        self.statusTextView.text = "Status: Pocketsphinx has detected speech."
    }
    
    
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Local callback: Pocketsphinx has detected a second of silence, concluding an utterance.")
        self.statusTextView.text = "Status: Pocketsphinx has detected finished speech."
    }
    
    func pocketsphinxDidStopListening() {
        print("Local callback: Pocketsphinx has stopped listening.")
        self.statusTextView.text = "Status: Pocketsphinx has stopped listening."
    }
    
    func pocketsphinxDidSuspendRecognition() {
        print("Local callback: Pocketsphinx has suspended recognition.")
        self.statusTextView.text = "Status: Pocketsphinx has suspended recognition."
    }
    
    func pocketsphinxDidResumeRecognition() {
        print("Local callback: Pocketsphinx has resumed recognition.")
        self.statusTextView.text = "Status: Pocketsphinx has resumed recognition."
    }
    
    func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        print("Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)")
    }
    
    func fliteDidStartSpeaking() {
        print("Local callback: Flite has started speaking")
        self.statusTextView.text = "Status: Flite has started speaking."
    }
    
    func fliteDidFinishSpeaking() {
        print("Local callback: Flite has finished speaking")
        self.statusTextView.text = "Status: Flite has finished speaking."
    }
    
    func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) {
        print("Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more.")
        self.statusTextView.text = "Status: Not possible to start recognition loop."
    }
    
    func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) {
        print("Local callback: Tearing down the continuous recognition loop has failed for the reason %, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure) // Log it.
        self.statusTextView.text = "Status: Not possible to cleanly end recognition loop."
    }
    
    func testRecognitionCompleted() {
        print("Local callback: A test file which was submitted for direct recognition via the audio driver is done.")
        if(OEPocketsphinxController.sharedInstance().isListening) {
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in testRecognitionCompleted: \(stopListeningError)")
            }
        }
    }
    
    func pocketsphinxFailedNoMicPermissions() {
        print("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
        self.startupFailedDueToLackOfPermissions = true
        if(OEPocketsphinxController.sharedInstance().isListening){
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in pocketsphinxFailedNoMicPermissions: \(stopListeningError). Will try again in 10 seconds.")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
            if(!OEPocketsphinxController.sharedInstance().isListening) {
                OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
            }
        })
    }
    
    func micPermissionCheckCompleted(withResult: Bool) {
        if(withResult) {
            self.restartAttemptsDueToPermissionRequests += 1
            if(self.restartAttemptsDueToPermissionRequests == 1 && self.startupFailedDueToLackOfPermissions) {
                
                if(!OEPocketsphinxController.sharedInstance().isListening) {
                    OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
                }
                
                self.startupFailedDueToLackOfPermissions = false
            }
        }
    }
    
    @IBAction func suspendListeningButtonAction() {
        OEPocketsphinxController.sharedInstance().suspendRecognition()
        
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
        self.suspendListeningButton.isHidden = true
        self.resumeListeningButton.isHidden = false
    }
    
    @IBAction func resumeListeningButtonAction() {
        OEPocketsphinxController.sharedInstance().resumeRecognition()
        
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
        self.suspendListeningButton.isHidden = false
        self.resumeListeningButton.isHidden = true
    }
    
    @IBAction func stopButtonAction() {
        if(OEPocketsphinxController.sharedInstance().isListening){
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in pocketsphinxFailedNoMicPermissions: \(stopListeningError)")
            }
        }
        self.startButton.isHidden = false
        self.stopButton.isHidden = true
        self.suspendListeningButton.isHidden = true
        self.resumeListeningButton.isHidden = true
    }
    
    @IBAction func startButtonAction() {
        if(!OEPocketsphinxController.sharedInstance().isListening) {
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
        self.suspendListeningButton.isHidden = false
        self.resumeListeningButton.isHidden = true
    }
    
    func startDisplayingLevels() {
        if(self.timer != nil) {
            self.timer.invalidate()
        }

        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateLevelsUI), userInfo: nil, repeats: true)
    }
    
    func updateLevelsUI() {
        
        self.pocketsphinxDbLabel.text = "Pocketsphinx Input level: \(OEPocketsphinxController.sharedInstance().pocketsphinxInputLevel)"
        
        if(self.fliteController.speechInProgress) {
            self.fliteDbLabel.text = "Flite Output level: \(self.fliteController.fliteOutputLevel)"
        }
    }
}
