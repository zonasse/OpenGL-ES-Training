attribute vec4 vPosition;
attribute vec2 vTextureCoord;

varying lowp vec2 textureCoordVarying;

void main() {
    gl_Position = vPosition;
    textureCoordVarying = vTextureCoord;
}
