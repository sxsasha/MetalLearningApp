//
//  StandartShader.metal
//  MetalLearningApp
//
//  Created by sxsasha on 12/4/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

#include <metal_stdlib>
#include "ShaderDefinitions.h"

using namespace metal;

//#import "MetalLearningApp-Bridging-Header.h"

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]],
                          constant Uniforms &uniforms [[ buffer(1) ]]) {
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertex_in.position;
    
    return position;
}

fragment float4 fragment_main() {
    return float4(0, 0, 1, 1);
}
