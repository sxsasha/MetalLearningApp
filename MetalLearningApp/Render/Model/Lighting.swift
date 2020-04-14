//
//  Lighting.swift
//  MetalLearningApp
//
//  Created by sxsasha on 15.04.2020.
//  Copyright © 2020 sxsasha. All rights reserved.
//

import MetalKit

extension Renderer {
    func lighting() -> [Light] {
        return [Light(type: Sunlight, position: [-1.0, 0.5, -2.0], intensity: 2.0),
                Light(type: Sunlight, position: [0.0, 1.0, 2.0], intensity: 0.2),
                Light(type: Ambientlight, intensity: 0.2),
                Light(type: Pointlight,
                      position: [-0, 0.5, -0.5],
                      color: [1, 0, 0],
                      attenuation: [1, 3, 4]),
                Light(type: Spotlight,
                      position: [0.4, 0.8, 1],
                      color: [1, 0, 1],
                      attenuation: [1, 0.5, 0],
                      coneAngle: radians(fromDegrees: 40),
                      coneDirection: [-2, 0, -1.5],
                      coneAttenuation: 12)]
    }
}
