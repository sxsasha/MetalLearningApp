//
//  Node.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/20/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import Foundation

class Node {
    var name: String = "untitled"
    var position: SIMD3<Float> = .zero
    var scale: SIMD3<Float> = .one
    var rotation: SIMD3<Float> = .zero
    
    var modelMatrix: float4x4 {
        return float4x4(translation: position) * float4x4(rotation: rotation) * float4x4(scaling: scale)
    }
    
}
