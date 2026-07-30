uniform float u_time;
uniform vec2 u_resolution;
uniform float u_energy;
uniform float u_bass;
uniform float u_mid;
uniform float u_treble;
uniform float u_beat;
uniform float u_intensity;

out vec4 fragColor;
in vec2 fragCoord;

void main() {
    vec2 uv = fragCoord / u_resolution;
    vec2 center = vec2(0.5, 0.5);
    vec2 d = uv - center;
    float dist = length(d);

    float t = u_time;
    float pulse = sin(t * 1.5 + u_bass * 3.0) * 0.5 + 0.5;
    float beatFlash = smoothstep(0.5, 1.0, u_beat);

    float ring1 = abs(sin(dist * 30.0 - t * 2.0));
    float ring2 = abs(cos(dist * 45.0 + t * 1.5 + u_mid * 2.0));
    float ring3 = abs(sin(dist * 60.0 - t * 3.0 + u_bass * 4.0));

    ring1 = 1.0 - ring1;
    ring2 = 1.0 - ring2;
    ring3 = 1.0 - ring3;

    ring1 = pow(ring1, 8.0);
    ring2 = pow(ring2, 8.0);
    ring3 = pow(ring3, 6.0);

    float glow = ring1 + ring2 * 0.6 + ring3 * 0.4;
    glow *= 0.3 + pulse * 0.5 + beatFlash * 0.4;
    glow *= (0.2 + u_energy * 0.8);

    vec3 c1 = vec3(0.0, 0.7, 1.0);
    vec3 c2 = vec3(1.0, 0.2, 0.8);
    vec3 c3 = vec3(0.0, 1.0, 0.5);

    float hueShift = sin(t * 0.2) * 0.5 + 0.5;
    vec3 color = mix(c1, c2, hueShift) * ring1;
    color += mix(c2, c3, pulse) * ring2 * 0.5;
    color += vec3(0.5, 0.0, 1.0) * ring3 * 0.3;

    float core = 1.0 - dist * 3.0;
    core = max(0.0, core);
    color += vec3(1.0, 1.0, 1.0) * core * 0.3 * u_energy;

    color *= (0.4 + u_intensity * 0.6);
    color *= 1.0 - length(uv - 0.5) * 0.3;

    fragColor = vec4(color, 1.0);
}
