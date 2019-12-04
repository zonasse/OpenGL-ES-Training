attribute vec4 vPosition;
attribute vec2 vTextureCoord;

varying vec2 TextureCoordVarying;

void main() {
    gl_Position = vPosition;
    TextureCoordVarying = vTextureCoord;
}
