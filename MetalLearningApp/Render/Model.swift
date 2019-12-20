//
//  Model.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/20/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import MetalKit

class Model: Node {
    let mesh: MTKMesh
    let submeshes: [MTKSubmesh]
    let vertexBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    
    init(name: String,
         vertexDescriptor: MDLVertexDescriptor = VertexDescriptorManager.defaultVertexDescriptor,
         pipelineState: MTLRenderPipelineState = PipelineStateManager.defaultPipelineState) {
        
        guard let assetURL = Bundle.main.url(forResource: name, withExtension: "obj") else {
            fatalError()
        }
        
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: vertexDescriptor,
                             bufferAllocator: allocator)
        
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        // get mtkMesh from MDLMesh
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: Renderer.device)
        self.submeshes = mesh.submeshes
        self.vertexBuffer = mesh.vertexBuffers[0].buffer
        self.pipelineState = pipelineState
        
        super.init()
    }
}
