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
    
    private var commandQueue: MTLCommandQueue
    private var uniforms = Uniforms()
    
    var camera = Camera()
    var models: [Model] = []
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else {
          fatalError("GPU not available")
        }
        
        Renderer.device = device
        metalView.device = device
        metalView.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
        
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create a command queue")
        }
        
        self.commandQueue = commandQueue
        
        super.init()
        
        metalView.delegate = self
        camera.aspect = Float(metalView.bounds.size.width / metalView.bounds.size.height)
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
        
        for model in models {
            uniforms.modelMatrix = model.modelMatrix
            
            renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            renderEncoder.setRenderPipelineState(model.pipelineState)
            renderEncoder.setVertexBuffer(model.vertexBuffer, offset: 0, index: 0)
            
            for submesh in model.mesh.submeshes {
                renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                    indexCount: submesh.indexCount,
                                                    indexType: submesh.indexType,
                                                    indexBuffer: submesh.indexBuffer.buffer,
                                                    indexBufferOffset: submesh.indexBuffer.offset)
            }
        }

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
