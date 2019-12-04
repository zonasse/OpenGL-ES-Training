attribute vec4 vPosition;
attribute vec2 vTextureCoord;

varying vec2 textureCoordVarying;
uniform float time;

void main() {
    textureCoordVarying = vTextureCoord;
    
    float duration = 0.6;
    float maxScale = 0.3;
    float PI = 3.1415926;
    // 0.0 ~ 0.6
    float currentTime = mod(time,duration);
    float currentScale = 1.0 + maxScale * abs(sin(PI * (currentTime / duration)));
    
    gl_Position = vec4(vPosition.x * currentScale,vPosition.y * currentScale, vPosition.z, 1.0);
    
    
    
}
