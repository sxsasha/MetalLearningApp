//
//  Submesh.swift
//  MetalLearningApp
//
//  Created by sxsasha on 1/17/20.
//  Copyright © 2020 sxsasha. All rights reserved.
//

import MetalKit

class Submesh {
    let submesh: MTKSubmesh
    let textures: Textures
    let pipelineState: MTLRenderPipelineState!
    
    struct Textures {
        let baseColor: MTLTexture?
        let normal: MTLTexture?
    }
    
    init(submesh: MTKSubmesh, mdlSubmesh: MDLSubmesh) {
        self.submesh = submesh
        self.textures = Textures(material: mdlSubmesh.material)
        pipelineState = PipelineStateManager.makePipelineState()
    }
}

extension Submesh: Texturable {
    
}

private extension Submesh.Textures {
    init(material: MDLMaterial?) {
        func property(with semantic: MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic),
                property.type == .string,
                let filename = property.stringValue,
                let texture = try? Submesh.loadTexture(imageName: filename) else {
                    return nil
            }
            
            return texture
        }
        
        baseColor = property(with: .baseColor)
        normal = property(with: .tangentSpaceNormal)
    }
}
