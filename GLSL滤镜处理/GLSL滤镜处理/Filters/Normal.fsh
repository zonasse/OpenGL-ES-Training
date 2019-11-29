precision highp float;
uniform sampler2D fTexture;
varying vec2 textureCoordVarying;

void main() {
    vec4 mask = texture2D(fTexture,textureCoordVarying);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
