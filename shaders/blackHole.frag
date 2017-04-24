extern float time;
extern float aspect;

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
            sin(_angle),cos(_angle));
}

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
    vec2 norm = tex_coords * vec2(aspect, 1.0) - vec2(aspect / 2, 0.5);
    float dist = length(norm);
    float distortion = 0.5 * mix(0.1, 0.0, min(dist * 10.0, 1.0));
    float move = sin(dist * 40.0 - 10.0 * time) * 0.5 + 0.5;
    float rotate = distortion * sin(time * 5.0);
    vec2 coord = tex_coords + move * distortion * norm / dist;
    coord = rotate2d(rotate) * coord;
    return Texel(tex, coord);
}
