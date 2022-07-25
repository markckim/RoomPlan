//
//  AssetNode.swift
//  rp2
//
//  Created by Mark Kim on 6/17/22.
//

import ARKit
import RoomPlan

enum AssetBoxStatus {
    case good
    case neutral
    case fireHazard
    case electricalHazard
    case none
}

protocol AssetNodeDelegate: AnyObject {
    func asset(_ assetNode: AssetNode, isNearElectricalHazard objectNode: ObjectNode)

    func asset(_ assetNode: AssetNode, isNearFireHazard objectNode: ObjectNode)

    func asset(_ assetNode: AssetNode, isWithinNeutralObject objectNode: ObjectNode?)

    func asset(_ assetNode: AssetNode, isOnGoodObject objectNode: ObjectNode?)

    func assetIsNotOnObject(_ assetNode: AssetNode)
}

class AssetNode {
    private(set) var asset: SCNNode
    private(set) var isOnSurface: Bool

    private var model: AssetModel
    private var goodBox: SCNNode
    private var neutralBox: SCNNode
    private var fireHazardBox: SCNNode
    private var electricalHazardBox: SCNNode

    weak var delegate: AssetNodeDelegate? = nil

    init(asset: SCNNode, model: AssetModel, transform: simd_float4x4) {
        self.asset = asset
        self.asset.simdTransform = transform
        self.isOnSurface = false

        self.model = model
        self.goodBox = SCNNode()
        self.neutralBox = SCNNode()
        self.fireHazardBox = SCNNode()
        self.electricalHazardBox = SCNNode()

        setup()
    }

    private func isPointOnTopOfCuboid(cuboid: SCNNode, matchTransform: simd_float4x4) -> Bool {
        let d = minimumDistanceFromTopOf(cuboid: cuboid, to: matchTransform)
        let thresholdDistance = Float(0.05)
        if d < thresholdDistance, isPointOnTopOf(cuboid: cuboid, point: matchTransform.translation()) {
            return true
        }
        return false
    }

    private func isPointNearOrInsideCuboid(cuboid: SCNNode, matchTransform: simd_float4x4) -> (Bool, Float) {
        let d = minimumDistanceFrom(cuboid: cuboid, to: matchTransform)
        let thresholdDistance = Float(0.25)
        if d < thresholdDistance {
            return (true, d)
        }
        return (false, d)
    }

    func update(with suggestedTransform: simd_float4x4?, defaultTransform: simd_float4x4, objectNodes: [ObjectNode]) {
        if let matchTransform = suggestedTransform {
            // raycast found an estimated plane to use
            var electricalHazard: ObjectNode? = nil
            var fireHazard: ObjectNode? = nil
            var neutralObject: ObjectNode? = nil
            var isOnTopOfObject = false

            for objectNode in objectNodes {
                // determine if raycast coincides with any room objects
                let box = objectNode.box

                let (isAssetNearObject, distanceToObject) = isPointNearOrInsideCuboid(cuboid: box, matchTransform: matchTransform)
                if isAssetNearObject {
                    // asset is near room object; determine if room object is a hazard
                    guard let category = objectNode.currentCategory else {
                        return
                    }
                    if model.electricalHazardCategories.contains(category) {
                        electricalHazard = objectNode
                        break
                    } else if model.fireHazardCategories.contains(category) {
                        fireHazard = objectNode
                        break
                    } else if model.neutralCategories.contains(category) && distanceToObject < Float(0.01) {
                        // asset is within this room object
                        neutralObject = objectNode
                        break
                    }
                }

                let isAssetOnTopOfObject = isPointOnTopOfCuboid(cuboid: box, matchTransform: matchTransform)
                if isAssetOnTopOfObject {
                    // asset is on top of room object; determine if placing on top of this room object is non-ideal (i.e., neutral)
                    guard let category = objectNode.currentCategory else {
                        return
                    }
                    isOnTopOfObject = true
                    if model.neutralCategories.contains(category) {
                        neutralObject = objectNode
                        break
                    }
                }
            }

            if electricalHazard != nil {
                updateAssetBoxStatus(status: .electricalHazard)
                delegate?.asset(self, isNearElectricalHazard: electricalHazard!)
            } else if fireHazard != nil {
                updateAssetBoxStatus(status: .fireHazard)
                delegate?.asset(self, isNearFireHazard: fireHazard!)
            } else if neutralObject != nil {
                updateAssetBoxStatus(status: .neutral)
                delegate?.asset(self, isWithinNeutralObject: neutralObject!)
            } else {
                if isOnTopOfObject {
                    // assume good
                    updateAssetBoxStatus(status: .good)
                    delegate?.asset(self, isOnGoodObject: nil)
                } else {
                    // probably on floor; if floor is okay, good; otherwise, neutral
                    if model.isFloorOkay {
                        updateAssetBoxStatus(status: .good)
                        delegate?.asset(self, isOnGoodObject: nil)
                    } else {
                        updateAssetBoxStatus(status: .neutral)
                        delegate?.asset(self, isWithinNeutralObject: nil)
                    }
                }
            }

            // place on top of found "plane"
            asset.simdTransform = matchTransform
            isOnSurface = true
        } else {
            updateAssetBoxStatus(status: .none)
            delegate?.assetIsNotOnObject(self)
            // place in front of camera
            asset.simdTransform = defaultTransform
            isOnSurface = false
        }
    }

