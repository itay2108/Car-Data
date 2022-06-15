//
//  CDNavigationController.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import UIKit
import Hero

class CDNavigationController: UINavigationController {
    
    var navigationAnimationType: HeroDefaultAnimationType = .fade {
        didSet {
            hero.navigationAnimationType = navigationAnimationType
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isHidden = true
        hero.isEnabled = true
        hero.navigationAnimationType = navigationAnimationType
        // Do any additional setup after loading the view.
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
