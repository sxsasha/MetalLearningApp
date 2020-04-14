//
//  Texturable.swift
//  MetalLearningApp
//
//  Created by sxsasha on 1/17/20.
//  Copyright © 2020 sxsasha. All rights reserved.
//

import MetalKit

protocol Texturable {
    
}

extension Texturable {
    static func loadTexture(imageName: String) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        let fileExtension = URL(fileURLWithPath: imageName).pathExtension.isEmpty ? "png" : nil
        
        guard let url = Bundle.main.url(forResource: imageName,
                                        withExtension: fileExtension) else {
                                            print("Failed to load \(imageName)")
                                            return nil
        }
        
        let texture = try textureLoader.newTexture(URL: url,
                                                   options: [.origin: MTKTextureLoader.Origin.bottomLeft,
                                                             .SRGB: false,
                                                             .generateMipmaps: NSNumber(booleanLiteral: true)])
        print("loaded texture: \(url.lastPathComponent)")
        
        return texture
    }
}
