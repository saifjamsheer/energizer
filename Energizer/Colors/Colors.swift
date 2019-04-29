//
//  Colors.swift
//  Energizer
//
//  Created by Saif Jamsheer on 4/10/19.
//

import Foundation
import UIKit
import SwiftTheme

//class DayColors {
//
//    let primaryColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
//    let secondaryColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
//    let accentColor = UIColor(red:0.40, green:0.37, blue:1.00, alpha:1.0)
//    let primaryTextColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
//    let accentTextColor = UIColor(red:0.40, green:0.37, blue:1.00, alpha:1.0)
//    let mapIconsColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
//    let searchTextColor = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
//    let firstBorderColor = UIColor(red:0.40, green:0.37, blue:1.00, alpha:1.0)
//    let secondBorderColor = UIColor(red:0.34, green:0.45, blue:1.00, alpha:1.0)
//    let thirdBorderColor = UIColor(red:0.20, green:0.59, blue:0.99, alpha:1.0)
//    let fourthBorderColor = UIColor(red:0.23, green:0.80, blue:0.88, alpha:1.0)
//    let buttonTextColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
//    let drawerIconColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
//    let detailTitleTextColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
//    let subTextColor = UIColor(red:0.31, green:0.31, blue:0.31, alpha:1.0)
//    let innerButtonColor = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
//
//    let chargerRedColor = UIColor(red:0.98, green:0.48, blue:0.48, alpha:1.0)
//    let chargerAmberColor = UIColor(red:0.98, green:0.67, blue:0.48, alpha:1.0)
//    let chargerGreenColor = UIColor(red:0.00, green:0.69, blue:0.48, alpha:1.0)
//    let drawerLineColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)
//    let searchBarColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
//    let favouriteFilledColor = UIColor(red:1.00, green:0.00, blue:0.40, alpha:1.0)
//    let favouriteUnfilledColor = UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.0)
//    let renameSquareColor = UIColor(red:1.00, green:0.70, blue:0.47, alpha:1.0)
//    let deleteSquareColor = UIColor(red:1.00, green:0.39, blue:0.27, alpha:1.0)
//    let editContainerColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:0.9)
//    let editTextBoxColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
//    let detailContractButton = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
//    let stationOvalColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
//
//    let detailSubTextColor = UIColor(red:0.22, green:0.22, blue:0.22, alpha:1.0)
//    let filterHeaderTextColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
//    let editHintTextColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
//    let detailDescriptionText = UIColor(red:0.43, green:0.44, blue:0.50, alpha:1.0)
//    let detailDropText = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
//    let saveDisabledTextColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.0)
//
//    let containerBorderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
//    let searchBarBorderColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
//    let tabBarSeparationColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)
//    let editTextBoxBorderColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)
//    let stationOvalBorderColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
//
//}
//
//class NightColors {
//
//    let primaryColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
//    let secondaryColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
//    let accentColor = UIColor(red:0.20, green:0.59, blue:0.99, alpha:1.0)
//    let primaryTextColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
//    let accentTextColor = UIColor(red:0.20, green:0.59, blue:0.99, alpha:1.0)
//    let mapIconsColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
//    let searchTextColor = UIColor(red:0.43, green:0.46, blue:0.49, alpha:1.0)
//    let firstBorderColor = UIColor(red:0.40, green:0.37, blue:1.00, alpha:1.0)
//    let secondBorderColor = UIColor(red:0.34, green:0.45, blue:1.00, alpha:1.0)
//    let thirdBorderColor = UIColor(red:0.20, green:0.59, blue:0.99, alpha:1.0)
//    let fourthBorderColor = UIColor(red:0.23, green:0.80, blue:0.88, alpha:1.0)
//    let buttonTextColor = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1.0)
//    let drawerIconColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
//    let detailTitleTextColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
//    let subTextColor = UIColor(red:0.43, green:0.46, blue:0.49, alpha:1.0)
//    let innerButtonColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
//
//    let chargerRedColor = UIColor(red:0.65, green:0.19, blue:0.19, alpha:1.0)
//    let chargerAmberColor = UIColor(red:0.93, green:0.59, blue:0.41, alpha:1.0)
//    let chargerGreenColor = UIColor(red:0.02, green:0.42, blue:0.29, alpha:1.0)
//    let drawerLineColor = UIColor(red:0.18, green:0.20, blue:0.21, alpha:1.0)
//    let searchBarColor = UIColor(red:0.07, green:0.08, blue:0.09, alpha:1.0)
//    let favouriteFilledColor = UIColor(red:1.00, green:0.00, blue:0.40, alpha:1.0)
//    let favouriteUnfilledColor = UIColor(red:0.43, green:0.46, blue:0.49, alpha:1.0)
//    let renameSquareColor = UIColor(red:1.00, green:0.70, blue:0.47, alpha:1.0)
//    let deleteSquareColor = UIColor(red:1.00, green:0.39, blue:0.27, alpha:1.0)
//    let editContainerColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.9)
//    let editTextBoxColor = UIColor(red:0.07, green:0.08, blue:0.09, alpha:1.0)
//    let detailContractButton = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
//    let stationOvalColor = UIColor(red:0.07, green:0.08, blue:0.09, alpha:1.0)
//
//    let detailSubTextColor = UIColor(red:0.43, green:0.46, blue:0.49, alpha:1.0)
//    let filterHeaderTextColor = UIColor(red:0.43, green:0.46, blue:0.49, alpha:1.0)
//    let editHintTextColor = UIColor(red:0.43, green:0.46, blue:0.49, alpha:1.0)
//    let detailDescriptionText = UIColor(red:0.43, green:0.46, blue:0.49, alpha:1.0)
//    let detailDropText = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
//    let saveDisabledTextColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
//
//    let containerBorderColor = UIColor(red:0.18, green:0.20, blue:0.21, alpha:1.0)
//    let searchBarBorderColor = UIColor(red:0.07, green:0.08, blue:0.09, alpha:1.0)
//    let tabBarSeparationColor = UIColor(red:0.18, green:0.20, blue:0.21, alpha:1.0)
//    let editTextBoxBorderColor = UIColor(red:0.07, green:0.08, blue:0.09, alpha:1.0)
//    let stationOvalBorderColor = UIColor(red:0.09, green:0.09, blue:0.10, alpha:1.0)
//
//}

