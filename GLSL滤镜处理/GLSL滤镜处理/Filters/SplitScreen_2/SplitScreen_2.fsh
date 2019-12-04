precision lowp float;
uniform sampler2D fTexture;

varying vec2 textureCoordVarying;

void main() {
    vec2 uv = textureCoordVarying.xy;
    float y;
    if (uv.y >= 0.0 && uv.y <= 0.5) {
        y = uv.y + 0.25;
    } else {
        y = uv.y - 0.25;
    }
    vec4 mask = texture2D(fTexture,vec2(uv.x,y));
    gl_FragColor = vec4(mask.rgb, 1.0);
}
