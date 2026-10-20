shader_type canvas_item;

uniform float hue:hint_range(0.0,360.0,1.0)=2.0;
uniform float brightness_modifier:hint_range(0.0,2.0,0.1)=1.0;

// https://www.geeksforgeeks.org/dsa/program-change-rgb-color-model-hsv-color-model/
vec3 rgb_to_hsv(vec4 rgb) {
	float r=rgb.r;
	float g=rgb.g;
	float b=rgb.b;
	float cmax=max(r,max(g,b));
	float cmin=min(r,min(g,b));
	float diff=cmax-cmin;
	float h=-1.0,s=-1.0;
	
	if (cmax==cmin) h=0.0;
	else if (cmax==r) h=mod(60.0*((g-b)/diff)+360.0,360.0);
	else if (cmax==g) h=mod(60.0*((b-r)/diff)+120.0,360.0);
	else if (cmax==b) h=mod(60.0*((r-g)/diff)+240.0,360.0);
	
	if (cmax==0.0) s=0.0;
	else s=(diff/cmax)*100.0;
	
	float v=cmax*100.0;
	
	return vec3(h,s,v);
}

// https://www.codespeedy.com/hsv-to-rgb-in-cpp/
vec3 hsv_to_rgb(vec3 hsv) {
	float h=hsv.r;
	float s=hsv.g/100.0;
	float v=hsv.b/100.0;
	float c=s*v;
	float x=c*(1.0-abs(mod(h/60.0,2.0)-1.0));
	float m=v-c;
	float r,g,b;
	if (h>=0.0&&h<60.0) {
		r=c;g=x;b=0.0;
	}
	else if (h>=60.0&&h<120.0) {
		r=x;g=c;b=0.0;
	}
	else if (h>=120.0&&h<180.0) {
		r=0.0;g=c;b=x;
	}
	else if (h>=180.0&&h<240.0) {
		r=0.0;g=x;b=c;
	}
	else if (h>=240.0&&h<300.0) {
		r=x;g=0.0;b=c;
	}
	else {
		r=c;g=0.0;b=x;
	}
	
	return vec3(r+m,g+m,b+m);
}

void fragment() {
	vec4 col=texture(TEXTURE,UV);
	vec3 hsv=rgb_to_hsv(col);
	hsv.r=hue;
	hsv.b*=brightness_modifier;
	col=vec4(hsv_to_rgb(hsv),col.a);
	COLOR=col;
}
