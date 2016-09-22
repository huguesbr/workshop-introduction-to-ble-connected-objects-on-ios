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
    
    var central: CBCentralManager!
    var discoveredPeripherals: [String] = []
    var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init() // require to super init before self available
        // create central
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: CentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("state: on")
            central.scanForPeripherals(withServices: nil, options: nil) // can specify service to limit scope
        default:
            print("state:", central.state.rawValue)
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discovered:", peripheral)
        guard let name = peripheral.name, discoveredPeripherals.contains(name) == false else {
            return
        }
        discoveredPeripherals.append(name)
        // !!!: if you don't somehow retain the peripheral object that is delivered to didDiscoverPeripheral then it is released once this delegate method exits and you won't get a connection.
        self.connectedPeripheral = peripheral
        print("connecting")
        central.stopScan()
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected:", peripheral)
        peripheral.delegate = self
        print("discovering services")
        peripheral.discoverServices([UUID.service.uuid])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect:", peripheral, error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnect:", peripheral)
        central.scanForPeripherals(withServices: [], options: nil)
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
            print("discovering characteristics")
            peripheral.discoverCharacteristics([uuid], for: battery)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            print("no characteristics...")
            return
        }
        print("characteristics:", characteristics)
        if let characteristic = characteristics.first {
            print("characteristic: ", characteristic.uuid.uuidString)
            peripheral.setNotifyValue(true, for: characteristic)
            //            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationState:", characteristic.uuid, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            print("no data")
            return
        }
        print("data:", data)
        do {
            let time = try CurrentTime(data: data)
            print("date:", time.date)
            print("epoch:", time.date?.timeIntervalSince1970)
        } catch {
            print("Invalid data")
        }
    }
}

struct CurrentTime {
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.current_time.xml
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.date_time.xml
    
    let year: UInt16
    let month: UInt8
    let day: UInt8
    let hours: UInt8
    let minutes: UInt8
    let seconds: UInt8
    let dayOfWeek: UInt8
    let fraction: UInt8
    let reason: UInt8
    
    var date: Date? {
        let components = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, era: nil, year: Int(year), month: Int(month), day: Int(day), hour: Int(hours), minute: Int(minutes), second: Int(seconds), nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        return Calendar.current.date(from: components)
    }
    
    init(data: Data) throws {
        var parser = try DataParser(data: data)
        year = try parser.extractUInt16()
        month = try parser.extractUInt8()
        day = try parser.extractUInt8()
        hours = try parser.extractUInt8()
        minutes = try parser.extractUInt8()
        seconds = try parser.extractUInt8()
        dayOfWeek = try parser.extractUInt8()
        fraction = try parser.extractUInt8()
        reason = try parser.extractUInt8()
    }
}

struct DataParser {
    let data: Data
    var bytes: UnsafePointer<UInt8>?
    
    struct InvalidData: Error {}
    
    init(data: Data) throws {
        self.data = data
        data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
            print("raw:", bytes)
            self.bytes = bytes
        }
    }
    
    mutating func extractUInt16() throws -> UInt16 {
        guard let bytes = bytes else { throw InvalidData() }
        let value: UInt16 = bytes.withMemoryRebound(to: UInt16.self, capacity: 1) { (bytes: UnsafeMutablePointer<UInt16>) -> UInt16 in
            return bytes.pointee
        }
        self.bytes = bytes.advanced(by: 2)
        return value
    }
    
    mutating func extractUInt8() throws -> UInt8 {
        guard let bytes = bytes else { throw InvalidData() }
        let value = bytes.pointee
        self.bytes = bytes.advanced(by: 1)
        return value
    }
}

let scanner = BLEScanner()
