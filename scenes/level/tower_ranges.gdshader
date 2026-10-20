shader_type canvas_item;

void fragment() {
	vec4 tex=texture(TEXTURE,UV);
	vec4 col=vec4(0.,0.,0.,0.);
	if (tex.r>0.01||tex.g>0.01||tex.b>0.01) {
		float mx=max(tex.r,max(tex.g,tex.b));
		if (mx==tex.r) {
			col=vec4(0.,0.,1.,0.08);
		}
		else if (mx==tex.g) {
			col=vec4(0.,0.,1.,0.32);
		}
	}
	COLOR=col;
}
