//
//  FiltersView.swift
//  Energizer
//
//  Created by Michalis Neophytou on 06/02/2019.
//  Copyright © 2019 Michalis Neophytou. All rights reserved.
//  This is the View class that contains the filters


import Foundation
import UIKit
import SwiftTheme

class FiltersView: UIView {
    
    var delegate : PassFilterProtocol? = nil     // protocol that is used to call functions from the MapView (filterAllData function)
    
    var resetFilter = Filter(WithinRangeOnly: false, EVChargerTypeOnly: false, PriceMax: 100, IsOperationalNow: false, FastestChargersOnly: false, minPower: 120.0, minQuantity: 0) //passed to MapViewController when reset button is pressed
    
    var filterToPass = Filter(WithinRangeOnly: false, EVChargerTypeOnly: false, PriceMax: 100, IsOperationalNow: false, FastestChargersOnly: false, minPower: 120.0, minQuantity: 0)  //filter object passed to be modified by user interaction and passed to MapViewController
    
    var ShowAllClicked: Bool = true
    let buttonCornerRadi : CGFloat = 7
    let buttonBorderWidths : CGFloat = 2
    
    @IBOutlet weak var ResetButton: UIButton!
    @IBAction func ResetClicked(_ sender: UIButton) {
        reset()
    }
    @IBOutlet weak var whichToShowLabel: UILabel!
    @IBOutlet weak var maxPriceTitleLabel: UILabel!
    @IBOutlet weak var connectorsAvailableTitleLabel: UILabel!
    @IBOutlet weak var priceAnyLabel: UILabel!
    @IBOutlet weak var connectorsAnyLabel: UILabel!
    @IBOutlet weak var freeLabel: UILabel!
    @IBOutlet weak var tenLabel: UILabel!
    
    @IBOutlet weak var WithinRange: UIButton!
    @IBOutlet weak var Type2Only: UIButton!
    @IBOutlet weak var ShowAll: UIButton!
    @IBOutlet weak var PriceSlider: UISlider!
    @IBOutlet weak var PriceSliderValue: UILabel!
    @IBOutlet weak var ConnectorsAvailableSliderValue: UILabel!
    @IBOutlet weak var ConnectorsAvailableSlider: UISlider!
    
    @IBAction func ConnectorsAvailableValueChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(ConnectorsAvailableSlider.value)), animated: true)
        ConnectorsAvailableSliderValue.text = "\(Int(ConnectorsAvailableSlider.value))"
        if ConnectorsAvailableSlider.value == 0 {
            ConnectorsAvailableSliderValue.text = "Any"
        }
        if filterToPass.minQuantity != Int(sender.value){
            filterToPass.minQuantity = Int(sender.value)
            updateFilter()
        }
    }
    
    @IBAction func PriceSliderValueChanged(_ sender: UISlider) {
        let reversePriceValue = 5 - PriceSlider.value
        if "\(round(100*PriceSlider.value)/100)".count == 3 {
            PriceSliderValue.text = "\(round(100*reversePriceValue)/100)"+"0£/kWh"
            
        }else{
            PriceSliderValue.text = "\(round(100*reversePriceValue)/100)"+"£/kWh"
        }
        if PriceSlider.value == 0 {
            PriceSliderValue.text = "Any"
        }
        
        if filterToPass.PriceMax != Int((100*reversePriceValue).rounded()){
            filterToPass.PriceMax = Int((100*reversePriceValue).rounded())
            updateFilter()
        }
    }
    
    @IBAction func buttonActon(sender: UIButton) {  //linking all top filter buttons to one function
        switch sender {                             //function to figure out logic among the top filter buttons
        case WithinRange:
            if filterToPass.WithinRangeOnly == true{
                filterToPass.WithinRangeOnly = false
                if filterToPass.EVChargerTypeOnly == false {
                    ShowAllClicked = true
                }
            } else {
                filterToPass.WithinRangeOnly = true
                if ShowAllClicked == true {
                    ShowAllClicked = false
                }
            }
        case Type2Only:
            if filterToPass.EVChargerTypeOnly == true{
                filterToPass.EVChargerTypeOnly = false
                if filterToPass.WithinRangeOnly == false {
                    ShowAllClicked = true
                }
            } else {
                filterToPass.EVChargerTypeOnly = true
                if ShowAllClicked == true {
                    ShowAllClicked = false
                }
            }
        case ShowAll:
            if ShowAllClicked == true{
                ShowAllClicked = false
                filterToPass.EVChargerTypeOnly = true
                filterToPass.WithinRangeOnly = true
            } else {
                ShowAllClicked = true
                filterToPass.EVChargerTypeOnly = false
                filterToPass.WithinRangeOnly = false
            }
        default:
            print("Break")
            break
        }
        reColorButtons()
        updateFilter()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.theme_backgroundColor = Colors.primaryColor
        PriceSliderValue.theme_textColor = Colors.primaryTextColor
        ConnectorsAvailableSliderValue.theme_textColor = Colors.primaryTextColor
        whichToShowLabel.theme_textColor = Colors.primaryTextColor
        maxPriceTitleLabel.theme_textColor = Colors.primaryTextColor
        connectorsAvailableTitleLabel.theme_textColor = Colors.primaryTextColor
        priceAnyLabel.theme_textColor = Colors.primaryTextColor
        connectorsAnyLabel.theme_textColor = Colors.primaryTextColor
        freeLabel.theme_textColor = Colors.primaryTextColor
        tenLabel.theme_textColor = Colors.primaryTextColor
        PriceSlider.theme_minimumTrackTintColor = Colors.accentColor
        PriceSlider.theme_maximumTrackTintColor = Colors.sliderRightColor
        ConnectorsAvailableSlider.theme_minimumTrackTintColor = Colors.accentColor
        ConnectorsAvailableSlider.theme_maximumTrackTintColor = Colors.sliderRightColor
        ConnectorsAvailableSlider.theme_thumbTintColor = Colors.accentColor
        PriceSlider.theme_thumbTintColor = Colors.accentColor
        WithinRange.layer.cornerRadius = buttonCornerRadi
        WithinRange.layer.borderWidth = buttonBorderWidths
        ShowAll.layer.cornerRadius = buttonCornerRadi
        ShowAll.layer.borderWidth = buttonBorderWidths
        Type2Only.layer.cornerRadius = buttonCornerRadi
        Type2Only.layer.borderWidth = buttonBorderWidths
        ResetButton.layer.cornerRadius = buttonCornerRadi
        ResetButton.theme_backgroundColor = Colors.accentColor
        ResetButton.theme_setTitleColor(Colors.buttonTextColor, forState: .normal)
        PriceSliderValueChanged(PriceSlider)                            //sync label to slider
        ConnectorsAvailableValueChanged(ConnectorsAvailableSlider)      //sync label to slider
        
        reColorButtons()
    }
    
    func reset(){             //resets filter ui and sends default filter to the MapViewController
        PriceSlider.setValue(0, animated: true)
        ConnectorsAvailableSlider.setValue(0, animated: true)
        ShowAllClicked = true
        filterToPass.EVChargerTypeOnly = false
        filterToPass.WithinRangeOnly = false
        reColorButtons()
        PriceSliderValueChanged(PriceSlider)                            //sync label to slider
        ConnectorsAvailableValueChanged(ConnectorsAvailableSlider)      //sync label to slider
    }
    
    func reColorButtons(){     //function that checks the status of each button and updates formatting
        if ShowAllClicked == true{
            ShowAll.theme_backgroundColor = Colors.accentColor
            ShowAll.layer.borderColor = UIColor.clear.cgColor
            ShowAll.theme_setTitleColor(Colors.buttonTextColor, forState: .normal)
        }else {
            ShowAll.backgroundColor = UIColor.clear
            ShowAll.layer.theme_borderColor = Colors.filterBorderColor
            ShowAll.theme_setTitleColor(Colors.accentColor, forState: .normal)
        }
        if filterToPass.EVChargerTypeOnly == true{
            Type2Only.theme_backgroundColor = Colors.accentColor
            Type2Only.layer.borderColor = UIColor.clear.cgColor
            Type2Only.theme_setTitleColor(Colors.buttonTextColor, forState: .normal)
        }else {
            Type2Only.backgroundColor = UIColor.clear
            Type2Only.layer.theme_borderColor = Colors.filterBorderColor
            Type2Only.theme_setTitleColor(Colors.accentColor, forState: .normal)
        }
        if filterToPass.WithinRangeOnly == true{
            WithinRange.theme_backgroundColor = Colors.accentColor
            WithinRange.layer.borderColor = UIColor.clear.cgColor
            WithinRange.theme_setTitleColor(Colors.buttonTextColor, forState: .normal)
        }else{
            WithinRange.backgroundColor = UIColor.clear
            WithinRange.layer.theme_borderColor = Colors.filterBorderColor
            WithinRange.theme_setTitleColor(Colors.accentColor, forState: .normal)
        }
    }
    
    func updateFilter(){                        //function used to pass to MapViewController
        if filterToPass != resetFilter{
            delegate?.filterAllData(filter: filterToPass)
        }
    }
}
