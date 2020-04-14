//
//  SamplerState.swift
//  MetalLearningApp
//
//  Created by sxsasha on 1/17/20.
//  Copyright © 2020 sxsasha. All rights reserved.
//

import MetalKit

class SamplerStateManager {
    static var buildRepeatSamplerState: MTLSamplerState? = {
        let descriptor = MTLSamplerDescriptor()
        descriptor.sAddressMode = .repeat
        descriptor.tAddressMode = .repeat
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        descriptor.mipFilter = .linear
        descriptor.maxAnisotropy = 8
        let samplerState = Renderer.device.makeSamplerState(descriptor: descriptor)
        
        return samplerState
    }()
}
