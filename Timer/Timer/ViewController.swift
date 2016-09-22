//
//  ViewController.swift
//  Timer
//
//  Created by Hugues Bernet-Rollande on 22/9/16.
//  Copyright © 2016 Hugues Bernet-Rollande. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    @IBOutlet var lblTime: UILabel?
    
    var timer: Timer?
    var peripheral: TimerPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheral = TimerPeripheral()
    }
    
    @IBAction func updateTime(_ sender: UIButton) {
        if timer != nil {
            stopTimer()
            sender.setTitle("Start", for: .normal)
        } else {
            startTimer()
            sender.setTitle("Stop", for: .normal)
        }
        sender.sizeToFit()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (_) in
            guard let strongSelf = self else { return }
            let date = Date()
            strongSelf.peripheral?.date = date
            strongSelf.lblTime?.text = "\(date)"
            strongSelf.lblTime?.sizeToFit()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
}

// http://osxdaily.com/2015/12/15/reset-bluetooth-hardware-module-mac-osx/
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.battery_service.xml

class TimerPeripheral: NSObject, CBPeripheralManagerDelegate {
    enum UUID: String {
        case service = "3749FA00-4CED-524B-33D5-F00FD858C4F2"
        case characteristic = "3749FA01-4CED-524B-33D5-F00FD858C4F2"
        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }
    }
    
    var date: Date? {
        didSet {
            guard let date = date, let peripheral = peripheral, let charateristic = charateristic else { return }
            let time = CurrentTime(date: date)
            guard let data = time.data else { return }
            let didSendValue = peripheral.updateValue(data, for: charateristic, onSubscribedCentrals: nil)
            print("updating value:", didSendValue, time.date)
        }
    }
    
    private var peripheral: CBPeripheralManager!
    private var charateristic: CBMutableCharacteristic!
    private var service: CBMutableService!
    
    override init() {
        print("init")
        super.init() // require to super init before self available
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
        //        setup()
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            setup()
        default:
            break
        }
    }
    
    func setup() {
        charateristic = CBMutableCharacteristic(type: UUID.characteristic.uuid, properties: [.read, .notify], value: nil, permissions: [.readable])
        service = CBMutableService(type: UUID.service.uuid, primary: true)
        service.characteristics = [charateristic]
        peripheral.add(service)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("didAdd:", service, error)
        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.uuid], CBAdvertisementDataLocalNameKey: "Timer"])
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("didStartAdvertising:", peripheral, error)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("didReceiveRead:", request)
        guard let date = date else {
            peripheral.respond(to: request, withResult: .insufficientResources)
            return
        }
        request.value = CurrentTime(date: date).data
        peripheral.respond(to: request, withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribe:", peripheral, characteristic)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("didUnsubscribe")
    }
}

struct CurrentTime {
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.current_time.xml
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.date_time.xml
    
    let date: Date
    
    var data: Data? {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        guard let year = components.year, let month = components.month, let day = components.day, let hour = components.hour, let minute = components.minute, let second = components.second else {
            return nil
        }
        var data = Data()
        data.append(UInt8(year & 0x00ff))
        data.append(UInt8(year >> 8))
        data.append(UInt8(month))
        data.append(UInt8(day))
        data.append(UInt8(hour))
        data.append(UInt8(minute))
        data.append(UInt8(second))
        data.append(0)
        data.append(0)
        data.append(0)
        return data
    }
    
    init(date: Date) {
        self.date = date
    }
}
