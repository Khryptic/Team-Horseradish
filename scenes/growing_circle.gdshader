shader_type canvas_item;

instance uniform float ring_size;
instance uniform float opacity;
instance uniform float ring_thickness;
instance uniform vec3 color : source_color;

void fragment() {
	// Called for every pixel the material is visible on.

    float dist = length(UV - vec2(0.5));

    float alpha;

    if(dist > ring_size) {
        alpha = smoothstep(ring_size + ring_thickness, ring_size - ring_thickness, dist);
    } else {
        alpha = smoothstep(ring_size - ring_thickness, ring_size + ring_thickness, dist);
    }

    // Output to color.rgb
    COLOR = vec4(color.rgb, alpha * opacity);
}