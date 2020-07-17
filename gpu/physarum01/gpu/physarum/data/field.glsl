
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform sampler2D deposit;
uniform float nPX;
uniform float nPY;

void main() {
	float avgValue = 0;
	float coefficientSum = 0.0;
	for (int x = -1; x < 2; x++) {
		for (int y = -1; y < 2; y++) {
			vec2 thisPos = (vertTexCoord.xy + vec2(x/nPX,y/nPY));
			thisPos.x = mod((thisPos.x+1),1.0f);
			thisPos.y = mod((thisPos.y+1),1.0f);
			avgValue += texture2D(texture, thisPos).r;
			coefficientSum += 1.0;
		}
	}

	// deposit
	avgValue += texture2D(deposit, vertTexCoord.xy).r*10.0;

	gl_FragColor = vec4(avgValue * 0.98 / coefficientSum,0.0,0.0,1.0);
}
