//
//  QrCodeDataListViewController.swift
//  QrReaderViewController
//
//  Created by u-pt on 2024/09/08.
//

import Foundation

import UIKit
import AVFoundation

class QrCodeDataListViewController: UITableViewController {
    var qrDatas: [String]
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init?(coder aDecoder: NSCoder, qrDatas: [String]) {
        self.qrDatas = qrDatas
        super.init(coder: aDecoder)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.qrDatas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QrDataCell", for: indexPath as IndexPath)
        
        if indexPath.row < self.qrDatas.count {
            var cellConfiguer = cell.defaultContentConfiguration()
            cellConfiguer.text = self.qrDatas[indexPath.row]
            cell.contentConfiguration = cellConfiguer
        }
        
        return cell
    }
}
