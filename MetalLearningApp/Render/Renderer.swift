//
//  Renderer.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/4/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice = MTLCreateSystemDefaultDevice()!
    static var library: MTLLibrary? = device.makeDefaultLibrary()
    
    private var depthStencilState: MTLDepthStencilState
    private var commandQueue: MTLCommandQueue
    var colorPixelFormat: MTLPixelFormat
    var uniforms = Uniforms()
    private var fragmentUniforms = FragmentUniforms()
    
    var camera = Camera()
    var models: [Model] = []
    var lights: [Light] = [] {
        didSet {
            fragmentUniforms.lightCount = UInt32(lights.count)
        }
    }
    
    // Debug drawing of lights
    lazy var lightPipelineState: MTLRenderPipelineState = {
      return buildLightPipelineState()
    }()
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else {
          fatalError("GPU not available")
        }
        
        Renderer.device = device
        metalView.device = device
        metalView.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
        metalView.depthStencilPixelFormat = .depth32Float
        self.colorPixelFormat = metalView.colorPixelFormat
        
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create a command queue")
        }
        
        self.commandQueue = commandQueue
        
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        self.depthStencilState = Renderer.device.makeDepthStencilState(descriptor: descriptor)!
        
        super.init()
        
        metalView.delegate = self
        camera.aspect = Float(metalView.bounds.size.width / metalView.bounds.size.height)
        lights = lighting()
        fragmentUniforms.lightCount = UInt32(lights.count)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(size.width / size.height)
    }
    
    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        fragmentUniforms.cameraPosition = camera.position
        
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setFragmentBytes(&lights,
                                       length: MemoryLayout<Light>.stride * lights.count,
                                       index: Int(LightsIndex.rawValue))
        
        for model in models {
            // set model and normal matrix to uniforms
            uniforms.modelMatrix = model.modelMatrix
            uniforms.normalMatrix = float3x3(normalFrom4x4: model.modelMatrix)
            fragmentUniforms.tiling = model.tiling
            
            // set uniforms to vertex shader
            renderEncoder.setVertexBytes(&uniforms,
                                         length: MemoryLayout<Uniforms>.stride,
                                         index: Int(UniformsIndex.rawValue))
            renderEncoder.setFragmentBytes(&fragmentUniforms,
                                           length: MemoryLayout<FragmentUniforms>.stride,
                                           index: Int(FragmentUniformsIndex.rawValue))
            
            // set fragment sampler
            renderEncoder.setFragmentSamplerState(model.samplerState, index: 0)
            
            // set vertex buffer to vertex shader
            for (index, vertexBuffer) in model.mesh.vertexBuffers.enumerated() {
                renderEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: index)
            }
            
            for modelSubmesh in model.submeshes {
                // set pipeline state
                renderEncoder.setRenderPipelineState(modelSubmesh.pipelineState)
                
                // set textures
                renderEncoder.setFragmentTexture(modelSubmesh.textures.baseColor,
                                                 index: Int(BaseColorTexture.rawValue))
                
                renderEncoder.setFragmentTexture(modelSubmesh.textures.normal,
                                                 index: Int(NormalTexture.rawValue))
                
                // set the materials here
                var material = modelSubmesh.material
                renderEncoder.setFragmentBytes(&material,
                                               length: MemoryLayout<Material>.stride,
                                               index: Int(Materials.rawValue))
                
                // send submesh to draw
                renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                    indexCount: modelSubmesh.submesh.indexCount,
                                                    indexType: modelSubmesh.submesh.indexType,
                                                    indexBuffer: modelSubmesh.submesh.indexBuffer.buffer,
                                                    indexBufferOffset: modelSubmesh.submesh.indexBuffer.offset)
            }
        }

//        debugLights(renderEncoder: renderEncoder, lightType: Pointlight)
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
