precision highp float;

uniform sampler2D fTexture;
varying vec2 textureCoordVarying;

uniform float time;

void main (void) {
    
    float duration = 0.7;
    float maxScale = 1.1;
    float offset = 0.02;
    
    float progress = mod(time, duration) / duration; // 0~1
    vec2 offsetCoords = vec2(offset, offset) * progress;
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    vec2 ScaleTextureCoords = vec2(0.5, 0.5) + (textureCoordVarying - vec2(0.5, 0.5)) / scale;
    
    vec4 maskR = texture2D(fTexture, ScaleTextureCoords + offsetCoords);
    vec4 maskB = texture2D(fTexture, ScaleTextureCoords - offsetCoords);
    vec4 mask = texture2D(fTexture, ScaleTextureCoords);
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);

    
}
