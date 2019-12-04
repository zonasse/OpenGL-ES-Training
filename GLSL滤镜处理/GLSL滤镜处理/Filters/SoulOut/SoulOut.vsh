
attribute vec4 vPosition;
attribute vec2 vTextureCoord;

varying vec2 textureCoordVarying;

void main() {
    textureCoordVarying = vTextureCoord;
    
    
    gl_Position = vPosition;
    
    
}
