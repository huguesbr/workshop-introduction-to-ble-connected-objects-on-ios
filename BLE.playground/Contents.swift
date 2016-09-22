import Foundation
import CoreBluetooth
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

// http://osxdaily.com/2015/12/15/reset-bluetooth-hardware-module-mac-osx/
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.battery_service.xml


class BLEScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    enum UUID: String {
        case Service = "0x180F"
        case Characteristic = "0x2A19"
        
        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }
    }
    
    var central: CBCentralManager!
    var currentPeripheral: CBPeripheral?
    
    override init() {
        print("init")
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: CentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            print("state: on")
            central.scanForPeripheralsWithServices(nil, options: nil)
        default:
            print("state:", central.state.rawValue)
            break
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("discovered:", peripheral)
        print("connecting to device")
        currentPeripheral = peripheral
        central.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("connected:", peripheral)
        print("discovering device services")
        let uuid = UUID.Service.uuid
        peripheral.delegate = self
        peripheral.discoverServices([uuid])
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("failed to connect:", peripheral, error)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("disconnect:", peripheral)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            central.scanForPeripheralsWithServices(nil, options: nil)
        })
    }
    
    // MARK: PeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        guard let services = peripheral.services else {
            print("no services...")
            return
        }
        print("services:", services)
        if let service = services.first {
            let uuid = UUID.Characteristic.uuid
            peripheral.discoverCharacteristics([uuid], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        guard let characteristics = service.characteristics else {
            print("no characteristics...")
            return
        }
        print("characteristics:", characteristics)
        if let characteristic = characteristics.first {
            peripheral.readValueForCharacteristic(characteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard let data = characteristic.value else {
            print("no data")
            central.cancelPeripheralConnection(peripheral)
            return
        }
        var value: UInt8 = 0
        data.getBytes(&value, length: sizeof(UInt8))
        print(peripheral.name ?? "Unnamed", "battery:", "\(value)%")
        central.cancelPeripheralConnection(peripheral)
    }
}

let scanner = BLEScanner()
