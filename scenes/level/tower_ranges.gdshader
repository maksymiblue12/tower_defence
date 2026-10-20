shader_type canvas_item;

void fragment() {
	vec4 tex=texture(TEXTURE,UV);
	vec4 col=vec4(0.,0.,0.,0.);
	if (tex.r>0.01||tex.g>0.01||tex.b>0.01) {
		if (tex.rgb==vec3(0,0,1)) {
			col=vec4(0.,0.,1.,0.08);
		} else if (tex.rgb==vec3(0,1,0)) {
			col=vec4(0.,0.,1.,0.32);
		} else if (tex.rgb==vec3(0,1,1)) {
			col=vec4(1.,0.,0.,0.08);
		} else if (tex.rgb==vec3(1,0,0)) {
			col=vec4(1.,0.,0.,0.32);
		}
	}
	COLOR=col;
}
