//
//  Light+Extension.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/23/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import Foundation

extension Light {
    init(type: LightType = Sunlight,
         position: SIMD3<Float> = .zero,
         color: SIMD3<Float> = .one,
         specularColor: SIMD3<Float> = [0.6, 0.6, 0.6],
         intensity: Float = 1.0,
         attenuation: SIMD3<Float> = [1, 0, 0],
         coneAngle: Float = 1.0,
         coneDirection: SIMD3<Float> = [1, 0, 0],
         coneAttenuation: Float = 1.0) {
        self.init()
        
        self.position = position
        self.color = color
        self.specularColor = specularColor
        self.intensity = intensity
        self.attenuation = attenuation
        self.coneAngle = coneAngle
        self.coneDirection = coneDirection
        self.coneAttenuation = coneAttenuation
        self.type = type
    }
}
