//
//  BLEViewController.swift
//  BluetoothLE
//
//  Created by Yatendra Chaudhary on 12/12/16.
//  Copyright © 2016 Yatendra Chaudhary. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITextViewDelegate {

    private let UuidSerialService = "1BCF4032-19FE-451C-B74C-75FE2B2D82EE"
    private let UuidTx =            "FFE1"
    private let UuidRx =            "FFE1"
    

    
    @IBOutlet weak var lblBLEConnected: UILabel!
    
    @IBOutlet weak var writtenTextView: UITextView!
    
    @IBOutlet weak var readingTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblBLEConnected.text = ConnectedBluetooth
        print(_SelectedPeripheral.name ?? "No Any Value Got")
        self.writtenTextView.delegate = self
        self.readingTextView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    

    @IBAction func btnSend(_ sender: Any) {
        //let data = NSData(bytes: value, length: value.count)
        //serialPortPeripheral?.writeValue(data as Data, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        if let text = writtenTextView.text{
            print(text);
            writeValue(data: text)
            _SelectedPeripheral.readValue(for: txCharacteristic)
        }
    }
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Write function
    func writeValue(data: String){
        //let xmlStr:String = String(bytes: data, encoding: String.Encoding.utf8)!
        let writedata = data.data(using: String.Encoding.utf8)
        if let peripheralDevice = _SelectedPeripheral{
            if let deviceCharacteristics = txCharacteristic{
                peripheralDevice.writeValue(writedata!, for:
                    deviceCharacteristics, type: CBCharacteristicWriteType.withResponse)
                print(deviceCharacteristics.value ?? 0)
            }
        }
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state){
        case .poweredOn:
            Blue.scanForPeripherals(withServices: nil, options:nil)
            print("Bluetooth is powered ON")
        case .poweredOff:
            print("Bluetooth is powered OFF")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unknown:
            print("Bluetooth is unknown")
        case .unsupported:
            print("Bluetooth is not supported")
        }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic.uuid)
        if (characteristic.uuid == txCharacteristic.uuid){
            let writedata = writtenTextView.text.data(using: String.Encoding.utf8)
            
        }
            
    }
    

    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let characteristicValue = _SelectedCharacteristic.value{
                        let datastring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue)
                        if let datastring = datastring{
                           readingTextView.text  = datastring as String
                        }
                   }
    }
        
        //        
        
        
        
        //        let rxData = characteristic.value
//        print(characteristic.value ?? "Not Found Value")
//        if let rxData = rxData {
//            let numberOfBytes = rxData.count
//            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
//            (rxData as NSData).getBytes(&rxByteArray, length: numberOfBytes)
//            print(rxByteArray)
//            if let str = String(data: rxData, encoding: String.Encoding.utf8) {
//                print(str)
//                readingTextView.text = str
//            } else {
//                print("not a valid UTF-8 sequence")
//            }
//            
//        }

   

    

}
