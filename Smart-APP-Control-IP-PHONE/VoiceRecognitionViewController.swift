//
//  VoiceRecognitionViewController.swift
//  Smart-APP-Control-IP-PHONE
//
//  Created by javchen on 1/3/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit

class VoiceRecognitionViewController: UIViewController, OEEventsObserverDelegate {
    
    // TODO
    var selectedContantName = "";
    var selecteTelephonyNumber = ""
    func startCall() {
        print("Local callback: Selected to call name - \(selectedContantName).")
        print("Local callback: Selected to call # - \(selecteTelephonyNumber).")
    }
    
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
    @IBOutlet var heardTextView:UITextView!
    @IBOutlet var statusTextView:UITextView!
    @IBOutlet var pocketsphinxDbLabel:UILabel!
    @IBOutlet var fliteDbLabel:UILabel!
    @IBOutlet var ciscoLogo:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.openEarsEventsObserver.delegate = self
        self.restartAttemptsDueToPermissionRequests = 0
        self.startupFailedDueToLackOfPermissions = false
        
        let languageModelGenerator = OELanguageModelGenerator()
        
        let firstLanguageArray = ["Wang Chuck",
                                  "Huang Xiaolin",
                                  "Wang Zhaocai",
                                  "Chen Javen",
                                  "Xuebin Liang",
                                  "Gu Xingcai"]
        
        let ContactName = "ContactName"
        
