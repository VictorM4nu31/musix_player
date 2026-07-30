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
    float aspect = u_resolution.x / u_resolution.y;
    vec2 p = uv;
    p.x *= aspect;

    float t = u_time * 0.25;

    float b1 = sin(p.x * 3.2 + t) * cos(p.y * 2.1 + t * 0.6 + u_bass * 1.5);
    float b2 = sin(p.x * 5.1 - t * 0.6 + p.y * 1.4 + u_mid * 1.2);
    float b3 = cos(p.x * 4.3 + p.y * 3.2 + t * 0.9 + u_treble * 0.8);

    b1 = b1 * 0.5 + 0.5;
    b2 = b2 * 0.5 + 0.5;
    b3 = b3 * 0.5 + 0.5;

    vec3 c1 = vec3(0.05, 0.75, 0.55) * b1;
    vec3 c2 = vec3(0.45, 0.15, 0.85) * b2;
    vec3 c3 = vec3(0.0, 0.8, 0.35) * b3;

    vec3 color = c1 + c2 + c3;
    color *= 0.5 + u_energy * 0.6;
    color += u_bass * vec3(0.08, 0.03, 0.0);

    float vig = 1.0 - length(uv - 0.5) * 0.7;
    color *= vig * (0.6 + u_intensity * 0.4);

    fragColor = vec4(color, 1.0);
}
