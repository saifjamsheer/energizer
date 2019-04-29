//
//  myCarViewController.swift
//  UBottomSheet
//
//  Created by Michalis Neophytou on 21/02/2019.
//  Copyright © 2019 otw. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CodableFirebase

class myCarViewController: UIViewController, UIScrollViewDelegate{
    @IBOutlet weak var myCarNavBar: UINavigationBar!
    @IBOutlet weak var carScrollView: UIScrollView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var carPageControl: UIPageControl!
    @IBOutlet weak var chargeRemainingRangeLabel: UILabel!
    @IBOutlet weak var chargeRemainingPercentageLabel: UILabel!
    @IBOutlet weak var milesRemainingLabel: UILabel!
    @IBOutlet weak var kmRemainingLabel: UILabel!
    @IBOutlet weak var kWhTotalConsumptionLabel: UILabel!
    @IBOutlet weak var kWhAverageConsumptionLabel: UILabel!
    @IBOutlet weak var milageLabel: UILabel!
    @IBOutlet weak var dateLastChargeLabel: UILabel!
    @IBOutlet weak var sinceDateLastChargeLabel: UILabel!

    var ref: DatabaseReference!
    var myCarInfoArray: [myCarInfo] = []
    var currentCarInfo: myCarInfo?
    var carsImageArray: [UIImage] = [#imageLiteral(resourceName: "Car1"),  #imageLiteral(resourceName: "Car3")]
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.theme_backgroundColor = Colors.primaryColor
        if UserDefaults.standard.object(forKey: "LastCarInfoAvailable") != nil{
            let firstCarData = UserDefaults.standard.object(forKey: "LastCarInfoAvailable") as! Data
            let carObjectLoaded = try? PropertyListDecoder().decode(myCarInfo.self, from: firstCarData)
            self.pageToShow(carInfoToShow: carObjectLoaded!, loadedCar: true)
            self.carScrollView.setContentOffset(CGPoint(x: CGFloat(carObjectLoaded!.IDinList!) * self.carScrollView.frame.width, y: 0), animated: false)
        }
            
        carScrollView.delegate = self
        ref = Database.database().reference()
        
//        self.getMyCarInfo()             //used to update Firebase car info
        
        ref.child("users/email/CarInfo/").observe(.value, with: { snapshot in
            self.myCarInfoArray = []
            print ("Observing Favourites")
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                do {
                    let carInfo = try FirebaseDecoder().decode(myCarInfo.self, from: child.value!)
                    self.myCarInfoArray.append(carInfo)
                    self.myCarInfoArray[self.myCarInfoArray.count - 1].IDinList = self.myCarInfoArray.count - 1
                } catch let error {
                    print(error)
                }
            }
            //self.scrollViewDidEndDecelerating(self.carScrollView)
            self.carScrollView.isPagingEnabled = true
            self.carScrollView.contentSize = CGSize(width:self.carScrollView.frame.size.width * CGFloat(self.myCarInfoArray.count), height: self.carScrollView.frame.size.height)
            self.view.bringSubviewToFront(self.carPageControl)
            self.view.addSubview(self.carScrollView)
            
            for subview in self.carScrollView.subviews{
                subview.removeFromSuperview()
            }
            for index in 0..<self.myCarInfoArray.count {
                self.frame.origin.x = self.carScrollView.frame.size.width * CGFloat(index)
                self.frame.size = self.carScrollView.frame.size
                let subView = UIImageView(frame: self.frame)
                subView.image = self.carsImageArray[self.myCarInfoArray[index].carImage!]
                subView.contentMode = .scaleAspectFit
                self.carScrollView.addSubview(subView)
            }
        })
        
