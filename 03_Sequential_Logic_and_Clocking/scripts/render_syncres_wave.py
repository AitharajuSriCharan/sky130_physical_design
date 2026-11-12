import sys
from PIL import Image, ImageDraw, ImageFont

# Canvas dimensions
width, height = 1100, 380
img = Image.new('RGB', (width, height), color=(13, 17, 23))
draw = ImageDraw.Draw(img)

signals = ['clk', 'sync_reset', 'd', 'q']
l_margin = 150
r_margin = 50
plot_w = width - l_margin - r_margin

def t2x(t):
    return l_margin + int(t * plot_w / 90.0)

# Grid & Time ruler
for t in range(0, 95, 5):
    x = t2x(t)
    grid_col = (40, 50, 65) if t % 10 == 0 else (25, 32, 42)
    draw.line([(x, 40), (x, height - 30)], fill=grid_col, width=1)
    if t % 10 == 0:
        draw.text((x - 12, 18), f"{t}ns", fill=(140, 160, 185))

trace_defs = {
    'clk': [(0,0), (5,1), (10,0), (15,1), (20,0), (25,1), (30,0), (35,1), (40,0), (45,1), (50,0), (55,1), (60,0), (65,1), (70,0), (75,1), (80,0), (85,1), (90,0)],
    'sync_reset': [(0,1), (12,0), (57,1), (72,0), (90,0)],
    'd': [(0,0), (20,1), (30,0), (40,1), (90,1)],
    'q': [(0,'x'), (5,0), (25,1), (35,0), (45,1), (65,0), (75,1), (90,1)]
}

y_start = 75
row_h = 70

for i, sig in enumerate(signals):
    y_base = y_start + i * row_h
    y_high = y_base - 35
    y_low = y_base
    draw.text((25, y_high + 8), sig, fill=(220, 235, 255))
    draw.line([(l_margin, y_low + 5), (width - r_margin, y_low + 5)], fill=(30, 40, 55), width=1)
    
    events = trace_defs[sig]
    for j in range(len(events) - 1):
        t1, val1 = events[j]
        t2, val2 = events[j+1]
        x1, x2 = t2x(t1), t2x(t2)
        
        if val1 == 'x':
            draw.line([(x1, y_high), (x2, y_high)], fill=(240, 70, 70), width=2)
            draw.line([(x1, y_low), (x2, y_low)], fill=(240, 70, 70), width=2)
            for hx in range(x1, x2, 6):
                draw.line([(hx, y_low), (hx + 4, y_high)], fill=(190, 50, 50), width=1)
            draw.line([(x2, y_high), (x2, y_low)], fill=(0, 255, 130), width=2)
        else:
            y_curr = y_high if val1 == 1 else y_low
            y_next = y_high if val2 == 1 else y_low
            draw.line([(x1, y_curr), (x2, y_curr)], fill=(0, 255, 130), width=2)
            if val1 != val2:
                draw.line([(x2, y_curr), (x2, y_next)], fill=(0, 255, 130), width=2)

# Latency Highlight Window (57ns -> 65ns)
x_57 = t2x(57)
x_65 = t2x(65)

# Shaded background box for latency
overlay = Image.new('RGBA', (width, height), (0,0,0,0))
ov_draw = ImageDraw.Draw(overlay)
ov_draw.rectangle([x_57, 40, x_65, height - 30], fill=(255, 180, 0, 35))
img = Image.alpha_composite(img.convert('RGBA'), overlay).convert('RGB')
draw = ImageDraw.Draw(img)

# Marker lines
draw.line([(x_57, 40), (x_57, height - 30)], fill=(255, 170, 0), width=2)
draw.line([(x_65, 40), (x_65, height - 30)], fill=(0, 210, 255), width=2)

# Text labels
draw.text((x_57 - 45, height - 25), "Reset at 57ns", fill=(255, 170, 0))
draw.text((x_65 - 45, height - 25), "Posedge at 65ns", fill=(0, 210, 255))
draw.text((x_57 + 6, y_start + 3 * row_h - 45), "<-- 8ns Synchronous Latency (Q holds 1!) -->", fill=(255, 230, 80))
draw.text((t2x(1), y_start + 3 * row_h - 45), "Uninitialized (X)", fill=(240, 80, 80))

out_path = "/home/aravi/sky130_physical_design/03_Sequential_Logic_and_Clocking/docs/images/dff_syncres_waveform_gtkwave.png"
img.save(out_path)
print(f"Successfully rendered: {out_path}")
