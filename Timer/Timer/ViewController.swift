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
            // update peripheral value and notify
        }
    }
    
    override init() {
        print("init")
        super.init() // require to super init before self available
        // create peripheral
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // setup peripheral depending of state
    }
    
    func setup() {
        // create characteristic
        // create service using characteristic
        // add service to peripheral
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        // service ready
        // start advertising
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        //
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        // respond to read request
        // peripheral.respond(to: CBATTRequest, withResult: CBATTError.Code)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        //
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        //
    }
}