enum Colors {
    static let primaryColor: ThemeColorPicker = ["#ffffff", "#000000"]
    static let secondaryColor: ThemeColorPicker = ["#fafafa", "#000000"]
    static let accentColor: ThemeColorPicker = ["#665eff", "#3497fd"]
    static let primaryTextColor: ThemeColorPicker = ["#000000", "#d9d9d8"]
    static let accentTextColor: ThemeColorPicker = ["#665eff", "#3497fd"]
    static let mapIconsColor: ThemeColorPicker = ["#000000", "#d9d9d8"]
    static let searchTextColor: ThemeColorPicker = ["#9b9b9b", "#6e767d"]
    static let firstBorderColor: ThemeColorPicker = ["#665eff", "#665eff"]
    static let secondBorderColor: ThemeColorPicker = ["#5773ff", "#5773ff"]
    static let thirdBorderColor: ThemeColorPicker = ["#3497fd", "#3497fd"]
    static let fourthBorderColor: ThemeColorPicker = ["#3acce1", "#3acce1"]
    static let buttonTextColor: ThemeColorPicker = ["#ffffff", "#fdfdfd"]
    static let drawerIconColor: ThemeColorPicker = ["#000000", "#d9d9d8"]
    static let detailTitleTextColor: ThemeColorPicker = ["#000000", "#000000"]
    static let subTextColor: ThemeColorPicker = ["#505050", "#6e757d"]
    static let innerButtonColor: ThemeColorPicker = ["#9b9b9b", "#d9d9d8"]
    
    static let chargerRedColor: ThemeColorPicker = ["#fa7a7a", "#a73131"]
    static let chargerAmberColor: ThemeColorPicker = ["#faaB7a", "#ed9769"]
    static let chargerGreenColor: ThemeColorPicker = ["#00b17a", "#056a4b"]
    static let connectorRedColor: ThemeCGColorPicker = ["#fa7a7a", "#a73131"]
    static let connectorAmberColor: ThemeCGColorPicker = ["#faaB7a", "#ed9769"]
    static let connectorGreenColor: ThemeCGColorPicker = ["#00b17a", "#056a4b"]
    static let drawerLineColor: ThemeColorPicker = ["#bababa", "#2f3336"]
    static let searchBarColor: ThemeColorPicker = ["#f8f8f8", "#121517"]
    static let favouriteFilledColor: ThemeColorPicker = ["#ff0065", "#ff0065"]
    static let favouriteUnfilledColor: ThemeColorPicker = ["#989898", "#6e757d"]
    static let renameSquareColor: ThemeColorPicker = ["#ffb279", "#ffb279"]
    static let deleteSquareColor: ThemeColorPicker = ["#ff6346", "#ff6346"]
    static let editContainerColor: ThemeColorPicker = ["#ffffff", "#000000"] //opacity
    static let editTextBoxColor: ThemeColorPicker = ["#ffffff", "#121517"]
    static let detailContractButton: ThemeColorPicker = ["#000000", "#000000"]
    static let stationOvalColor: ThemeColorPicker = ["#fafafa", "#121517"]
    
    static let detailSubTextColor: ThemeColorPicker = ["#383838", "#6e757d"]
    static let filterHeaderTextColor: ThemeColorPicker = ["#181818", "#6e757d"]
    static let editHintTextColor: ThemeColorPicker = ["#c7c7cc", "#6e767d"]
    static let detailDescriptionTextColor: ThemeColorPicker = ["#6e717f", "#6e757d"]
    static let detailDropTextColor: ThemeColorPicker = ["#434343", "#d9d9d8"]
    static let saveDisabledTextColor: ThemeColorPicker = ["#676767", "#d9d9d8"]
    
    static let containerBorderColor: ThemeCGColorPicker = ["#e3e3e3", "#2f3336"]
    static let containerColor: ThemeColorPicker = ["#e3e3e3", "#2f3336"]
    static let searchBarBorderColor: ThemeCGColorPicker = ["#f7f7f7", "#121517"]
    static let tabBarSeparationColor: ThemeColorPicker = ["#bababa", "#2f3336"]
    static let editContainerBorderColor: ThemeCGColorPicker = ["3f3f3f", "#2f3336"]
    static let editTextBoxBorderColor: ThemeCGColorPicker = ["#bababa", "#121517"]
    static let stationOvalBorderColor: ThemeCGColorPicker = ["#f8f8f8", "#16181a"]
    static let filterBorderColor: ThemeCGColorPicker = ["#665eff", "#3497fd"]
    
    static let pColor: ThemeCGColorPicker = ["#ffffff", "#000000"]
    static let cColor: ThemeCGColorPicker = ["#000000", "#ffffff"]
    
    static let barStyle: ThemeBarStylePicker = [.default, .black]
    static let sliderRightColor: ThemeColorPicker = ["#d1cfff", "#0f2c4a"]
    
    static let barTextColors = ["#000000", "#d9d9d8"]

}
