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
    let submeshes: [Submesh]
    let vertexBuffer: MTLBuffer
    let samplerState: MTLSamplerState?
    var tiling: UInt32 = 1
    
    init(name: String,
         vertexDescriptor: MDLVertexDescriptor = VertexDescriptorManager.normalVertexDescriptor) {
        guard let assetURL = Bundle.main.url(forResource: name, withExtension: "obj") else {
            fatalError()
        }
        
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: vertexDescriptor,
                             bufferAllocator: allocator)
        
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                tangentAttributeNamed: MDLVertexAttributeTangent,
                                bitangentAttributeNamed: MDLVertexAttributeBitangent)
        
        // get mtkMesh from MDLMesh
        let mesh = try! MTKMesh(mesh: mdlMesh, device: Renderer.device)
        self.mesh = mesh
        self.vertexBuffer = mesh.vertexBuffers[0].buffer
        self.submeshes = mdlMesh.submeshes?.enumerated().compactMap({ index, submesh in
            if let submesh = submesh as? MDLSubmesh {
                return Submesh(submesh: mesh.submeshes[index],
                               mdlSubmesh: submesh)} else {
                return nil
            }
        }) ?? []
        
        self.samplerState = SamplerStateManager.buildRepeatSamplerState
            
        super.init()
        self.name = name
    }
}
