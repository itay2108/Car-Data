//
//  PreferencesViewController.swift
//  Car Data
//
//  Created by itay gervash on 14/06/2022.
//

import UIKit

class PreferencesViewController: CDTableViewController {

    @IBOutlet var cells: [UITableViewCell]!

    override func setupViews() {
        super.setupViews()
        
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print((tableView.cellForRow(at: indexPath) as? UITableViewCell)?.textLabel?.text)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 14.5
    }
}
