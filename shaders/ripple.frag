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

    float t = u_time * 0.6;
    float bass = u_bass * 2.0;
    float beat = u_beat * 3.0;

    float wave1 = sin(dist * 20.0 - t * 3.0 + bass) * 0.5 + 0.5;
    float wave2 = cos(dist * 35.0 - t * 2.0 + beat) * 0.5 + 0.5;
    float wave3 = sin(dist * 50.0 - t * 4.0 + u_mid * 2.0) * 0.5 + 0.5;

    float ring = (wave1 + wave2 * 0.4 + wave3 * 0.2) / 1.6;
    ring *= 0.4 + u_energy * 0.6;

    float fade = 1.0 - dist * 0.8;
    ring *= fade;

    vec3 color1 = vec3(0.1, 0.6, 0.9);
    vec3 color2 = vec3(0.8, 0.2, 0.6);
    vec3 color = mix(color1, color2, wave1);
    color *= ring * (0.3 + u_intensity * 0.7);

    vec3 glow = vec3(0.3, 0.5, 1.0) * ring * 0.15;
    color += glow;

    color *= 0.5 + length(uv - 0.5) * 0.5;

    fragColor = vec4(color, 1.0);
}
