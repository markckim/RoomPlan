//
//  SCNNode+Extra.swift
//  rp2
//
//  Created by Mark Kim on 6/16/22.
//

import RoomPlan
import SceneKit

func update(_ label: SCNNode, with color: UIColor) {
    guard let textGeometry = label.geometry else {
        print("error: no textGeometry found for label")
        return
    }
    textGeometry.firstMaterial!.diffuse.contents = color
}

func update(_ label: SCNNode, with text: String, color: UIColor) {
    let textGeometry = SCNText(string: text, extrusionDepth: 0.0)
    textGeometry.font = UIFont(name: themeFont, size: 20)
    textGeometry.firstMaterial!.diffuse.contents = color
    label.geometry = textGeometry

    // adjust label pivot
    let (minVec, maxVec) = label.boundingBox
    let (simdMinVec, simdMaxVec) = (simd_float3(minVec), simd_float3(maxVec))
    let adjustedPivot = simdMinVec + 0.5 * (simdMaxVec - simdMinVec)
    label.simdPivot = simd_float4x4.translationTransform(adjustedPivot)
}

func update(_ box: SCNNode, with dimensions: simd_float3, color: UIColor = UIColor.white, category: CapturedRoom.Object.Category? = nil) {
    let width = CGFloat(dimensions.x)
    let height = CGFloat(dimensions.y)
    let length = CGFloat(dimensions.z)
    let boxColor = category != nil ? rp2.color(for: category!) : color
    let boxGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
    boxGeometry.firstMaterial?.diffuse.contents = boxColor
    boxGeometry.firstMaterial?.transparency = 0.35

    box.geometry = boxGeometry
}

func planeDimensionsFor(textNode: SCNNode) -> (CGFloat, CGFloat) {
    let (minTextNode, maxTextNode) = textNode.boundingBox
    let textNodeWidth = CGFloat(maxTextNode.x - minTextNode.x)
    let textNodeHeight = CGFloat(maxTextNode.y - minTextNode.y)
    let inset = 0.3 * textNodeHeight
    let planeWidth = 7.0 * inset + textNodeWidth
    let planeHeight = 3.0 * inset + textNodeHeight

    return (planeWidth, planeHeight)
}

func update(_ planeNode: SCNNode, width: CGFloat, height: CGFloat, color: UIColor) {
    let plane = SCNPlane(width: width, height: height)
    plane.cornerRadius = 0.4 * height
    plane.materials.first?.diffuse.contents = color
    plane.materials.first?.metalness.contents = 0.5
    plane.materials.first?.roughness.contents = 0.1
    planeNode.geometry = plane
}
