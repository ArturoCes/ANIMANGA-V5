"""Genera páginas de avance de muestra (arte procedural, sin contenido con derechos)."""
import math
import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

covers = Path(sys.argv[1])
out = Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)

W, H = 640, 960
M = 28  # margen exterior
GAP = 14
FONTS = Path("C:/Windows/Fonts")
bubble_font = ImageFont.truetype(str(FONTS / "comicbd.ttf"), 20)
sfx_font = ImageFont.truetype(str(FONTS / "impact.ttf"), 64)
small_font = ImageFont.truetype(str(FONTS / "arial.ttf"), 14)
title_font = ImageFont.truetype(str(FONTS / "impact.ttf"), 54)
sub_font = ImageFont.truetype(str(FONTS / "arialbd.ttf"), 22)

SERIES = {
    "jjk-01": "Jujutsu Kaisen",
    "jjk-00": "Jujutsu Kaisen 0",
    "op-01": "One Piece",
    "nar-01": "Naruto",
    "snk-01": "Ataque a los Titanes",
    "kny-01": "Guardianes de la Noche",
    "csm-01": "Chainsaw Man",
    "sxf-01": "Spy×Family",
}
LINES = [
    "¿Qué ha sido eso?", "¡No pienso rendirme!", "Esto solo acaba de empezar...", "¡Corre!",
    "¿Quién eres tú?", "Lo prometí.", "No te muevas.", "¡Ahora!", "...", "Tenemos que irnos ya.",
    "¿Lo has notado?", "¡Detrás de ti!", "Confía en mí.", "No puede ser...",
]
SFX = ["¡BAM!", "¡FWOOSH!", "¡KRAK!", "¡DON!", "¡ZAS!", "¡GOGOGO!"]

# Distribuciones de viñetas en coordenadas relativas (x0, y0, x1, y1) dentro del área útil
LAYOUTS = [
    [(0, 0, 1, .32), (0, .32, .55, .66), (.55, .32, 1, .66), (0, .66, 1, 1)],
    [(0, 0, .6, .45), (.6, 0, 1, .45), (0, .45, 1, .72), (0, .72, .4, 1), (.4, .72, 1, 1)],
    [(0, 0, 1, .55), (0, .55, .5, 1), (.5, .55, 1, 1)],
    [(0, 0, .45, .3), (.45, 0, 1, .3), (0, .3, 1, .62), (0, .62, .62, 1), (.62, .62, 1, 1)],
    [(0, 0, 1, .25), (0, .25, 1, .5), (0, .5, 1, .75), (0, .75, 1, 1)],
]


