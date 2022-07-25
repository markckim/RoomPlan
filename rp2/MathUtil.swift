//
//  MathUtil.swift
//  rp2
//
//  Created by Mark Kim on 6/16/22.
//

import Foundation

import ARKit

extension simd_float4x4 {
    func translation() -> simd_float3 {
        return simd_float3(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }

    func quaternion() -> simd_quatf {
      return simd_quatf(self)
    }

    func unitRightVector() -> simd_float3 {
        let vector = simd_float3(columns.0.x, columns.0.y, columns.0.z)
        return simd_normalize(vector)
    }

    func unitLeftVector() -> simd_float3 {
        let vector = unitRightVector()
        return -1.0 * vector
    }

    func unitUpVector() -> simd_float3 {
        let vector = simd_float3(columns.1.x, columns.1.y, columns.1.z)
        return simd_normalize(vector)
    }

    func unitDownVector() -> simd_float3 {
        let vector = unitUpVector()
        return -1.0 * vector
    }

    func unitForwardVector() -> simd_float3 {
        let vector = simd_float3(columns.2.x, columns.2.y, columns.2.z)
        return simd_normalize(vector)
    }

    func unitBackVector() -> simd_float3 {
        let vector = unitForwardVector()
        return -1.0 * vector
    }

    static func translationTransform(_ translation: simd_float3) -> simd_float4x4 {
        let x: Float = translation.x
        let y: Float = translation.y
        let z: Float = translation.z
        return simd_float4x4(
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(x, y, z, 1)
        )
    }

    static func shearTransformYZ(_ yz: Float) -> simd_float4x4 {
        return shearTransform(yz: yz)
    }

    static func shearTransformYX(_ yx: Float) -> simd_float4x4 {
        return shearTransform(yx: yx)
    }

    static func shearTransform(xy: Float = 0, xz: Float = 0, yz: Float = 0, yx: Float = 0, zx: Float = 0, zy: Float = 0) -> simd_float4x4 {
        return simd_float4x4(
            simd_float4(1,  yx, zx, 0),
            simd_float4(xy, 1,  zy, 0),
            simd_float4(xz, yz, 1,  0),
            simd_float4(0,  0,  0,  1)
        )
    }

    static func scaleTransform(_ scale: simd_float3) -> simd_float4x4 {
        return simd_float4x4(
            simd_float4(scale.x,    0,          0,          0),
            simd_float4(0,          scale.y,    0,          0),
            simd_float4(0,          0,          scale.z,    0),
            simd_float4(0,          0,          0,          1)
        )
    }

    static func rotationTransformX(_ radians: Float) -> simd_float4x4 {
        return simd_float4x4(
            simd_float4(1,              0,              0,              0),
            simd_float4(0,              cos(radians),   sin(radians),   0),
            simd_float4(0,              -sin(radians),  cos(radians),   0),
            simd_float4(0,              0,              0,              1))
    }

    static func rotationTransformY(_ radians: Float) -> simd_float4x4 {
        return simd_float4x4(
            simd_float4(cos(radians),   0,              -sin(radians),  0),
            simd_float4(0,              1,              0,              0),
            simd_float4(sin(radians),   0,              cos(radians),   0),
            simd_float4(0,              0,              0,              1))
    }

    static func rotationTransformZ(_ radians: Float) -> simd_float4x4 {
        return simd_float4x4(
            simd_float4(cos(radians),   sin(radians),   0,              0),
            simd_float4(-sin(radians),  cos(radians),   0,              0),
            simd_float4(0,              0,              1,              0),
            simd_float4(0,              0,              0,              1)
        )
    }

    static func rotationTransform(_ radians: simd_float3) -> simd_float4x4 {
        return rotationTransformX(radians.x) * rotationTransformY(radians.y) * rotationTransformZ(radians.z)
    }
}

extension simd_float3 {
    var length: Float {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    }

    var lengthSquared: Float {
        return self.x * self.x + self.y * self.y + self.z * self.z
    }
}

// note: if distance returnd is 0, that means point is inside the cuboid
func minimumDistanceFrom(cuboid: SCNNode, to matchTransform: simd_float4x4) -> Float {
    let cuboidTransform = cuboid.simdTransform
    let adjustedMatchTransform = cuboidTransform.inverse * matchTransform
    let axisAlignedPoint = adjustedMatchTransform.translation()
    let (minBox, maxBox) = cuboid.boundingBox
    let dX = 0.5 * (maxBox.x - minBox.x)
    let dY = 0.5 * (maxBox.y - minBox.y)
    let dZ = 0.5 * (maxBox.z - minBox.z)

    let dSquared = powf(max(0, abs(axisAlignedPoint.x) - dX), 2) + powf(max(0, abs(axisAlignedPoint.y) - dY), 2) + powf(max(0, abs(axisAlignedPoint.z) - dZ), 2)
    let d = sqrtf(dSquared)

    return d
}

func minimumDistanceFromTopOf(cuboid: SCNNode, to matchTransform: simd_float4x4) -> Float {
    let unitUpVector = cuboid.simdTransform.unitUpVector()
    let unitForwardVector = cuboid.simdTransform.unitForwardVector()
    let unitRightVector = cuboid.simdTransform.unitRightVector()
    let boxTranslation = cuboid.simdTransform.translation()
    let (minBox, maxBox) = cuboid.boundingBox

    let dVectorY = 0.5 * (maxBox.y - minBox.y) * unitUpVector
    let q = boxTranslation + dVectorY
    let p = matchTransform.translation()

    let v = p - q
    let N = simd_cross(unitForwardVector, unitRightVector)
    let n = N / N.length
    let d = abs(dot(v, n))

    return d
}

func isPointOnTopOf(cuboid: SCNNode, point p: simd_float3) -> Bool {
    let unitUpVector = cuboid.simdTransform.unitUpVector()
    let unitForwardVector = cuboid.simdTransform.unitForwardVector()
    let unitRightVector = cuboid.simdTransform.unitRightVector()
    let boxTranslation = cuboid.simdTransform.translation()
    let (minBox, maxBox) = cuboid.boundingBox

    let dVectorX = 0.5 * (maxBox.x - minBox.x) * unitRightVector
    let dVectorY = 0.5 * (maxBox.y - minBox.y) * unitUpVector
    let dVectorZ = 0.5 * (maxBox.z - minBox.z) * unitForwardVector

    let q = boxTranslation + dVectorY

    // vertices of a square
    let a = q - dVectorX + dVectorZ
    let b = q - dVectorX - dVectorZ
    let d = q + dVectorX + dVectorZ

    // vectors based on vertices of the square
    let ap = p - a
    let ab = b - a
    let ad = d - a

    let apAB = dot(ap, ab)
    let apAD = dot(ap, ad)

    if 0 < apAB, apAB < dot(ab, ab), 0 < apAD, apAD < dot(ad, ad) {
        // point p is within the cuboid top
        return true
    }
    return false
}