        let firstLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: firstLanguageArray, withFilesNamed: ContactName, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if(firstLanguageModelGenerationError != nil) {
            print("Error while creating initial language model: \(firstLanguageModelGenerationError)")
        } else {
            self.pathToFirstDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: ContactName)
            self.pathToFirstDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: ContactName)
            self.usingStartingLanguageModel = true
            
            let Operation = "Operation"
            
            let secondLanguageArray = ["Search",
                                       "Dail",
                                       "Hangup",
                                       "change model"]
            
            let secondLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: secondLanguageArray, withFilesNamed: Operation, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
            
            if(secondLanguageModelGenerationError != nil) {
                print("Error while creating second language model: \(secondLanguageModelGenerationError)")
            } else {
                self.pathToSecondDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: Operation)
                self.pathToSecondDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: Operation)
                
                do {
                    try OEPocketsphinxController.sharedInstance().setActive(true)
                }
                catch {
                    print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
                }
                
                if(!OEPocketsphinxController.sharedInstance().isListening) {
                    OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
                }
                //startDisplayingLevels()
                
                if(OEPocketsphinxController.sharedInstance().isListening){
                    let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
                    if(stopListeningError != nil) {
                        print("Error while stopping listening in viewDidLoad: \(stopListeningError).")
                    }
                }
                
                self.startButton.isHidden = false
                self.stopButton.isHidden = true
                //self.suspendListeningButton.isHidden = true
                //self.resumeListeningButton.isHidden = true
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
        
        // to set contact name
        Shared.shared.contactName = hypothesis!
        
        // to get contact name from other view controller
        if let contactName = Shared.shared.contactName {
            print("Local callback: You said - \(contactName).")
        }
        
        self.heardTextView.text = "\"Call \(hypothesis!)\""
        
        self.fliteController.say(_:"You will call \(hypothesis!)", with:self.slt)
        
        // dail the contact name recognized
        self.startCall(contactName: hypothesis!)
        
        // add the contact name into call history list
        self.addRecentContact(contactName: hypothesis!)
    }
    
    func audioSessionInterruptionDidEnd() {
        print("Local callback:  AudioSession interruption ended.")
        //self.statusTextView.text = "Status: AudioSession interruption ended."

        if(!OEPocketsphinxController.sharedInstance().isListening){
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }
    }
    
    func audioInputDidBecomeUnavailable() {
        print("Local callback:  The audio input has become unavailable")
        //self.statusTextView.text = "Status: The audio input has become unavailable"
        
        if(OEPocketsphinxController.sharedInstance().isListening){
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in audioInputDidBecomeUnavailable: \(stopListeningError)")
            }
        }
        
        func audioInputDidBecomeAvailable() {
            print("Local callback: The audio input is available")
            //self.statusTextView.text = "Status: The audio input is available"
            if(!OEPocketsphinxController.sharedInstance().isListening) {
                OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
            }
        }
        
        func audioRouteDidChange(toRoute newRoute: String!) {
            print("Local callback: Audio route change. The new audio route is \(newRoute)")
            //self.statusTextView.text = "Status: Audio route change. The new audio route is \(newRoute)"
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
        //self.statusTextView.text = "Status: Pocketsphinx started."
    }
    
    func pocketsphinxDidStartListening() {
        
        print("Local callback: Pocketsphinx is now listening.")
        //self.statusTextView.text = "Status: Pocketsphinx is now listening."
        
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
        
        //self.suspendListeningButton.isHidden = true
        //self.resumeListeningButton.isHidden = true
    }
    
    func pocketsphinxDidDetectSpeech() {
        self.ciscoLogo.isHidden = true
        print("Local callback: Pocketsphinx has detected speech.")
        //self.statusTextView.text = "Status: Pocketsphinx has detected speech."
        // to display audio wave
    }
    
    
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Local callback: Pocketsphinx has detected a second of silence, concluding an utterance.")
        //self.statusTextView.text = "Status: Pocketsphinx has detected finished speech."
        // to disappear audio wave
    }
    
    func pocketsphinxDidStopListening() {
        print("Local callback: Pocketsphinx has stopped listening.")
        //self.statusTextView.text = "Status: Pocketsphinx has stopped listening."
        
        self.startButton.isHidden = false
        self.stopButton.isHidden = true
        self.ciscoLogo.isHidden = false
        //self.suspendListeningButton.isHidden = true
        //self.resumeListeningButton.isHidden = true
    }
    
    func pocketsphinxDidSuspendRecognition() {
        print("Local callback: Pocketsphinx has suspended recognition.")
        //self.statusTextView.text = "Status: Pocketsphinx has suspended recognition."
    }
    
    func pocketsphinxDidResumeRecognition() {
        print("Local callback: Pocketsphinx has resumed recognition.")
        //self.statusTextView.text = "Status: Pocketsphinx has resumed recognition."
    }
    
    func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        print("Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)")
    }
    
    func fliteDidStartSpeaking() {
        print("Local callback: Flite has started speaking")
        //self.statusTextView.text = "Status: Flite has started speaking."
    }
    
    func fliteDidFinishSpeaking() {
        print("Local callback: Flite has finished speaking")
        //self.statusTextView.text = "Status: Flite has finished speaking."
    }
    
    func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) {
        print("Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more.")
        //self.statusTextView.text = "Status: Not possible to start recognition loop."
    }
    
    func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) {
        print("Local callback: Tearing down the continuous recognition loop has failed for the reason %, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure) // Log it.
        //self.statusTextView.text = "Status: Not possible to cleanly end recognition loop."
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
        self.ciscoLogo.isHidden = true
        //self.suspendListeningButton.isHidden = true
        //self.resumeListeningButton.isHidden = false
    }
    
    @IBAction func resumeListeningButtonAction() {
        OEPocketsphinxController.sharedInstance().resumeRecognition()
        
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
        self.ciscoLogo.isHidden = true
        //self.suspendListeningButton.isHidden = false
        //self.resumeListeningButton.isHidden = true
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
        self.ciscoLogo.isHidden = false
        //self.suspendListeningButton.isHidden = true
        //self.resumeListeningButton.isHidden = true
    }
    
    @IBAction func startButtonAction() {
        if(!OEPocketsphinxController.sharedInstance().isListening) {
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
        self.ciscoLogo.isHidden = true
        //self.suspendListeningButton.isHidden = false
        //self.resumeListeningButton.isHidden = true
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
    
    func addRecentContact(contactName: String) {
        
        print("Local callback: Added \(contactName) into history list.")
        
        PersistentUtil.addCallHistory(callHistory: CallHistory(contactName: "\(contactName)", telephonyNumber: "123-456-7892", callTime: Date()))
    }
    
    // Call Contact w/ TCP client socket
    private func startCall(contactName: String) {
        // the following line is for debugging
        print("Local callback: Dialing \(contactName) ... ")
        
        /* uncomment the block to test w/ real world connecting
        var tcpServer: String!
        let port = 40000
        var tcpCli: TCPClient?
        
        tcpServer = "10.74.37.187"
        tcpCli = TCPClient(address: tcpServer, port: Int32(port))
        
        switch tcpCli!.connect(timeout: 10) {
        case .success:
            print("Connected to host \(tcpCli?.address)")
            if let response = sendRequest(string: "Dial \(contactName)", using: tcpCli!) {
                print("Local callback: Recieved \(response) from IP phone.")
            }
        case .failure( _):
            print("Local callback: Failed To Connect IP Phone.")
        }*/
    }
    
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        print("Local callback: Sending data ... ")
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure( _):
            print("Local callback: Failed to send data.")
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
}
