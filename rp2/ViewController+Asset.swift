//
//  ViewController+Asset.swift
//  rp2
//
//  Created by Mark Kim on 6/17/22.
//

import ARKit
import SceneKit.ModelIO
import UIKit

// MARK: - Asset Managemet

extension ViewController {
    func createAssetView() -> UIView {
        let labelHeight = 24.0
        let buttonLength = 36.0
        let horizontalSpace = 32.0
        let verticalSpace = 8.0

        let viewHeight = buttonLength + 3.0 * verticalSpace + labelHeight
        let viewWidth = 3.0 * buttonLength + 4.0 * horizontalSpace
        let viewFrame = CGRectMake(0, 0, viewWidth, viewHeight)
        let assetView = UIVisualEffectView(frame: viewFrame)
        assetView.backgroundColor = .systemBackground
        assetView.alpha = 0.5
        assetView.layer.cornerRadius = 0.25 * viewHeight
        assetView.layer.masksToBounds = true

        // add label
        let label = UILabel(frame: CGRectMake(0, verticalSpace, viewWidth, labelHeight))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "Long press to bring into scene"
        assetView.contentView.addSubview(label)

        var xOffset = horizontalSpace
        let yOffset = verticalSpace + labelHeight + verticalSpace

        for (idx, imageName) in imageNames.enumerated() {
            let button = UIButton(type: .custom)
            button.contentMode = .scaleAspectFit
            if let image = UIImage(named: imageName) {
                button.setImage(image, for: .normal)
            }
            button.tag = idx
            button.frame = CGRectMake(xOffset, yOffset, buttonLength, buttonLength)
            let gestureReognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.didLongPressButton(with:)))
            button.addGestureRecognizer(gestureReognizer)

            imageButtons.append(button)
            assetView.contentView.addSubview(button)

