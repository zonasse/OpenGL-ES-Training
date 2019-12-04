
uniform sampler2D fTexture;
varying lowp vec2 textureCoordVarying;

const lowp vec2 TextureSize = vec2(512.0,512.0);
const lowp vec2 mosaicSize = vec2(16.0,16.0);

void main() {
    lowp vec2 intXY = vec2(textureCoordVarying.x * TextureSize.x, textureCoordVarying.y * TextureSize.y);
    lowp vec2 mosaicXY = vec2(floor(intXY.x / mosaicSize.x) * mosaicSize.x,floor(intXY.y / mosaicSize.y) * mosaicSize.y);
    lowp vec2 mosaicST = vec2(mosaicXY.x / TextureSize.x,mosaicXY.y / TextureSize.y);
    gl_FragColor = texture2D(fTexture,mosaicST);
}
