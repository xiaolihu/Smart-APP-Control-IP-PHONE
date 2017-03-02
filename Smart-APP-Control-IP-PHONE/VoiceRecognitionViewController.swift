//
//  VoiceRecognitionViewController.swift
//  Smart-APP-Control-IP-PHONE
//
//  Created by javchen on 1/3/2017.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit

class VoiceRecognitionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VoiceRecognitionViewController loaded its view.")
        
        let lmGenerator = OELanguageModelGenerator()
        let words = ["Hello", "World"]
        let name = "MyLanguageModelFiles"
        let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if (err != nil) {
            print("Error while creating initial language model: \(err)")
        } else {
            let lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name)
            let dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name)
            
            OELogging.startOpenEarsLogging()
            
            do {
                try OEPocketsphinxController.sharedInstance().setActive(true)
            } catch  {
                print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
            }
            
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }
    }
}
