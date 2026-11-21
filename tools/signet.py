#!/usr/bin/env python3
"""The Swarm signet (a bee), built with the ODSV signet helpers and grammar (ODSV SPEC 10.4).

Usage: python3 -I tools/signet.py <odsv-clone> [out-dir]      (default out-dir: assets)
ODSV clone: git clone --depth 1 https://github.com/diren89/odsv

Grammar (summary): viewBox 400, exactly four strokes of 26 units with round ends, colour order
pink → orange → amber → gold from back/large to front/small, exactly one yellow dot (r 24–34) as
focus, motif right of centre (left edge ≥ 107 incl. stroke), visible band y 50–350, wordmark zone
x < 240 / y > 302 stays free, parallel strokes ≥ 40 apart, no fills except the dot.
Writes the-swarm-signet.svg (transparent) and the-swarm-signet-dark.svg (on black, square icon).
"""
import importlib.util, math, pathlib, re, sys

odsv = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2] if len(sys.argv) > 2 else 'assets')
spec = importlib.util.spec_from_file_location('bs', odsv / 'tools' / 'build_signets.py')
bs = importlib.util.module_from_spec(spec); spec.loader.exec_module(bs)

COLORS = ['#EC3A78', '#EE6A2C', '#F09A35', '#F3C340']   # signet-1…4
DOT = '#FFE94D'                                          # signet-dot


def ellipse(cx, cy, rx, ry, rot_deg, n=10):
    """Closed smooth ellipse through n points, rotated (degrees, counter-clockwise on screen)."""
    r = math.radians(rot_deg)
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        x, y = rx * math.cos(t), ry * math.sin(t)
        pts.append((cx + x * math.cos(r) + y * math.sin(r), cy - x * math.sin(r) + y * math.cos(r)))
    return bs.smooth(pts, closed=True)


def bee():
    # Biene im Profil, Blick nach rechts:
    # 1 Pink   – hinterer, großer Flügel (nach hinten oben geneigt)
    # 2 Orange – vorderer, kleinerer Flügel (steiler)
    # 3 Bernstein – Körper (liegende Ellipse) mit Stachel als Teilstrich
    # 4 Gold   – zwei Streifen auf dem Körper (ein Pfad, zwei Teilstriche)
    # Punkt    – Kopf vorne rechts: Fokus des Signets
    back_wing = ellipse(200, 116, 70, 40, 30)
    front_wing = ellipse(284, 122, 60, 34, 65)
    body = ellipse(262, 226, 80, 54, 0, n=12) + 'M176 226L152 226'   # body + sting (same stroke)
    stripes = 'M242 200L242 252M286 200L286 252'
    return [back_wing, front_wing, body, stripes], (366, 220, 28)   # head sits on the body's front


def svg(paths, dot, background=None, view='0 0 400 400', size=400):
    bg = f'<rect x="-200" y="-200" width="800" height="800" fill="{background}"/>' if background else ''
    body = ''.join(f'<path d="{d}" fill="none" stroke="{c}" stroke-width="26" stroke-linecap="round" stroke-linejoin="round"/>'
                   for d, c in zip(paths, COLORS))
    body += f'<circle cx="{dot[0]}" cy="{dot[1]}" r="{dot[2]}" fill="{DOT}"/>'
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}" width="{size}" height="{size}" '
            f'role="img" aria-label="The Swarm"><title>The Swarm</title>{bg}{body}</svg>')


def sample(d):
    """Point sampling for M/L/C paths (enough for bounds and zone checks)."""
    pts, cur = [], (0.0, 0.0)
    for cmd, args in re.findall(r'([MLCZ])([^MLCZ]*)', d):
        n = [float(x) for x in re.findall(r'-?\d+\.?\d*', args)]
        if cmd == 'M':
            cur = (n[0], n[1]); pts.append(cur)
        elif cmd == 'L':
            b = (n[0], n[1]); pts += [(cur[0] + (b[0] - cur[0]) * t / 20, cur[1] + (b[1] - cur[1]) * t / 20) for t in range(21)]; cur = b
        elif cmd == 'C':
            for i in range(0, len(n), 6):
                c = [cur, (n[i], n[i + 1]), (n[i + 2], n[i + 3]), (n[i + 4], n[i + 5])]
                for t in [s / 20 for s in range(21)]:
                    p = c[:]
                    while len(p) > 1:
                        p = [(p[j][0] + (p[j + 1][0] - p[j][0]) * t, p[j][1] + (p[j + 1][1] - p[j][1]) * t) for j in range(len(p) - 1)]
                    pts.append(p[0])
                cur = c[-1]
    return pts


def check(paths, dot):
    errs = []
    if len(paths) != 4: errs.append(f'{len(paths)} Striche statt 4')
    if not 24 <= dot[2] <= 34: errs.append(f'Punkt r={dot[2]}')
    pts = [p for d in paths for p in sample(d)]
    minx = min(min(p[0] for p in pts) - 13, dot[0] - dot[2])
    miny = min(min(p[1] for p in pts) - 13, dot[1] - dot[2])
    maxy = max(max(p[1] for p in pts) + 13, dot[1] + dot[2])
    if minx < 107: errs.append(f'zu weit links (x {minx:.0f})')
    if miny < 50: errs.append(f'oben ausserhalb (y {miny:.0f})')
    if maxy > 350: errs.append(f'unten ausserhalb (y {maxy:.0f})')
    if any(p[0] - 13 < 240 and p[1] + 13 > 302 for p in pts): errs.append('Wortmarken-Zone belegt')
    if dot[0] - dot[2] < 240 and dot[1] + dot[2] > 302: errs.append('Punkt in Wortmarken-Zone')
    return errs


if __name__ == '__main__':
    paths, dot = bee()
    errs = check(paths, dot)
    print('Grammatik:', 'ok' if not errs else errs)
    out.mkdir(parents=True, exist_ok=True)
    (out / 'the-swarm-signet.svg').write_text(svg(paths, dot))
    # Square icon: motif centred (view shifted right), black ground.
    (out / 'the-swarm-signet-dark.svg').write_text(svg(paths, dot, background='#000000', view='95 15 330 330', size=1024))
    sys.exit(1 if errs else 0)
