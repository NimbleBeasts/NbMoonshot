shader_type canvas_item;

uniform float scale_x = 1.0; // How many tiles we need to fill the sprite
uniform float direction = -1.0; // Flow direction -1 -> right, +1 -> left

void fragment() {
	vec2 adjusted_uv = UV;
	adjusted_uv.x *= scale_x;
	adjusted_uv.y *= 0.8 + 0.2;
	
	vec2 waves_uv_offset;
	waves_uv_offset.x = TIME * direction * 0.8;
	waves_uv_offset.y = cos(TIME + adjusted_uv.x * direction * 2.0 ) * 0.05 ;
	
	COLOR = texture(TEXTURE, adjusted_uv + waves_uv_offset);
}