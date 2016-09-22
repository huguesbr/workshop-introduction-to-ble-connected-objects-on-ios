import Foundation
import CoreBluetooth
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// http://osxdaily.com/2015/12/15/reset-bluetooth-hardware-module-mac-osx/
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.battery_service.xml

class BLEScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    enum UUID: String {
        case service = "0x180F"
        case characteristic = "0x2A19"
        
        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }
    }
    
    var central: CBCentralManager!
    var currentPeripheral: CBPeripheral?
    
    override init() {
        print("init")
        super.init() // require to super init before self available
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: CentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("state: on")
            central.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("state:", central.state.rawValue)
            break
        }
    }
    
    var discoveredPeripherals: [String] = []
    var connectedPeripheral: CBPeripheral?
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discovered:", peripheral)
        // , name.contains("iPhone") &&
        guard let name = peripheral.name, !discoveredPeripherals.contains(name) else {
            return
        }
        discoveredPeripherals.append(name)
        // If you don't somehow retain the peripheral object that is delivered to didDiscoverPeripheral then it is released once this delegate method exits and you won't get a connection.
        self.connectedPeripheral = peripheral
        print("discovered:", peripheral)
        print("connecting")
        central.stopScan()
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected:", peripheral)
        peripheral.delegate = self
        peripheral.discoverServices([UUID.service.uuid])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect:", peripheral, error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnect:", peripheral)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            central.scanForPeripherals(withServices: [], options: nil)
        }
    }
    
    // MARK: PeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("no services...")
            return
        }
        print("services:", services)
        if let battery = services.first {
            let uuid = UUID.characteristic.uuid
            peripheral.discoverCharacteristics([uuid], for: battery)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            print("no characteristics...")
            return
        }
        print("characteristics:", characteristics)
        if let battery = characteristics.first {
            print("battery: ", battery.uuid.uuidString)
            peripheral.readValue(for: battery)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            print("no data")
            central.cancelPeripheralConnection(peripheral)
            return
        }
        
        var buffer: [UInt8] = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count)
        let value = UnsafePointer(buffer).withMemoryRebound(to: UInt8.self, capacity: 1) {
            $0.pointee
        }
        print(peripheral.name ?? "Unnamed", "battery:", "\(Double(value))%")
        central.cancelPeripheralConnection(peripheral)
    }
}

let scanner = BLEScanner()
