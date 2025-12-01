//
//  ActivitiesTypes.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 30.10.2023.
//

import Foundation
import SwiftUICore

struct Activity{
    var name : LocalizedStringKey = "" // LocalizedStringKey - this is for corect multilanguare translation
    var image : String = ""
    var category : AcitivityCategory
   
}

enum AcitivityCategory: LocalizedStringKey, CaseIterable{
    case Walk,Bike,Drive,Winter,Water
}

enum ActivityType:  String, CaseIterable {
    case UNKNOWN
    case HIKING,WALKING,RUNNING,MUSHROOM_HUNTING
    case BIKE_MOUNT,BIKE_ROAD,BIKE_CITY,BIKE_BMX,BIKE_ELECTRO
    case CAR,CAR_OFFROAD,ATV,BUGGY,MOTORCYCLE_ENDURO,MOTORCYCLE_DUALSPORT,SCOOTER,MOTORCYCLE_CITY,MOTORCYCLE_TOURING,MOTORCYCLE_SPORT
    case SKI,SKI_FREERIDE,SKI_CROSS_COUNTRY,SKI_ALPINISM,SHOWBOARD,SLEIGH,SNOW_MOBILE
    case KAYAK,RAFTING,DINGHY,JETSKI
}


func GetActivity(_ activityTAype: ActivityType) -> Activity {
    switch (activityTAype){
   
    case .UNKNOWN  : return Activity(name: "Unknown", image: "", category: .Walk)
    //walk
    case .HIKING : return Activity(name: "Hiking", image: "hiking", category: .Walk)
    case .WALKING : return Activity(name: "Walking", image: "walking", category: .Walk)
    case .RUNNING : return Activity(name: "Running", image: "running", category: .Walk)
    case .MUSHROOM_HUNTING : return Activity(name: "Mushroom Hunting", image: "mushroom", category: .Walk)
    
        
    //bike
    case .BIKE_MOUNT : return Activity(name: "Mount Bike", image: "bikeMount", category: .Bike)
    case .BIKE_ROAD : return Activity(name: "Road Bike", image: "bikeRoad", category: .Bike)
    case .BIKE_CITY : return Activity(name: "City Bike", image: "bikeCity", category: .Bike)
    case .BIKE_BMX : return Activity(name: "BMX Bike", image: "bikeBMX", category: .Bike)
    case .BIKE_ELECTRO : return Activity(name: "Electric Bike", image: "bikeElectro", category: .Bike)
        
   
    //drive
    case .CAR : return Activity(name: "Car", image: "car", category: .Drive)
    case .CAR_OFFROAD : return Activity(name: "Offroad Vehicle", image: "carOffroad", category: .Drive)
    case .ATV : return Activity(name: "ATV", image: "atv", category: .Drive)
    case .BUGGY : return Activity(name: "Buggy", image: "buggy", category: .Drive)
    case .MOTORCYCLE_ENDURO : return Activity(name: "Enduro Motorcycle", image: "enduroMotorcycle", category: .Drive)
    case .MOTORCYCLE_DUALSPORT : return Activity(name: "DualSport Motorcycle", image: "dualsportMotorcycle", category: .Drive)
    case .SCOOTER : return Activity(name: "Scooter", image: "scooter", category: .Drive)
    case .MOTORCYCLE_CITY : return Activity(name: "City Motorcycle", image: "cityMotorcycle", category: .Drive)
    case .MOTORCYCLE_TOURING : return Activity(name: "Touring Motorcycle", image: "touringMotorcycle", category: .Drive)
    case .MOTORCYCLE_SPORT : return Activity(name: "Sport Motorcycle", image: "sportMotorcycle", category: .Drive)
        
    //winter
    case .SKI : return Activity(name: "Ski", image: "ski", category: .Winter)
    case .SKI_FREERIDE : return Activity(name: "Freeride ski", image: "skiFreeride", category: .Winter)
    case .SKI_CROSS_COUNTRY : return Activity(name: "Cross-Country ski", image: "skiCrossCountry", category: .Winter)
    case .SKI_ALPINISM : return Activity(name: "Alpinism ski", image: "skiAlpinism", category: .Winter)
    case .SHOWBOARD : return Activity(name: "Snowboard", image: "showBoard", category: .Winter)
    case .SLEIGH : return Activity(name: "Sleigh", image: "sleigh", category: .Winter)
    case .SNOW_MOBILE : return Activity(name: "Snowmobile", image: "snowmobile", category: .Winter)
    
        
    //water
    case .KAYAK : return Activity(name: "Kayak", image: "kayak", category: .Water)
    case .RAFTING : return Activity(name: "Rafting", image: "rafting", category: .Water)
    case .DINGHY : return Activity(name: "Dinghy", image: "dinghy", category: .Water)
    case .JETSKI : return Activity(name: "JetSki", image: "jetSki", category: .Water)
        
        
        
    }
 
}



