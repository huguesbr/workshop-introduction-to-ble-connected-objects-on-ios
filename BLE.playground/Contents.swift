import Foundation
import CoreBluetooth
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

// http://osxdaily.com/2015/12/15/reset-bluetooth-hardware-module-mac-osx/
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.battery_service.xml


class BLEScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    enum UUID: String {
        case Service = "AAAA"
        case Characteristic = "XXXX"
        
        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }
    }
    
    override init() {
        super.init()
        // create central
    }
    
    // MARK: CentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        // start scanning depending of state
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        // connect to device
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        // discover services
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // failed
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // disconnected
    }
    
    // MARK: PeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        // discover characteristics
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        // read value
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // interpret data
    }
}

let scanner = BLEScanner()
