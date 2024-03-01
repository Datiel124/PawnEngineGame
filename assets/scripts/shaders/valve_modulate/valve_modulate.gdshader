shader_type spatial;
render_mode unshaded;

uniform sampler2D base_texture : hint_default_white;
uniform vec3 tint : source_color = vec3(1.0);
uniform float strength : hint_range(0.0, 10.0) = 1.0;
uniform sampler2D screen_tex : hint_screen_texture;

//
//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(screen_tex, SCREEN_UV).rgb * texture(base_texture, UV).rgb * tint * strength;
}