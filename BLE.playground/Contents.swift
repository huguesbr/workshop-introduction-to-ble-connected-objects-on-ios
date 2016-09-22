import Foundation
import CoreBluetooth
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// http://osxdaily.com/2015/12/15/reset-bluetooth-hardware-module-mac-osx/
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.battery_service.xml

class BLEScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    enum UUID: String {
        case service = "1234"
        case characteristic = "5678"
        
        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }
    }
    
    var central: CBCentralManager!
    var currentPeripheral: CBPeripheral?
    
    override init() {
        super.init() // require to super init before self available
        // create central
    }
    
    // MARK: CentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // start scanning depending of state
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // connect to device
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // discover device services (battery only)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // re-start scanning
    }
    
    // MARK: PeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // discover service characteristics
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // read value
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // interpret data
    }
}

let scanner = BLEScanner()
