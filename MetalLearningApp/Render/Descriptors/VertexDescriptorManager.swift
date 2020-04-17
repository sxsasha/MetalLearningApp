//
//  VertexDescriptorManager.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/20/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import MetalKit

class VertexDescriptorManager {
    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[Int(Position.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0,
                                                            bufferIndex: 0)
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        
        return vertexDescriptor
    }()
    
    static var normalVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[Int(Position.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                                                 format: .float3,
                                                                                 offset: 0,
                                                                                 bufferIndex: 0)
        
        vertexDescriptor.attributes[Int(Normal.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                                               format: .float3,
                                                                               offset: 12,
                                                                               bufferIndex: 0)
        
        vertexDescriptor.attributes[Int(UV.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                                           format: .float2,
                                                                           offset: 24,
                                                                           bufferIndex: 0)
        
        vertexDescriptor.attributes[Int(Tangent.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeTangent,
                                                                                format: .float3,
                                                                                offset: 0,
                                                                                bufferIndex: 1)
        
        vertexDescriptor.attributes[Int(Bitangent.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeBitangent,
                                                                                format: .float3,
                                                                                offset: 0,
                                                                                bufferIndex: 2)
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 32)
        vertexDescriptor.layouts[1] = MDLVertexBufferLayout(stride: 12)
        vertexDescriptor.layouts[2] = MDLVertexBufferLayout(stride: 12)
        
        return vertexDescriptor
    }()
}