def halftone(size, rnd, angle_dark=None):
    """Trama de puntos con degradado, como la screentone del manga."""
    w, h = size
    img = Image.new("L", size, 255)
    d = ImageDraw.Draw(img)
    step = 7
    ang = rnd.uniform(0, math.tau) if angle_dark is None else angle_dark
    for y in range(0, h + step, step):
        for x in range(0, w + step, step):
            t = ((x / w - .5) * math.cos(ang) + (y / h - .5) * math.sin(ang)) + .5
            r = max(0, min(step * .55, t * step * .6))
            if r > .6:
                ox = (step / 2) if (y // step) % 2 else 0
                d.ellipse((x + ox - r, y - r, x + ox + r, y + r), fill=0)
    return img


def speed_lines(d, box, rnd, center=None):
    x0, y0, x1, y1 = box
    cx, cy = center or ((x0 + x1) / 2, (y0 + y1) / 2)
    for _ in range(140):
        a = rnd.uniform(0, math.tau)
        r0 = rnd.uniform(.25, .45) * min(x1 - x0, y1 - y0)
        r1 = max(x1 - x0, y1 - y0)
        p0 = (cx + math.cos(a) * r0, cy + math.sin(a) * r0)
        p1 = (cx + math.cos(a) * r1, cy + math.sin(a) * r1)
        d.line([p0, p1], fill=0, width=rnd.choice([1, 1, 2]))


def figure(d, cx, base, scale, rnd):
    """Silueta sencilla de personaje (cabeza, pelo en punta y torso)."""
    head = 46 * scale
    d.ellipse((cx - head, base - 5.2 * head, cx + head, base - 3.2 * head), fill=255, outline=0, width=3)
    spikes = []
    for i in range(9):
        a = math.pi + i * math.pi / 8
        rr = head * (1.45 if i % 2 else 1.0)
        spikes.append((cx + math.cos(a) * rr, base - 4.2 * head + math.sin(a) * rr))
    d.polygon(spikes, fill=0)
    # ojos
    for side in (-1, 1):
        ex = cx + side * head * .42
        ey = base - 4.05 * head
        d.ellipse((ex - head * .16, ey - head * .22, ex + head * .16, ey + head * .22), fill=0)
        d.ellipse((ex - head * .06, ey - head * .15, ex + head * .03, ey - head * .03), fill=255)
    d.polygon([(cx - head * 1.6, base), (cx - head * 1.1, base - 3.1 * head), (cx + head * 1.1, base - 3.1 * head),
               (cx + head * 1.6, base)], fill=rnd.choice([0, 40, 255]), outline=0)
    d.line([(cx, base - 3.1 * head), (cx, base)], fill=128, width=2)


def bubble(d, box, text, rnd):
    x0, y0, x1, y1 = box
    words = text.split()
    lines, cur = [], ""
    for w in words:
        test = (cur + " " + w).strip()
        if d.textlength(test, font=bubble_font) > 150 and cur:
            lines.append(cur)
            cur = w
        else:
            cur = test
    lines.append(cur)
    tw = max(d.textlength(l, font=bubble_font) for l in lines)
    th = len(lines) * 24
    bw, bh = tw + 48, th + 34
    bx = rnd.uniform(x0 + 8, max(x0 + 9, x1 - bw - 8))
    by = rnd.uniform(y0 + 8, max(y0 + 9, y0 + (y1 - y0) * .35))
    tail = [(bx + bw * .45, by + bh - 4), (bx + bw * .6, by + bh - 4), (bx + bw * .5 + rnd.uniform(-30, 30), by + bh + 26)]
    d.polygon(tail, fill=255, outline=0)
    d.ellipse((bx, by, bx + bw, by + bh), fill=255, outline=0, width=3)
    d.polygon([(tail[0][0] + 3, tail[0][1] - 2), (tail[1][0] - 3, tail[1][1] - 2), tail[2]], fill=255)
    for i, l in enumerate(lines):
        lw = d.textlength(l, font=bubble_font)
        d.text((bx + (bw - lw) / 2, by + 17 + i * 24), l, font=bubble_font, fill=0)


def panel(page, d, box, rnd):
    x0, y0, x1, y1 = [int(v) for v in box]
    kind = rnd.choice(["tone", "speed", "figure", "figure", "sky"])
    w, h = x1 - x0, y1 - y0
    if kind == "tone" or kind == "sky":
        page.paste(halftone((w, h), rnd), (x0, y0))
    if kind == "speed":
        speed_lines(d, box, rnd)
        txt = rnd.choice(SFX)
        tw = d.textlength(txt, font=sfx_font)
        d.text((x0 + (w - tw) / 2, y0 + h / 2 - 36), txt, font=sfx_font, fill=255, stroke_width=4, stroke_fill=0)
    if kind == "sky":
        for _ in range(4):  # edificios en contraluz
            bw = rnd.uniform(.12, .25) * w
            bx = rnd.uniform(x0, x1 - bw)
            d.rectangle((bx, y1 - rnd.uniform(.2, .5) * h, bx + bw, y1), fill=0)
    if kind in ("figure", "tone"):
        scale = min(w, h) / 360
        figure(d, x0 + rnd.uniform(.35, .65) * w, y1 + 10, max(.45, scale), rnd)
    if kind != "speed" and rnd.random() < .85:
        bubble(d, box, rnd.choice(LINES), rnd)
    d.rectangle(box, outline=0, width=4)


def manga_page(n, rnd, series):
    page = Image.new("L", (W, H), 255)
    d = ImageDraw.Draw(page)
    aw, ah = W - 2 * M, H - 2 * M - 22
    for (a, b, c, e) in rnd.choice(LAYOUTS):
        box = (M + a * aw + (GAP / 2 if a else 0), M + b * ah + (GAP / 2 if b else 0),
               M + c * aw - (GAP / 2 if c < 1 else 0), M + e * ah - (GAP / 2 if e < 1 else 0))
        # Recorte para que nada se salga de la viñeta
        sub = Image.new("L", (W, H), 255)
        sd = ImageDraw.Draw(sub)
        panel(sub, sd, box, rnd)
        mask = Image.new("L", (W, H), 0)
        ImageDraw.Draw(mask).rectangle(box, fill=255)
        page.paste(sub, (0, 0), mask)
    foot = f"{series} · avance de muestra · pág. {n}"
    d.text(((W - d.textlength(foot, font=small_font)) / 2, H - M - 8), foot, font=small_font, fill=90)
    return page


def opening_page(cover_path, series):
    """Primera página a color: la portada difuminada de fondo con el título del capítulo."""
    cover = Image.open(cover_path).convert("RGB")
    bg = ImageOps.fit(cover, (W, H)).filter(ImageFilter.GaussianBlur(14))
    bg = Image.blend(bg, Image.new("RGB", (W, H), (20, 12, 30)), .35)
    art = ImageOps.contain(cover, (W - 160, H - 330))
    bg.paste(art, ((W - art.width) // 2, 70))
    d = ImageDraw.Draw(bg)
    y = 70 + art.height + 36
    for text, font in (("CAPÍTULO 1", title_font), (series, sub_font), ("Avance de muestra", small_font)):
        tw = d.textlength(text, font=font)
        d.text(((W - tw) / 2, y), text, font=font, fill=(255, 255, 255), stroke_width=3 if font is title_font else 0,
               stroke_fill=(0, 0, 0))
        y += font.size + 16
    return bg


for base, series in SERIES.items():
    rnd = random.Random(base)
    pages = [opening_page(covers / f"{base}.jpg", series)] + [manga_page(i, rnd, series) for i in range(2, 7)]
    for i, p in enumerate(pages, start=1):
        p.save(out / f"{base}-p{i:02d}.jpg", quality=68, optimize=True, progressive=True)
    print(base, len(pages))
