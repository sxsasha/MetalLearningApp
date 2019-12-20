//
//  Camera.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/20/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import Foundation

class Camera: Node {
    var fovDegree: Float = 70 {
        didSet {
            computeProjectionMatrix()
        }
    }
    
    var near: Float = 0.1 {
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
