//
//  TempViewController.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import UIKit

class TempViewController: CDViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hero.isEnabled = true
        
        let yview = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        
        yview.backgroundColor = .yellow
        yview.heroID = "licensePlate"
        
        view.addSubview(yview)

        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
