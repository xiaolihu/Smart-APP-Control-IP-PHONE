//
//  ViewController.swift
//  ControlIPPhoneViaBLE
//
//  Created by Xiaolin Huang on 2/27/17.
//  Copyright © 2017 Xiaolin Huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // This project will use IOS CoreBluetooth framework to communicate with Cisco IP PHONE.
    // In detail, we are utilizing GATT client-server architecture as our communication model.
    
    //   _________________________                     _________________________
    //   |  CISCO IP PHONE LINUX |       BLE/GATT      | APPLE iPhone IOS 10.x |
    //   |        server         |     <----------->   |       client          |
    
    
    // create IOS media/audio instance to capture voice signals from microphone
    
    // inject captured inputs to Speech Recognition(ASR) module, which will convert speech to text.
    
    // Then BTService moule will change GATT chanractics value with the 'text' and pass it to IP PHONE.
    
    // IP PHONE will parse the 'text' as a command to execute it and automatically do correponding operaions,
    
    // like dial a number out for making a call.
    
    
    // **************************** BLE/GATT ***********************************
    // create an instance of BTDiscovery to begin searching for BLE devices (Cisco IP PHONE)
    // in range with a specific Sevice UUID.
    
    // BTDiscovery manages the discovery of and connections to Bluetooth devices. It also notifies the APP when a
    // Bluetooth device connects or disconnects.
    
    // BTService handles the communication via BLE/GATT between IP PHONE and iPhone.
    
    // BTAdvertise will make iPhone perform common peripheral role and start advertise its service.
    
    
    @IBOutlet weak var serverIPAddr: UITextField!

    @IBAction func DismissKeyboard(_ sender: AnyObject) {
        serverIPAddr.resignFirstResponder()
    }
    @IBOutlet private weak var connectStatus: UILabel!
    
    //var btAdvertiseInstance : BTAdvertise!// perform common peripheral role
    
    //var btDiscoveryInstance : BTDiscovery!// perform common central role
    
    var tcpServer = "10.74.37.187"
    let port = 40000
    var tcpCli: TCPClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //btDiscoveryInstance = BTDiscovery()
        //btAdvertiseInstance = BTAdvertise()
        connectStatus.text = "Diconnected"

    }
    
    @IBAction private func turnOnSwitch(_ sender: UISwitch) {
        // start to discover service with UUID
        
        
        if (sender.isOn){
            print( "Connecting to server" )
            
            tcpServer = serverIPAddr.text!
            tcpCli = TCPClient(address: tcpServer, port: Int32(port))
            
            switch tcpCli!.connect(timeout: 10) {
            case .success:
                print("Connected to host \(tcpCli?.address)")
                connectStatus.text = "Connected"
                if let response = sendRequest(string: "Dial 4242", using: tcpCli!) {
                    print("Response: \(response)")
                }
            case .failure( _):
                connectStatus.text = "Failed To Connect"
            }
        
            
            //sender.isOn = true
        } else {
            print( "Close connection !" )
            tcpCli?.close()
            serverIPAddr.text = nil
            connectStatus.text = "Disconnected"
        }
    }

    private func sendRequest(string: String, using client: TCPClient) -> String? {
        print("Sending data ... ")
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure( _):
            print("Failed to send data...")
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }

}

