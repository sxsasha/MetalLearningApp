//
//  PipelineManager.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/20/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import MetalKit

class PipelineStateManager {
    static func makePipelineState() -> MTLRenderPipelineState {
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(VertexDescriptorManager.normalVertexDescriptor)
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            return try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