        ref.child("users/email/UserInfo/CurrentCar/").observe(.value, with: { snapshot in
            guard let value = snapshot.value else { return }
            do {
                let currentCarInfo = try FirebaseDecoder().decode(myCarInfo.self, from: value)
                self.currentCarInfo = currentCarInfo
                self.configurePageControl(currentPage: self.currentCarInfo!.IDinList ?? 0)
                self.pageToShow(carInfoToShow: currentCarInfo, loadedCar: true)
                let scrollXOffset = CGFloat(currentCarInfo.IDinList!) * self.carScrollView.frame.width
                self.carScrollView.setContentOffset(CGPoint(x: scrollXOffset, y: 0), animated: true)
            } catch let error {
                print(error)
            }
        })
    }
    
    func addCarInfoToFirebase(carInfo: myCarInfo){
        let data = try! FirebaseEncoder().encode(carInfo)
        ref.child("users/email/CarInfo/" + carInfo.carModel!).setValue(data)
    }
    
    func addCurrentCarInfoToFirebase(carInfo: myCarInfo){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(carInfo), forKey: "LastCarInfoAvailable")
        let data = try! FirebaseEncoder().encode(carInfo)
        ref.child("users/email/UserInfo/CurrentCar/").setValue(data)
    }
    
    func getMyCarInfo(){
        let myCarInfo1 = myCarInfo(carModel: "Range Rover", carColour: "Navy Blue", carImage: 0,  IDinList: nil, isEV: true, chargeRemainingRange: 13.1, chargeRemainingPercentage: 0.99, milesRemaining: 29.5, kmRemaining: 47.48, kWhTotalConsumption: 3719.2, kWhAverageConsumption: 12.1, milage: 2.29, dateLastCharge: "25/02/19", sinceDateLastCharge: "4 hours ago")
        let myCarInfo2 = myCarInfo(carModel: "Range Rover Velar", carColour: "Silver", carImage: 1, IDinList: nil, isEV: true, chargeRemainingRange: 12.1, chargeRemainingPercentage: 0.89, milesRemaining: 23.5, kmRemaining: 37.82, kWhTotalConsumption: 219.2, kWhAverageConsumption: 10.1, milage: 2.19, dateLastCharge: "22/02/19", sinceDateLastCharge: "3 days ago")
        self.myCarInfoArray.append(myCarInfo1)
        self.myCarInfoArray.append(myCarInfo2)
        for car in self.myCarInfoArray{
            addCarInfoToFirebase(carInfo: car)
        }
    }
    
    func pageToShow(carInfoToShow: myCarInfo, loadedCar: Bool){
        if loadedCar == false{
            self.addCurrentCarInfoToFirebase(carInfo: carInfoToShow)    //set current car for mapview
        }
        //myCarNavBar.topItem?.title = "My " + myCarInfo2Show.carModel!
        let carNameLabel = UILabel()
        carNameLabel.theme_textColor = Colors.primaryTextColor
        carNameLabel.text = "My " + carInfoToShow.carModel!
        myCarNavBar.topItem?.titleView = carNameLabel
        chargeRemainingRangeLabel.text = String(format: "%.2f", carInfoToShow.chargeRemainingRange!)
        chargeRemainingPercentageLabel.text = String(carInfoToShow.chargeRemainingPercentage!*100) + "%"
        milesRemainingLabel.text = String(format: "%.2f", carInfoToShow.milesRemaining!)
        kmRemainingLabel.text = String(format: "%.2f", carInfoToShow.kmRemaining!)
        kWhTotalConsumptionLabel.text = String(format: "%.0f", carInfoToShow.kWhTotalConsumption!)
        kWhAverageConsumptionLabel.text = String(format: "%.2f", carInfoToShow.kWhAverageConsumption!)
        milageLabel.text = String(format: "%.2f", carInfoToShow.milage!)
        dateLastChargeLabel.text = carInfoToShow.dateLastCharge
        sinceDateLastChargeLabel.text = carInfoToShow.sinceDateLastCharge!
    }
    
    func configurePageControl(currentPage: Int) {
        self.carPageControl.layer.zPosition = 1
        self.carPageControl.numberOfPages = myCarInfoArray.count
        self.carPageControl.currentPage = currentPage
        self.view.addSubview(carPageControl)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(carPageControl.currentPage) * carScrollView.frame.size.width
        carScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        if ((Int(pageNumber) + 1) > self.myCarInfoArray.count){
            pageNumber = pageNumber - 1
        }
        carPageControl.currentPage = Int(pageNumber)
        self.pageToShow(carInfoToShow: myCarInfoArray[Int(pageNumber)], loadedCar: false)
    }
}

extension myCarViewController{
    func setPageControlHidden (hidden: Bool){
        for subView in self.view.subviews{
            if subView is UIScrollView{
                subView.frame = self.view.bounds
            }
            else if subView is UIPageControl{
                subView.isHidden = hidden
            }
        }
    }
    
    func resize(image: UIImage, toSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size,false,1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return resizedImage
        }
        UIGraphicsEndImageContext()
        return image
    }
}

