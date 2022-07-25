//
//  ViewController+Picker.swift
//  rp2
//
//  Created by Mark Kim on 6/17/22.
//

import ARKit
import UIKit

extension ViewController {
    // (top left screen point, bottom right screen point)
    private func screenPoints(for node: SCNNode) -> (SCNVector3, SCNVector3) {
        let (minLabel, maxLabel) = node.boundingBox
        let labelScale = node.simdScale

        let dx = 0.5 * (maxLabel.x - minLabel.x) * labelScale.x
        let dy = 0.5 * (maxLabel.y - minLabel.y) * labelScale.y
        let topLeftX = node.simdPosition.x - dx
        let topLeftY = node.simdPosition.y + dy
        let topLeftZ = node.simdPosition.z
        let bottomRightX = node.simdPosition.x + dx
        let bottomRightY = node.simdPosition.y - dy
        let bottomRightZ = node.simdPosition.z

        let topLeftVector = SCNVector3(topLeftX, topLeftY, topLeftZ)
        let bottomRightVector = SCNVector3(bottomRightX, bottomRightY, bottomRightZ)

        let topLeftScreenPoint = sceneView.projectPoint(topLeftVector)
        let bottomRightScreenPoint = sceneView.projectPoint(bottomRightVector)

        return (topLeftScreenPoint, bottomRightScreenPoint)
    }

    // TODO: - refactor
    func showInfoView(with objectNode: ObjectNode) {
        guard let infoView = infoView,
              let objectModel = objectNode.model,
              let currentPickerRow = infoView.pickerData.firstIndex(of: objectNode.currentLabelText)
        else {
            print("infoView is nil")
            return
        }

        isInfoViewActive = true

        infoView.setCurrentPickerRow(currentPickerRow)
        let width = CGFloat(objectModel.dimensions.x)
        let height = CGFloat(objectModel.dimensions.y)
        let length = CGFloat(objectModel.dimensions.z)
        infoView.updateDimensions(width: width, height: height, length: length)

        let screenPoints = screenPoints(for: objectNode.label)
        let topLeftScreenPoint = screenPoints.0
        let bottomRightScreenPoint = screenPoints.1

        let infoViewApparentWidth = CGFloat(bottomRightScreenPoint.x - topLeftScreenPoint.x)
        let infoViewApparentHeight = CGFloat(bottomRightScreenPoint.y - topLeftScreenPoint.y)
        let infoViewCenter = CGPointMake(CGFloat(topLeftScreenPoint.x) + 0.5 * infoViewApparentWidth, CGFloat(topLeftScreenPoint.y) + 0.5 * infoViewApparentHeight)

        let infoViewWidth = infoView.bounds.width
        let infoViewHeight = infoView.bounds.height
        let infoViewApparentScaleX = infoViewApparentWidth / infoViewWidth
        let infoViewApparentScaleY = infoViewApparentHeight / infoViewHeight

        infoView.center = infoViewCenter

        let originalCenter = infoView.center
        let originalFrame = infoView.frame
        infoView.alpha = 0.1
        infoView.transform = CGAffineTransform(scaleX: infoViewApparentScaleX, y: infoViewApparentScaleY)

        let animationOptions: UIView.AnimationOptions = .curveEaseInOut
        let keyframeAnimationOptions = UIView.KeyframeAnimationOptions(rawValue: animationOptions.rawValue)
        UIView.animateKeyframes(withDuration: infoViewAnimationDuration, delay: 0.0, options: keyframeAnimationOptions) {
            let x0 = originalCenter.x
            let y0 = originalCenter.y
            let x1 = 0.5 * self.view.bounds.width
            let y1 = self.view.bounds.height - 0.5 * originalFrame.height
            let dx = x1 - x0
            let dy = y1 - y0

            let translation = CGAffineTransform(translationX: dx, y: dy)
            let scale = CGAffineTransform(scaleX: 1, y: 1)
            let combinedTransform = scale.concatenating(translation)

            infoView.transform = combinedTransform
            infoView.alpha = 1
        }
    }

    // TODO: - refactor
    func hideInfoView() {
        guard let selectedObjectNode = selectedObjectNode,
              let infoView = infoView
        else {
            return
        }

        let infoViewOldCenter = infoView.center

        let screenPoints = screenPoints(for: selectedObjectNode.label)
        let topLeftScreenPoint = screenPoints.0
        let bottomRightScreenPoint = screenPoints.1

        let infoViewApparentWidth = CGFloat(bottomRightScreenPoint.x - topLeftScreenPoint.x)
        let infoViewApparentHeight = CGFloat(bottomRightScreenPoint.y - topLeftScreenPoint.y)
        let infoViewNewCenter = CGPointMake(CGFloat(topLeftScreenPoint.x) + 0.5 * infoViewApparentWidth, CGFloat(topLeftScreenPoint.y) + 0.5 * infoViewApparentHeight)

        let infoViewWidth = infoView.bounds.width
        let infoViewHeight = infoView.bounds.height
        let infoViewApparentScaleX = infoViewApparentWidth / infoViewWidth
        let infoViewApparentScaleY = infoViewApparentHeight / infoViewHeight

        let animationOptions: UIView.AnimationOptions = .curveEaseInOut
        let keyframeAnimationOptions = UIView.KeyframeAnimationOptions(rawValue: animationOptions.rawValue)
        UIView.animateKeyframes(withDuration: infoViewAnimationDuration, delay: 0.0, options: keyframeAnimationOptions) {
            let x0 = infoViewOldCenter.x
            let y0 = infoViewOldCenter.y
            let x1 = infoViewNewCenter.x
            let y1 = infoViewNewCenter.y
            let dx = x1 - x0
            let dy = y1 - y0

            let translation = CGAffineTransform(translationX: dx, y: dy)
            let scale = CGAffineTransform(scaleX: infoViewApparentScaleX, y: infoViewApparentScaleY)
            let combinedTransform = scale.concatenating(translation)

            infoView.transform = combinedTransform
            infoView.alpha = 0
        } completion: { success in
            infoView.transform = CGAffineTransformIdentity
            self.isInfoViewActive = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + infoViewAnimationDuration - 0.1) {
            selectedObjectNode.stopEditingLabel()
            self.selectedObjectNode = nil
        }
    }
}
