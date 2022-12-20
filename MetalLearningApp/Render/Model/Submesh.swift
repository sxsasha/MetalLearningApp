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
    let material: Material
    
    struct Textures {
        let baseColor: MTLTexture?
        let normal: MTLTexture?
        let roughness: MTLTexture?
    }
    
    init(submesh: MTKSubmesh, mdlSubmesh: MDLSubmesh) {
        self.submesh = submesh
        
        textures = Textures(material: mdlSubmesh.material)
        material = Material(material: mdlSubmesh.material)
        pipelineState = Submesh.makePipelineState(textures: textures)
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
        roughness = property(with: .roughness)
    }
}

private extension Material {
    init(material: MDLMaterial?) {
        self.init()
        if let baseColor = material?.property(with: .baseColor) {
            self.baseColor = baseColor.float3Value
        }
    
        if let specular = material?.property(with: .specular) {
            self.specularColor = specular.float3Value
        }
        
        if let shininess = material?.property(with: .specularExponent) {
            self.shininess = shininess.floatValue
        }
        
        if let roughness = material?.property(with: .roughness), roughness.type == .float3 {
            self.roughness = roughness.floatValue
        }
    }
}

extension Submesh {
    static func makeFunctionConstants(textures: Textures) -> MTLFunctionConstantValues {
        let functionConstants = MTLFunctionConstantValues()
        
        var property = textures.baseColor != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 0)
        
        property = textures.normal != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 1)

        property = textures.roughness != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 2)
        property = false
        functionConstants.setConstantValue(&property, type: .bool, index: 3)
        functionConstants.setConstantValue(&property, type: .bool, index: 4)
        
        return functionConstants
    }
    
    static func makePipelineState(textures: Textures) -> MTLRenderPipelineState {
        let functionConstants = makeFunctionConstants(textures: textures)
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_main")
        
        let fragmentFunction: MTLFunction?
        do {
            fragmentFunction = try Renderer.library?.makeFunction(name: "fragment_mainPBR",
                                                                  constantValues: functionConstants)
        } catch {
            fatalError("No Metal function exists")
        }
        
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

