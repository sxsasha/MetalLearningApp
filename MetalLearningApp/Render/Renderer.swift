//
//  Renderer.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/4/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue!
    
    var pipelineState: MTLRenderPipelineState!
    var mdlMesh: MDLMesh!
    var mesh: MTKMesh!
    
    var timer: Float = 0
    var projectionMatrix: float4x4 = .identity
    
    init(device: MTLDevice, viewSize: CGSize) {
        self.device = device
        super.init()
        
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create a command queue")
        }
        
        self.commandQueue = commandQueue
        
        createMesh()
        makePipeline()
        computeProjection(size: viewSize)
    }
    
    private func createMesh() {
        // create allocator
        let allocator = MTKMeshBufferAllocator(device: device)
        
        guard let assetURL = Bundle.main.url(forResource: "train", withExtension: "obj") else {
            fatalError()
        }
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
        
        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        
        let asset = MDLAsset(url: assetURL, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        // get mtkMesh from MDLMesh
        mesh = try! MTKMesh(mesh: mdlMesh, device: device)
    }
    
    private func makePipeline() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        
        do {
            pipelineState =
            try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    private func computeProjection(size: CGSize) {
        let aspect = Float(size.width / size.height)
        projectionMatrix = float4x4(projectionFov: radians(fromDegrees: 45),
                                    near: 0.1,
                                    far: 100,
                                    aspect: aspect)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        computeProjection(size: size)
    }
    
    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        
        var uniforms = Uniforms()
        let translation = float4x4(translation: [0, 0.3, 0])
        let rotations = float4x4(rotation: [0, radians(fromDegrees: 70), 0])
        uniforms.modelMatrix = translation * float4x4(rotationY: sin(timer)) //rotations
        uniforms.viewMatrix = float4x4(translation: [0, 0, -5]).inverse
        uniforms.projectionMatrix = projectionMatrix
        
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 2)
        
        timer += 0.05
        var currentTime = sin(timer)
        renderEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 1)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
