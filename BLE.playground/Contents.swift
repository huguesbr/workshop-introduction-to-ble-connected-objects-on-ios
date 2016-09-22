import Foundation
import CoreBluetooth
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// http://osxdaily.com/2015/12/15/reset-bluetooth-hardware-module-mac-osx/
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.battery_service.xml

class BLEScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    enum UUID: String {
        case service = "3749FA00-4CED-524B-33D5-F00FD858C4F2"
        case characteristic = "3749FA01-4CED-524B-33D5-F00FD858C4F2"
        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }
    }
    
    override init() {
        super.init() // require to super init before self available
        // create central
    }
    
    // MARK: CentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // scan for peripherals depending of state
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // stop scan
        // connect
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // set as delegate
        // discover services
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // re-scan
    }
    
    // MARK: PeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // discover characteristics
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // set notify
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // interpret data
    }
}

let scanner = BLEScanner()
