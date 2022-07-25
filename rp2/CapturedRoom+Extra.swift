//
//  CapturedRoom+Extra.swift
//  rp2
//
//  Created by Mark Kim on 6/16/22.
//

import RoomPlan
import UIKit

extension CapturedRoom.Object.Category: CustomStringConvertible {
    public var description: String {
        switch self {
        case .storage:
            return "Storage"
        case .refrigerator:
            return "Refrigerator"
        case .stove:
            return "Stove"
        case .bed:
            return "Bed"
        case .sink:
            return "Sink"
        case .washerDryer:
            return "Washer"
        case .toilet:
            return "Toilet"
        case .bathtub:
            return "Bathtub"
        case .oven:
            return "Oven"
        case .dishwasher:
            return "Dishwasher"
        case .table:
            return "Table"
        case .sofa:
            return "Sofa"
        case .chair:
            return "Chair"
        case .fireplace:
            return "Fireplace"
        case .television:
            return "Screen"
        case .stairs:
            return "Stairs"
        @unknown default:
            return "Default"
        }
    }
}

func text(for category: CapturedRoom.Object.Category) -> String {
    return "\(category)"
}

func category(for text: String) -> CapturedRoom.Object.Category {
    switch text {
    case "Storage":
        return .storage
    case "Refrigerator":
        return .refrigerator
    case "Stove":
        return .stove
    case "Bed":
        return .bed
    case "Sink":
        return .sink
    case "Washer":
        return .washerDryer
    case "Toilet":
        return .toilet
    case "Bathtub":
        return .bathtub
    case "Oven":
        return .oven
    case "Dishwasher":
        return .dishwasher
    case "Table":
        return .table
    case "Sofa":
        return .sofa
    case "Chair":
        return .chair
    case "Fireplace":
        return .fireplace
    case "Screen":
        return .television
    case "Stairs":
        return .stairs
    default:
        return .storage
    }
}

func color(for category: CapturedRoom.Object.Category) -> UIColor {
    var color: UIColor

    switch category {
    case .storage:
        color = UIColor.white
    case .refrigerator:
        color = UIColor.white
    case .stove:
        color = UIColor.white
    case .bed:
        color = UIColor.white
    case .sink:
        color = UIColor.systemBlue
    case .washerDryer:
        color = UIColor.systemBlue
    case .toilet:
        color = UIColor.systemBlue
    case .bathtub:
        color = UIColor.systemBlue
    case .oven:
        color = UIColor.white
    case .dishwasher:
        color = UIColor.white
    case .table:
        color = UIColor.white
    case .sofa:
        color = UIColor.white
    case .chair:
        color = UIColor.white
    case .fireplace:
        color = UIColor.red
    case .television:
        color = UIColor.white
    case .stairs:
        color = UIColor.white
    @unknown default:
        color = UIColor.white
        break
    }

    return color
}

func capturedRoomObjectCategoryStrings() -> [String] {
    return ["Unknown", "Storage", "Refrigerator", "Stove", "Bed", "Sink", "Washer", "Toilet", "Bathtub", "Oven", "Dishwasher", "Table", "Sofa", "Chair", "Fireplace", "Screen", "Stairs"]
}

func roomAssetImageNames() -> [String] {
    return ["toy", "toaster", "tricycle"]
}

func roomAssetModels() -> [String: AssetModel] {
    // logic explanation:
    // floor = any horizontal surface that does not have a room object's top surface associated with it
    // neutral categories should check both "inside" a room object, and "on top of" a room object

    let assetModel1 = AssetModel(imageName: "toy",
                                 neutralCategories: [.storage, .sofa, .sink],
                                 fireHazardCategories: [.oven, .fireplace],
                                 electricalHazardCategories: [],
                                 isFloorOkay: true)
    let assetModel2 = AssetModel(imageName: "toaster",
                                 neutralCategories: [.storage, .bed, .washerDryer, .sofa, .chair],
                                 fireHazardCategories: [.oven, .fireplace],
                                 electricalHazardCategories: [.sink, .washerDryer, .toilet, .bathtub, .dishwasher],
                                 isFloorOkay: false)
    let assetModel3 = AssetModel(imageName: "tricycle",
                                 neutralCategories: [.storage, .table, .sofa, .chair, .stove, .washerDryer, .dishwasher],
                                 fireHazardCategories: [],
                                 electricalHazardCategories: [],
                                 isFloorOkay: true)

    return ["toy": assetModel1, "toaster": assetModel2, "tricycle": assetModel3]
}
