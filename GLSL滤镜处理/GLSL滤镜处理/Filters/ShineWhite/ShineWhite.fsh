precision highp float;

uniform sampler2D fTexture;
varying vec2 textureCoordVarying;

uniform float time;
const float PI = 3.1415926;

void main (void) {
    
    float duration = 0.6;
    float currentTime = mod(time, duration);
    vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
    float amplitude = abs(sin(currentTime * (PI / duration)));
    vec4 mask = texture2D(fTexture, textureCoordVarying);
    gl_FragColor = mask * (1.0 - amplitude) + whiteMask * amplitude;

    
}
