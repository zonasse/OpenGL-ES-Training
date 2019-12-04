precision lowp float;
uniform sampler2D fTexture;
varying lowp vec2 textureCoordVarying;

void main() {
    vec2 uv = textureCoordVarying.xy;
    if (uv.x >= 0.0 && uv.x <= 0.33) {
        uv.x += 0.33;
    } else if (uv.x >= 0.66) {
        uv.x -= 0.33;
    }
    if (uv.y >= 0.0 && uv.y <= 0.5) {
        uv.y += 0.25;
    } else {
        uv.y -= 0.25;
    }
    vec4 mask = texture2D(fTexture,uv);
    gl_FragColor = vec4(mask.rgb,1.0);
}
