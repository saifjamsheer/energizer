//
//  AccountSettingsController.swift
//  Energizer
//
//  Created by Michalis Neophytou on 10/04/2019.
//

import UIKit
import SwiftTheme

class AccountSettingsController: UIViewController {
    
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var darkModeSwitchItem: UISwitch!
    @IBAction func darkModeSwitch(_ sender: UISwitch) {
        MyThemes.switchNight(isToNight: sender.isOn)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.theme_backgroundColor = Colors.searchBarColor
        darkModeLabel.theme_textColor = Colors.primaryTextColor
        extendedLayoutIncludesOpaqueBars = true
        if MyThemes.isNight(){
            darkModeSwitchItem.setOn(true, animated: false)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if MyThemes.isNight() {
            return .lightContent
        } else {
            return .default
        }
    }
}