            xOffset += buttonLength + horizontalSpace
        }

        return assetView
    }

    func setupUSDZAssets(_ completion: USDZCompletionHandler? = nil) {
        DispatchQueue.global(qos: .background).async {
            var usdzNodes = [String: SCNNode]()
            let usdzFileNames = ["toy", "toaster", "tricycle", "painting"]
            for usdzFileName in usdzFileNames {
                guard let url = Bundle.main.url(forResource: usdzFileName, withExtension: "usdz") else {
                    print("ERROR: USDZ url issue with \(usdzFileName)")
                    continue
                }

                let asset = MDLAsset(url: url)
                asset.loadTextures()

                let scene = SCNScene(mdlAsset: asset)
                guard let node = scene.rootNode.childNode(withName: usdzFileName, recursively: false) else {
                    continue
                }
                usdzNodes[usdzFileName] = node
            }

            self.usdzNodes = usdzNodes

            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    func setupAssetView() {
        let viewBounds = view.bounds
        let assetViewBounds = assetView.bounds

        let beforeAssetViewFrame = CGRectMake(0.5 * (viewBounds.width - assetViewBounds.width),
                                              viewBounds.maxY,
                                              assetViewBounds.width,
                                              assetViewBounds.height)

        let afterAssetViewFrame = CGRectMake(0.5 * (viewBounds.width - assetViewBounds.width),
                                             viewBounds.maxY - view.safeAreaInsets.bottom - assetViewBounds.height - 48.0,
                                             assetViewBounds.width,
                                             assetViewBounds.height)

        var afterButtonFrames = [CGRect]()
        for imageButton in imageButtons {
            afterButtonFrames.append(imageButton.frame)
            let middleFrame = CGRectMake(0.5 * (assetViewBounds.width - imageButton.bounds.width),
                                         0.5 * (assetViewBounds.height - imageButton.bounds.height),
                                         imageButton.bounds.width,
                                         imageButton.bounds.height)
            imageButton.frame = middleFrame
        }

        guard let infoView = infoView else {
            return
        }
        view.insertSubview(assetView, belowSubview: infoView)

        assetView.frame = beforeAssetViewFrame
        assetView.alpha = 0.0

        UIView.animate(withDuration: 0.75) {
            self.assetView.frame = afterAssetViewFrame
            self.assetView.alpha = 0.8
            for (idx, imageButton) in self.imageButtons.enumerated() {
                imageButton.frame = afterButtonFrames[idx]
            }
        }
    }

    @objc func didLongPressButton(with gestureRecognizer: UILongPressGestureRecognizer) {
        let touchLocation = gestureRecognizer.location(in: sceneView)

        switch gestureRecognizer.state {
        case .possible:
            break
        case .began:
            if selectedAssetNode == nil {
                // should be a UILongPressGestureRecognizer
                guard let button = gestureRecognizer.view as? UIButton
                else {
                    return
                }
                let tag = button.tag
                let imageName = imageNames[tag]
                guard let asset = clonedNode(with: imageName),
                      let model = assetModels[imageName]
                else {
                    return
                }
                let assetNode = AssetNode(asset: asset, model: model, transform: nodeTransform(with: touchLocation))
                sceneView.scene.rootNode.addChildNode(assetNode.asset)
                selectedAssetNode = assetNode
                selectedAssetNode?.delegate = self
            }
            break
        case .changed:
            guard let selectedAssetNode = selectedAssetNode else {
                return
            }
            // raycast
            let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal)
            guard let query = query else {
                return
            }
            var matchTransform: simd_float4x4? = nil
            let rayResults = sceneView.session.raycast(query)
            if let rayResult = rayResults.first {
                matchTransform = rayResult.worldTransform
            }

            selectedAssetNode.update(with: matchTransform, defaultTransform: nodeTransform(with: touchLocation), objectNodes: Array(objectNodes.values))
            break
        case .ended:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
            fallthrough
        @unknown default:
            guard let selectedAssetNode = selectedAssetNode else {
                return
            }
            if selectedAssetNode.isOnSurface {
                selectedAssetNode.updateAssetBoxStatus(status: .none)
                placedAssetNodes.append(selectedAssetNode)
            } else {
                selectedAssetNode.cleanup()
            }
            self.selectedAssetNode = nil
            self.highlightedObjectNode?.box.opacity = 0.0
            self.highlightedObjectNode = nil
            self.statusMessage = ""
            break
        }
    }

    private func clonedNode(with imageName: String) -> SCNNode? {
        guard let nodeToClone = usdzNodes[imageName]
        else {
            return nil
        }

        let node = nodeToClone.clone()
        return node
    }

    func nodeTransform(with touchLocation: CGPoint) -> simd_float4x4 {
        guard let currentFrame = sceneView.session.currentFrame,
              let pointOfView = sceneView.pointOfView
        else {
            return matrix_identity_float4x4
        }

        let viewSize = sceneView.bounds.size
        let projection = currentFrame.camera.projectionMatrix(for: .portrait, viewportSize: viewSize, zNear: 0.5, zFar: 1.0)
        let xScale = projection[0,0]
        let yScale = projection[1,1] // = 1/tan(fovy/2)
        let yFovRadians = 2 * atan(1/yScale)
        let xFovRadians = yFovRadians * Float(viewSize.height / viewSize.width)

        let touchFloat = simd_float2(Float(touchLocation.x), Float(touchLocation.y))
        let viewSizeFloat = simd_float2(Float(viewSize.width), Float(viewSize.height))

        // TODO: - something about this math is wrong or i'm not understanding something; fix, if possible
        // i had to divide xMax by xScale, and multiply xMax by zFactor to get things looking okay
        let dZ = Float(-1)
        let zFactor = abs(dZ) / xScale

        let xMax = zFactor * (tanf(0.5 * xFovRadians) / xScale)
        let yMax = xMax * viewSizeFloat.y / viewSizeFloat.x
        //let zFactor2 = abs(dZ) / yScale
        //let yMax = zFactor2 * (tanf(0.5 * yFovRadians) / yScale)

        let dX = xMax * (touchFloat.x - 0.5 * viewSizeFloat.x) / (0.5 * viewSizeFloat.x)
        let dY = yMax * (0.5 * viewSizeFloat.y - touchFloat.y) / (0.5 * viewSizeFloat.y)

        let rightVector = pointOfView.simdTransform.unitRightVector()
        let upVector = pointOfView.simdTransform.unitUpVector()
        let forwardVector = pointOfView.simdTransform.unitForwardVector()

        let dImagePos = dX * rightVector + dY * upVector + dZ * forwardVector
        let translationTransform = simd_float4x4.translationTransform(dImagePos)

        let finalTransform = translationTransform * pointOfView.simdTransform

        return finalTransform
    }
}

// MARK: - AssetNodeDelegate

extension ViewController {
    func asset(_ assetNode: AssetNode, isNearElectricalHazard objectNode: ObjectNode) {
        highlightedObjectNode?.box.opacity = 0.0

        statusMessage = "Warning: Object near electrical hazard"
        highlightedObjectNode = objectNode
        highlightedObjectNode?.box.opacity = 1.0
    }

    func asset(_ assetNode: AssetNode, isNearFireHazard objectNode: ObjectNode) {
        highlightedObjectNode?.box.opacity = 0.0

        statusMessage = "Warning: Object near fire hazard"
        highlightedObjectNode = objectNode
        highlightedObjectNode?.box.opacity = 1.0
    }

    func asset(_ assetNode: AssetNode, isWithinNeutralObject objectNode: ObjectNode?) {
        highlightedObjectNode?.box.opacity = 0.0

        statusMessage = "Message: Object on non-ideal surface"
    }

    func asset(_ assetNode: AssetNode, isOnGoodObject objectNode: ObjectNode?) {
        highlightedObjectNode?.box.opacity = 0.0

        statusMessage = "Message: Great object placement"
    }

    func assetIsNotOnObject(_ assetNode: AssetNode) {
        highlightedObjectNode?.box.opacity = 0.0

        statusMessage = "Message: Place object"
    }
}
