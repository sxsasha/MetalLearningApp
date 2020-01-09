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
    float3 normal [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 worldNormal;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(1) ]]) {
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertex_in.position;
    out.worldPosition = (uniforms.modelMatrix * vertex_in.position).xyz;
    out.worldNormal = uniforms.normalMatrix * vertex_in.normal;
    
    return out;
}

fragment float4 fragment_main(VertexOut fromVertex [[ stage_in ]],
                              constant Light *lights [[ buffer(2) ]],
                              constant FragmentUniforms &fragmentUniforms [[ buffer(3) ]]) {
    // sunlight
    float3 baseColor = float3(0, 1, 0);
    float3 diffuseColor = float3(0);
    float3 normalDirection = normalize(fromVertex.worldNormal);
    
    // ambient
    float3 ambientColor = 0;
    
    // specular
    float3 specularColor = 0;
    float materialShininess = 32;
    float3 materialSpecularColor = float3(1, 1, 1);
    
    for (uint i = 0; i < fragmentUniforms.lightCount; i++) {
        Light light = lights[i];
        
        if (light.type == Sunlight) {
            float3 lightDirection = normalize(light.position);
            float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
            
            diffuseColor += light.color * baseColor * diffuseIntensity;
            
            if (diffuseIntensity > 0) {
              // 1 (R)
              float3 reflection =
                  reflect(lightDirection, normalDirection);
              // 2 (V)
              float3 cameraPosition =
                  normalize(fromVertex.worldPosition - fragmentUniforms.cameraPosition);
              // 3
              float specularIntensity =
                  pow(saturate(dot(reflection, cameraPosition)), materialShininess);
              specularColor +=
                  light.specularColor * materialSpecularColor * specularIntensity;
            }
        } else if (light.type == Ambientlight) {
            ambientColor += light.color * light.intensity;
        }
    }
    
    float3 color = diffuseColor + ambientColor + specularColor;

    return float4(color, 1);
}
