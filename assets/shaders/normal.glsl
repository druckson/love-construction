extern vec3 lightNormal;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {
    vec4 normal = (Texel(tex, tc) - vec4(0.5));
    number val = (lightNormal.x * normal.r) + (lightNormal.y * -normal.g) + (lightNormal.z * normal.b);
    return vec4(val);
}
