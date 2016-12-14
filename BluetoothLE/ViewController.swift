//
//  ViewController.swift
//  BluetoothLE
//
//  Created by Yatendra Chaudhary on 12/12/16.
//  Copyright © 2016 Yatendra Chaudhary. All rights reserved.
//

import UIKit
import CoreBluetooth
import DeviceKit


var ConnectedBluetooth = String()
var _SelectedCharacteristic : CBCharacteristic!
var deviceName: String!
var listValue = [String]()
var Blue: CBCentralManager!
var _SelectedPeripheral: CBPeripheral!
var txCharacteristic: CBCharacteristic!
var rxCharacteristic: CBCharacteristic!
var ReadValue = [String]()

class ViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    private let UuidSerialService = "1BCF4032-19FE-451C-B74C-75FE2B2D82EE"
    private let UuidTx =            "FFE1"
    private let UuidRx =            "FFE1"
    let device = Device()
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel * 100
    }
    var batteryState: Bool{
        if(UIDevice.current.batteryState == UIDeviceBatteryState.charging){
            return true
        }
        return false
    }
    var batteryCapacity : String{
        return UIDevice.current.batteryCapacity.components(separatedBy: " ").first!
    }
    var ModelName : String{
        return UIDevice.current.model
    }
    var Name : String{
        return UIDevice.current.name
    }
    var UUID : String{
        return (UIDevice.current.identifierForVendor?.description)!
    }
    var IphoneModel : String{
        return UIDevice.current.localizedModel
    }
    var IPhoneValue : String{
        return UIDevice.current.description
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceName = "APRICOT"
        Blue = CBCentralManager()
        Blue.delegate = self
        UIDevice.current.isBatteryMonitoringEnabled = true
        print("\(batteryLevel)% ")
        print("\(ModelName)\n \(Name) \n \(UUID) \n \(IphoneModel) \n \(IPhoneValue)")
        print(UIDevice.current.modelName)
        print(UIDevice.current.batteryCapacity)
        
        
        print("Battery Level = \(device.batteryLevel)")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager){
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name == deviceName){
            _SelectedPeripheral = peripheral
            _SelectedPeripheral.delegate = self
            Blue.stopScan()
            Blue.connect(_SelectedPeripheral, options: nil)
            ConnectedBluetooth = peripheral.name!
            //writeValue(data: "\(batteryLevel)")
            //self.performSegue(withIdentifier: "ConnectionSegue", sender: nil)
        }
        else{
            listValue.append(peripheral.name!)
//            listValue = [
//                (Name: peripheral.name!, RSS: RSSI.stringValue)
//            ]
            self.tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripheral = peripheral.services! as [CBService]!{
            for service in servicePeripheral{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
       // if let characterArray = service.characteristics! as [CBCharacteristic]!{
            
//            for cc in characterArray {
//                print("Hello Service Id = " + cc.uuid.uuidString)
//                if(cc.uuid.uuidString == "FFE1"){
//                    print("OKOK")
//                    peripheral.readValue(for: cc)
//                }
//            }
        //}
        var datalength: Int = 0
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // Tx:
                    print(characteristic.uuid)
                    if characteristic.uuid == CBUUID(string: UuidTx) {
                        print("Tx char found: \(characteristic.uuid)")
                        txCharacteristic = characteristic
                        _SelectedCharacteristic = characteristic
                        print("\(batteryLevel)% \(batteryState)")
                        writeValue(data: "Bat=\(device.batteryLevel)\nSt=\(batteryState)\nCap=\(batteryCapacity)")
                        var writterData = "\(batteryLevel)% \n \(batteryState) \n \(batteryCapacity) "
                        let array_UINT8 : [UInt8] = Array(writterData.utf8)
                        let data = NSData(bytes: array_UINT8, length: array_UINT8.count)
                        datalength = array_UINT8.count
                       // _SelectedPeripheral?.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)

                    }
                    
                    // Rx:
                    print(characteristic.uuid)
                    if characteristic.uuid == CBUUID(string: UuidRx) {
                        rxCharacteristic = characteristic
                        if let rxCharacteristic = rxCharacteristic {
                            print("Rx char found: \(characteristic.uuid)")
                            peripheral.setNotifyValue(true, for: rxCharacteristic)
                            
                            _SelectedPeripheral.readValue(for: characteristic)
                            
                            
                        }
                    }
                }
            }
        
    }
   
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        
        var data = characteristic.value
        var values = [UInt8](repeating:0, count:(data?.count)!)
        data?.copyBytes(to: &values, count:(data?.count)!)
        print(data ?? "Not Got A Value")
        if let characteristicValue = _SelectedCharacteristic.value{
            let datastring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue)
            if let datastring = datastring{
                print(datastring)
               ReadValue.append(datastring as String)
                print(ReadValue)
                let alert = UIAlertController(title: "Response Message", message: "\(ReadValue.joined())", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        print("Got Some Value")
        
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
    
    func platform() -> String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return NSString(bytes: &sysinfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)! as String
    }
    
    // table view controller delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)! as UITableViewCell
        deviceName = currentCell.textLabel?.text
        Blue = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listValue.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cella = self.tableView.dequeueReusableCell(withIdentifier: "Cella", for: indexPath)
        let Lista = listValue[indexPath.row]
        cella.textLabel?.text = Lista
        cella.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cella
    }
    

}
public extension UIDevice{
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    var batteryCapacity: String{
        
        switch modelName{
        case "iPod Touch 5":                             return "6470 mAh"
        case "iPod Touch 6":                             return "6470 mAh"
        case "iPhone 4":                                 return "1420 mAh"
        case "iPhone 4s":                                return "1432 mAh"
        case "iPhone 5":                                 return "1440 mAh"
        case "iPhone 5c":                                return "1507 mAh"
        case "iPhone 5s":                                return "1570 mAh"
        case "iPhone 6":                                 return "1810 mAh"
        case "iPhone 6 Plus":                            return "2915 mAh"
        case "iPhone 6s":                                return "1715 mAh"
        case "iPhone 6s Plus":                           return "2750 mAh"
        case "iPhone 7":                                 return "1960 mAh"
        case "iPhone 7 Plus":                            return "2900 mAh"
        case "iPhone SE":                                return "1624 mAh"
        case "iPad 2":                                   return "6930 mAh"
        case "iPad 3":                                  return "11560 mAh"
        case "iPad 4":                                  return "11560 mAh"
        case "iPad Air":                                return "8820 mAh"
        case "iPad Air 2":                              return "7340 mAh"
        case "iPad Mini":                               return "6470 mAh"
        case "iPad Mini 2":                             return "6470 mAh"
        case "iPad Mini 3":                             return "6470 mAh"
        case "iPad Mini 4":                             return "5124mAh"
        case "iPad Pro":                                return "10307 mAh"
        case "Apple TV":                                return "6470 mAh"
        default:                                        return modelName
        }
    }
}

