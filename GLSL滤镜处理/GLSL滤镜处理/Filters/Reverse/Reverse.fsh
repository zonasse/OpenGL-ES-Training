precision highp float;
uniform sampler2D fTexture;
varying vec2 textureCoordVarying;

void main() {
    vec2 uv = textureCoordVarying.xy;
    uv.y = 1.0 - uv.y;
    vec4 mask = texture2D(fTexture,uv);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
