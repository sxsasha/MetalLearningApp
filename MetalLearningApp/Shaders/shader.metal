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

constant bool hasColorTexture [[ function_constant(0) ]];
constant bool hasNormalTexture [[ function_constant(1) ]];

struct VertexIn {
    float4 position [[ attribute(Position) ]];
    float3 normal [[ attribute(Normal) ]];
    float2 uv [[ attribute(UV) ]];
    float3 tangent [[ attribute(Tangent) ]];
    float3 bitangent [[ attribute(Bitangent) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
    float3 worldTangent;
    float3 worldBitangent;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(UniformsIndex) ]]) {
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertex_in.position;
    out.worldPosition = (uniforms.modelMatrix * vertex_in.position).xyz;
    out.worldNormal = uniforms.normalMatrix * vertex_in.normal;
    out.worldTangent = uniforms.normalMatrix * vertex_in.tangent;
    out.worldBitangent = uniforms.normalMatrix * vertex_in.bitangent;
    out.uv = vertex_in.uv;
    
    return out;
}

fragment float4 fragment_main(VertexOut fromVertex [[ stage_in ]],
                              constant Light *lights [[ buffer(LightsIndex) ]],
                              constant FragmentUniforms &fragmentUniforms [[ buffer(FragmentUniformsIndex) ]],
                              constant Material &material [[ buffer(Materials) ]],
                              texture2d<float> baseColorTexture [[ texture(BaseColorTexture), function_constant(hasColorTexture) ]],
                              texture2d<float> normalTexture [[ texture(NormalTexture), function_constant(hasNormalTexture) ]],
                              sampler textureSampler [[sampler(0)]]) {
    // Base Color
    float3 baseColor;
    if (hasColorTexture) {
        baseColor = baseColorTexture.sample(textureSampler, fromVertex.uv * fragmentUniforms.tiling).rgb;
    } else {
        baseColor = material.baseColor;
    }

    float3 normalValue;
    if (hasNormalTexture) {
        normalValue = normalTexture.sample(textureSampler, fromVertex.uv * fragmentUniforms.tiling).xyz;
        normalValue = normalValue * 2 - 1;
    } else {
        normalValue = fromVertex.worldNormal;
    }
    normalValue = normalize(normalValue);
    
    
    float3 normalDirection = float3x3(fromVertex.worldTangent,
                                      fromVertex.worldBitangent,
                                      fromVertex.worldNormal) * normalValue;
    normalDirection = normalize(normalDirection);
    
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    
    float materialShininess = material.shininess;
    float3 materialSpecularColor = material.specularColor;
    
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
