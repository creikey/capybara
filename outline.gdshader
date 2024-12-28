shader_type canvas_item;

uniform int width = 2;

void vertex() {
}

void fragment() {
	vec2 size = vec2(textureSize(TEXTURE, 0));

	if(COLOR.a < 0.1) {
		bool visible = false;
		for(int x = -width; x <= width; x += 1) {
			for(int y = -width; y <= width; y += 1) {
				if(texture(TEXTURE, UV + vec2(float(x)/size.x,float(y)/size.y)).a > 0.1) {
					visible = true;
					break;
				}
			}
			if(visible) break;
 		}
		if(visible) {
			COLOR = vec4(1,1,1,1);
		} else {
			COLOR = vec4(1,1,1,0);
		}
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
