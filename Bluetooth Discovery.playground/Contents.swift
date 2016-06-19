
import CoreBluetooth
import PlaygroundSupport
import UIKit

 struct Device {
    let advertisementName : String
    let RSSI : String
    let UUID : String
}

class DiscoveryTableDataSource: NSObject, UITableViewDataSource {
    var devices = [String:Device]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DiscoveryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        if let key = Array(devices.keys)[indexPath.row] as? String {
            if let device = devices[key] {
                cell.textLabel?.text = device.advertisementName + " (RSSI:"+device.RSSI + ")"
                cell.detailTextLabel?.text = device.UUID
            }
        }
        return cell
    }
}

class BTDiscovery: NSObject, CBCentralManagerDelegate {
    let deviceTableView = UITableView()
    let dataSource = DiscoveryTableDataSource()
    var devices = [Device]() 
    
    let stateView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    override init() {
        stateView.backgroundColor = #colorLiteral(red: 0.600000023841858, green: 0.600000023841858, blue: 0.600000023841858, alpha: 1.0)
        deviceTableView.tableHeaderView = stateView
        deviceTableView.dataSource = dataSource
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            stateView.backgroundColor = #colorLiteral(red: 0.341176480054855, green: 0.623529434204102, blue: 0.168627455830574, alpha: 1.0)
            central.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff: 
            stateView.backgroundColor = #colorLiteral(red: 0.572549045085907, green: 0.0, blue: 0.23137255012989, alpha: 1.0)
            dataSource.devices.removeAll()
            deviceTableView.reloadData()
        default:
             stateView.backgroundColor = #colorLiteral(red: 0.803921580314636, green: 0.803921580314636, blue: 0.803921580314636, alpha: 1.0)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
        let advertisementName = (advertisementData["CBAdvertisementDataLocalNameKey"] as? String) ?? peripheral.name ?? "Unnamed"
        print(String(advertisementData))
        let uuid = peripheral.identifier.uuidString
        let device = Device(advertisementName: advertisementName, RSSI: String(RSSI), UUID: uuid)
        dataSource.devices[uuid] = device
        deviceTableView.reloadData()
    }
}

let discovery = BTDiscovery()
let manager = CBCentralManager(delegate: discovery, queue: nil)

PlaygroundPage.current.liveView = discovery.deviceTableView
PlaygroundPage.current.needsIndefiniteExecution = true

