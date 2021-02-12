shader_type canvas_item;

uniform float tile_factor = 10.0;
uniform float aspect_ratio = 0.5;


void fragment() {
	vec2 adjusted_uv = UV * tile_factor;
	adjusted_uv.y *= aspect_ratio;
	
	vec2 waves_uv_offset;
	//waves_uv_offset.x = cos(TIME + adjusted_uv.y ) * 0.05;
	waves_uv_offset.y = cos(TIME + adjusted_uv.x) * 0.15;
	
	COLOR = texture(TEXTURE, adjusted_uv + waves_uv_offset);
}
