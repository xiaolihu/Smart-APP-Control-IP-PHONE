# Smart-APP-Control-IP-PHONE
Cisco TLI program

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