    func updateAssetBoxStatus(status: AssetBoxStatus) {
        switch status {
        case .good:
            goodBox.opacity = 0.5
            neutralBox.opacity = 0.0
            fireHazardBox.opacity = 0.0
            electricalHazardBox.opacity = 0.0
        case .neutral:
            goodBox.opacity = 0.0
            neutralBox.opacity = 0.5
            fireHazardBox.opacity = 0.0
            electricalHazardBox.opacity = 0.0
        case .fireHazard:
            goodBox.opacity = 0.0
            neutralBox.opacity = 0.0
            fireHazardBox.opacity = 1.0
            electricalHazardBox.opacity = 0.0
        case .electricalHazard:
            goodBox.opacity = 0.0
            neutralBox.opacity = 0.0
            fireHazardBox.opacity = 0.0
            electricalHazardBox.opacity = 1.0
        case .none:
            goodBox.opacity = 0.0
            neutralBox.opacity = 0.0
            fireHazardBox.opacity = 0.0
            electricalHazardBox.opacity = 0.0
        }
    }

    func cleanup() {
        asset.removeFromParentNode()
    }

    private func setup() {
        setup(goodBox, for: asset, color: UIColor.green)
        setup(neutralBox, for: asset, color: UIColor.yellow)
        setup(fireHazardBox, for: asset, color: UIColor.red)
        setup(electricalHazardBox, for: asset, color: UIColor.blue)

        goodBox.opacity = 0.0
        neutralBox.opacity = 0.0
        fireHazardBox.opacity = 0.0
        electricalHazardBox.opacity = 0.0

        asset.addChildNode(goodBox)
        asset.addChildNode(neutralBox)
        asset.addChildNode(fireHazardBox)
        asset.addChildNode(electricalHazardBox)
    }

    private func setup(_ box: SCNNode, for object: SCNNode, color: UIColor) {
        let (minObject, maxObject) = object.boundingBox
        let dimensions = simd_float3(maxObject) - simd_float3(minObject)

        rp2.update(box, with: dimensions, color: color)

        let (minBox, _) = box.boundingBox
        let translation = simd_float3(minObject) - simd_float3(minBox)
        let translationTransform = simd_float4x4.translationTransform(translation)
        let scaleTransform = simd_float4x4.scaleTransform(simd_float3(1.08, 1.08, 1.08))
        box.simdTransform = translationTransform * scaleTransform
    }
}

struct AssetModel {
    var imageName: String
    var neutralCategories: [CapturedRoom.Object.Category]
    var fireHazardCategories: [CapturedRoom.Object.Category]
    var electricalHazardCategories: [CapturedRoom.Object.Category]
    var isFloorOkay: Bool
}
