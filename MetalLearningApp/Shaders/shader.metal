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
    float4 position [[ attribute(Position) ]];
    float3 normal [[ attribute(Normal) ]];
    float2 uv [[ attribute(UV) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(UniformsIndex) ]]) {
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertex_in.position;
    out.worldPosition = (uniforms.modelMatrix * vertex_in.position).xyz;
    out.worldNormal = uniforms.normalMatrix * vertex_in.normal;
    out.uv = vertex_in.uv;
    
    return out;
}

fragment float4 fragment_main(VertexOut fromVertex [[ stage_in ]],
                              constant Light *lights [[ buffer(LightsIndex) ]],
                              constant FragmentUniforms &fragmentUniforms [[ buffer(FragmentUniformsIndex) ]],
                              texture2d<float> baseColorTexture [[ texture(BaseColorTexture)]],
                              sampler textureSampler [[sampler(0)]]) {
    // sunlight
    float3 baseColor = baseColorTexture.sample(textureSampler, fromVertex.uv * fragmentUniforms.tiling).rgb;
    return float4(baseColor, 1);
    
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
        } else if (light.type == Pointlight) {
              // 1
              float d = distance(light.position, fromVertex.worldPosition);
              // 2
              float3 lightDirection = normalize(light.position - fromVertex.worldPosition);
              // 3
              float attenuation = 1.0 / (light.attenuation.x +
                  light.attenuation.y * d + light.attenuation.z * d * d);
              float diffuseIntensity =
                  saturate(dot(lightDirection, normalDirection));
              float3 color = light.color * baseColor * diffuseIntensity;
              // 4
              color *= attenuation;
              diffuseColor += color;
        } else if (light.type == Spotlight) {
            // 1
            float d = distance(light.position, fromVertex.worldPosition);
            float3 lightDirection = normalize(light.position - fromVertex.worldPosition);
            // 2
            float3 coneDirection = normalize(-light.coneDirection);
            float spotResult = (dot(lightDirection, coneDirection));
            // 3
            if (spotResult > cos(light.coneAngle)) {
                float attenuation = 1.0 / (light.attenuation.x +
                                           // 4
                                           light.attenuation.y * d + light.attenuation.z * d * d);
              
                attenuation *= pow(spotResult, light.coneAttenuation);
                float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
            }
        }
    }
    
    float3 color = diffuseColor + ambientColor + specularColor;

    return float4(color, 1);
}
