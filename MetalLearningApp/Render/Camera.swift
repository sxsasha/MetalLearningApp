//
//  Camera.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/20/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import UIKit

class Camera: Node {
    var fovDegree: Float = 70 {
        didSet {
            computeProjectionMatrix()
        }
    }
    
    var near: Float = 0.001 {
        didSet {
            computeProjectionMatrix()
        }
    }
    
    var far: Float = 100.0 {
        didSet {
            computeProjectionMatrix()
        }
    }
    
    var aspect: Float = 1.0 {
        didSet {
            computeProjectionMatrix()
        }
    }
    
    var projectionMatrix: float4x4 = .identity

    private func computeProjectionMatrix() {
        projectionMatrix = float4x4(projectionFov: radians(fromDegrees: fovDegree),
                                    near: near,
                                    far: far,
                                    aspect: aspect)
    }
    
    var viewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
}

extension Camera {
    func zoomUsing(delta: CGFloat, sensitivity: Float) {
        let cameraVector = modelMatrix.upperLeft().columns.2
        
        position += Float(delta) * sensitivity * cameraVector
    }
    
    func rotateUsing(translation: SIMD2<Float>) {
        let sensitivity: Float = 0.01
        
        position = float4x4(rotationY: translation.x * sensitivity).upperLeft() * position
        rotation.y = atan2f(-position.x, -position.z)
    }
}
