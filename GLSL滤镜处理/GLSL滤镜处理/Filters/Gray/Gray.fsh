precision highp float;
varying vec2 TextureCoordVarying;

uniform sampler2D fTexture;

void main() {
    vec4 mask = texture2D(fTexture, TextureCoordVarying);
    const highp vec3 W = vec3(0.321,0.52,0.135);
    float luminance = dot(mask.rgb,W);
    gl_FragColor = vec4(vec3(luminance),1.0);
}
