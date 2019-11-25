precision highp float;

uniform sampler2D colorMap;

varying lowp vec2 vTextureCoord;
varying lowp vec4 vPositionColor;

void main() {

    vec4 weakMaskColor = texture2D(colorMap,vTextureCoord);
    float alpha = 0.7;

    vec4 maskColor = vPositionColor;
    gl_FragColor = maskColor * alpha + weakMaskColor * (1.0 - alpha);
}
