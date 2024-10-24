shader_type spatial;
void vertex() {
	VERTEX.y +=sin(TIME *5.0 + VERTEX.x*5.0);
}
void fragment() {
	vec3 color;
	color.r =4.0;
	color.g =cos(TIME*2.0)+50.0;
	color.b =9.0;
	ALBEDO=color;
	ROUGHNESS=1.0;
	METALLIC=cos(TIME*5.0)+40.0;
}