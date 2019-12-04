precision lowp float;
varying vec2 textureCoordVarying;
uniform sampler2D fTexture;

void main() {
    gl_FragColor = texture2D(fTexture,textureCoordVarying);
}
