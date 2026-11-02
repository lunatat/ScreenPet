import AppKit

// Draws the ScreenPet example artwork as transparent 512x512 PNGs.
// Usage: swift Tools/draw-example-art.swift Assets

enum Mood { case happy, neutral, sad }

let size = 512
func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: a)
}

func render(_ path: String, _ draw: (CGContext) -> Void) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!.cgContext
    ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))
    // Flip so y grows downward, like the reference art.
    ctx.translateBy(x: 0, y: CGFloat(size)); ctx.scaleBy(x: 1, y: -1)
    ctx.setLineCap(.round); ctx.setLineJoin(.round)
    draw(ctx)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

func radial(_ ctx: CGContext, clip: CGPath, center: CGPoint, radius: CGFloat, colors: [CGColor]) {
    ctx.saveGState(); ctx.addPath(clip); ctx.clip()
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
    ctx.drawRadialGradient(g, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [.drawsAfterEndLocation])
    ctx.restoreGState()
}

func feet(_ ctx: CGContext, color: CGColor, y: CGFloat = 410, spread: CGFloat = 58) {
    for x in [256 - spread, 256 + spread] {
        let r = CGRect(x: x - 30, y: y - 14, width: 60, height: 30)
        ctx.setFillColor(color); ctx.fillEllipse(in: r)
        ctx.setFillColor(rgb(255, 255, 255, 0.25)); ctx.fillEllipse(in: CGRect(x: x - 18, y: y - 10, width: 26, height: 9))
    }
}

func face(_ ctx: CGContext, _ mood: Mood, cx: CGFloat = 256, cy: CGFloat = 270, ink: CGColor = rgb(30, 30, 40)) {
    let eyeDX: CGFloat = 52
    // Blush
    ctx.setFillColor(rgb(255, 120, 130, 0.45))
    for s in [-1.0, 1.0] { ctx.fillEllipse(in: CGRect(x: cx + s * 78 - 20, y: cy + 14, width: 40, height: 20)) }
    ctx.setStrokeColor(ink); ctx.setFillColor(ink)
    switch mood {
    case .happy:
        // Closed, smiling eyes
        ctx.setLineWidth(9)
        for s in [-1.0, 1.0] {
            ctx.addArc(center: CGPoint(x: cx + s * eyeDX, y: cy + 4), radius: 18, startAngle: .pi * 1.1, endAngle: .pi * 1.9, clockwise: false)
            ctx.strokePath()
        }
        // Open smile
        let m = CGMutablePath()
        m.move(to: CGPoint(x: cx - 30, y: cy + 28))
        m.addQuadCurve(to: CGPoint(x: cx + 30, y: cy + 28), control: CGPoint(x: cx, y: cy + 30))
        m.addQuadCurve(to: CGPoint(x: cx - 30, y: cy + 28), control: CGPoint(x: cx, y: cy + 92))
        ctx.addPath(m); ctx.fillPath()
        ctx.saveGState(); ctx.addPath(m); ctx.clip()
        ctx.setFillColor(rgb(240, 100, 110)); ctx.fillEllipse(in: CGRect(x: cx - 22, y: cy + 52, width: 44, height: 30))
        ctx.restoreGState()
    case .neutral, .sad:
        // Round eyes with highlights
        for s in [-1.0, 1.0] {
            let e = CGRect(x: cx + s * eyeDX - 17, y: cy - 22, width: 34, height: 40)
            ctx.setFillColor(ink); ctx.fillEllipse(in: e)
            if mood == .sad {
                ctx.setFillColor(rgb(70, 110, 200, 0.8)); ctx.fillEllipse(in: CGRect(x: e.minX + 5, y: e.midY, width: 24, height: 16))
            }
            ctx.setFillColor(rgb(255, 255, 255)); ctx.fillEllipse(in: CGRect(x: e.minX + 6, y: e.minY + 6, width: 12, height: 12))
            ctx.fillEllipse(in: CGRect(x: e.maxX - 13, y: e.maxY - 15, width: 6, height: 6))
        }
        ctx.setStrokeColor(ink); ctx.setLineWidth(7)
        if mood == .sad {
            // Worried brows, frown, tear
            for s in [-1.0, 1.0] {
                ctx.move(to: CGPoint(x: cx + s * (eyeDX + 18), y: cy - 34))
                ctx.addLine(to: CGPoint(x: cx + s * (eyeDX - 14), y: cy - 46))
                ctx.strokePath()
            }
            ctx.move(to: CGPoint(x: cx - 18, y: cy + 46))
            ctx.addQuadCurve(to: CGPoint(x: cx + 18, y: cy + 46), control: CGPoint(x: cx, y: cy + 28))
            ctx.strokePath()
            let t = CGMutablePath()
            let tx = cx + eyeDX + 4, ty = cy + 24
            t.move(to: CGPoint(x: tx, y: ty))
            t.addQuadCurve(to: CGPoint(x: tx + 11, y: ty + 26), control: CGPoint(x: tx + 12, y: ty + 12))
            t.addArc(center: CGPoint(x: tx, y: ty + 26), radius: 11, startAngle: 0, endAngle: .pi, clockwise: false)
            t.addQuadCurve(to: CGPoint(x: tx, y: ty), control: CGPoint(x: tx - 12, y: ty + 12))
            ctx.addPath(t); ctx.setFillColor(rgb(120, 190, 255)); ctx.fillPath()
        } else {
            // Calm, sleepy lids and a small flat smile
            for s in [-1.0, 1.0] {
                ctx.move(to: CGPoint(x: cx + s * eyeDX - 20, y: cy - 20))
                ctx.addLine(to: CGPoint(x: cx + s * eyeDX + 20, y: cy - 20))
                ctx.strokePath()
            }
            ctx.move(to: CGPoint(x: cx - 16, y: cy + 40))
            ctx.addQuadCurve(to: CGPoint(x: cx + 16, y: cy + 40), control: CGPoint(x: cx, y: cy + 46))
            ctx.strokePath()
        }
    }
}

// MARK: Basketball (Valkyries example: violet feet, no team marks)

func basketball(_ mood: Mood) -> (CGContext) -> Void {
    return { ctx in
        let ball = CGRect(x: 96, y: 96, width: 320, height: 320)
        ctx.setFillColor(rgb(0, 0, 0, 0.12)); ctx.fillEllipse(in: CGRect(x: 150, y: 418, width: 212, height: 22))
        feet(ctx, color: rgb(84, 46, 140))
        let clip = CGPath(ellipseIn: ball, transform: nil)
        radial(ctx, clip: clip, center: CGPoint(x: 210, y: 180), radius: 280,
               colors: [rgb(255, 178, 92), rgb(240, 126, 38), rgb(196, 86, 20)])
        ctx.saveGState(); ctx.addPath(clip); ctx.clip()
        ctx.setStrokeColor(rgb(70, 35, 15)); ctx.setLineWidth(7)
        ctx.move(to: CGPoint(x: 96, y: 256)); ctx.addLine(to: CGPoint(x: 416, y: 256)); ctx.strokePath()
        ctx.move(to: CGPoint(x: 256, y: 96)); ctx.addLine(to: CGPoint(x: 256, y: 416)); ctx.strokePath()
        ctx.move(to: CGPoint(x: 150, y: 110)); ctx.addQuadCurve(to: CGPoint(x: 150, y: 402), control: CGPoint(x: 230, y: 256)); ctx.strokePath()
        ctx.move(to: CGPoint(x: 362, y: 110)); ctx.addQuadCurve(to: CGPoint(x: 362, y: 402), control: CGPoint(x: 282, y: 256)); ctx.strokePath()
        ctx.restoreGState()
        ctx.setStrokeColor(rgb(150, 70, 20)); ctx.setLineWidth(3); ctx.strokeEllipse(in: ball)
        // Face sits on a soft patch so it reads over the seams
        ctx.setFillColor(rgb(250, 150, 66, 0.9)); ctx.fillEllipse(in: CGRect(x: 168, y: 214, width: 176, height: 124))
        face(ctx, mood, cy: 276)
    }
}

// MARK: Weather

func cloudPath(_ rect: CGRect) -> CGPath {
    let p = CGMutablePath()
    let w = rect.width, h = rect.height, x = rect.minX, y = rect.minY
    p.addEllipse(in: CGRect(x: x, y: y + h * 0.42, width: w * 0.36, height: h * 0.56))
    p.addEllipse(in: CGRect(x: x + w * 0.16, y: y + h * 0.12, width: w * 0.42, height: h * 0.70))
    p.addEllipse(in: CGRect(x: x + w * 0.42, y: y, width: w * 0.40, height: h * 0.72))
    p.addEllipse(in: CGRect(x: x + w * 0.64, y: y + h * 0.36, width: w * 0.36, height: h * 0.60))
    p.addRoundedRect(in: CGRect(x: x + w * 0.12, y: y + h * 0.5, width: w * 0.76, height: h * 0.48), cornerWidth: h * 0.22, cornerHeight: h * 0.22)
    return p
}

func sun(_ ctx: CGContext) {
    let c = CGPoint(x: 256, y: 250)
    ctx.setFillColor(rgb(0, 0, 0, 0.10)); ctx.fillEllipse(in: CGRect(x: 160, y: 432, width: 192, height: 20))
    feet(ctx, color: rgb(232, 120, 30), y: 420, spread: 52)
    ctx.setFillColor(rgb(255, 196, 40))
    for i in 0..<12 {
        let a = CGFloat(i) / 12 * 2 * .pi
        let ray = CGMutablePath()
        ray.move(to: CGPoint(x: c.x + cos(a - 0.13) * 150, y: c.y + sin(a - 0.13) * 150))
        ray.addLine(to: CGPoint(x: c.x + cos(a) * 225, y: c.y + sin(a) * 225))
        ray.addLine(to: CGPoint(x: c.x + cos(a + 0.13) * 150, y: c.y + sin(a + 0.13) * 150))
        ray.closeSubpath()
        ctx.addPath(ray); ctx.fillPath()
    }
    let disc = CGRect(x: c.x - 160, y: c.y - 160, width: 320, height: 320)
    radial(ctx, clip: CGPath(ellipseIn: disc, transform: nil), center: CGPoint(x: 210, y: 190), radius: 260,
           colors: [rgb(255, 240, 140), rgb(255, 205, 50), rgb(250, 160, 30)])
    face(ctx, .happy, cy: 262)
}

func fogCloud(_ ctx: CGContext) {
    ctx.setFillColor(rgb(0, 0, 0, 0.08)); ctx.fillEllipse(in: CGRect(x: 150, y: 420, width: 212, height: 20))
    feet(ctx, color: rgb(120, 128, 145), y: 408, spread: 62)
    let body = cloudPath(CGRect(x: 66, y: 120, width: 380, height: 290))
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [rgb(250, 251, 253), rgb(214, 220, 230)] as CFArray, locations: nil)!
    ctx.saveGState(); ctx.addPath(body); ctx.clip()
    ctx.drawLinearGradient(g, start: CGPoint(x: 256, y: 120), end: CGPoint(x: 256, y: 410), options: [])
    ctx.restoreGState()
    face(ctx, .neutral, cy: 292, ink: rgb(60, 66, 82))
    // Drifting fog bands in front of the cloud
    ctx.setLineWidth(18)
    for (y, x0, x1, a) in [(352.0, 40.0, 300.0, 0.9), (392.0, 190.0, 476.0, 0.85), (432.0, 80.0, 360.0, 0.8)] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        ctx.setStrokeColor(rgb(200, 207, 220, a))
        ctx.move(to: CGPoint(x: x0, y: y))
        ctx.addCurve(to: CGPoint(x: x1, y: y), control1: CGPoint(x: x0 + (x1 - x0) * 0.33, y: y - 14), control2: CGPoint(x: x0 + (x1 - x0) * 0.66, y: y + 14))
        ctx.strokePath()
    }
}

func rainCloud(_ ctx: CGContext) {
    feet(ctx, color: rgb(60, 72, 100), y: 360, spread: 62)
    // Raindrops
    ctx.setFillColor(rgb(90, 160, 240))
    for (x, y) in [(120.0, 400.0), (180.0, 450.0), (250.0, 410.0), (320.0, 460.0), (390.0, 405.0), (150.0, 490.0), (360.0, 495.0)] as [(CGFloat, CGFloat)] {
        let d = CGMutablePath()
        d.move(to: CGPoint(x: x, y: y - 20))
        d.addQuadCurve(to: CGPoint(x: x + 9, y: y + 2), control: CGPoint(x: x + 9, y: y - 8))
        d.addArc(center: CGPoint(x: x, y: y + 2), radius: 9, startAngle: 0, endAngle: .pi, clockwise: false)
        d.addQuadCurve(to: CGPoint(x: x, y: y - 20), control: CGPoint(x: x - 9, y: y - 8))
        ctx.addPath(d); ctx.fillPath()
    }
    let body = cloudPath(CGRect(x: 66, y: 80, width: 380, height: 290))
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [rgb(176, 188, 206), rgb(120, 134, 158)] as CFArray, locations: nil)!
    ctx.saveGState(); ctx.addPath(body); ctx.clip()
    ctx.drawLinearGradient(g, start: CGPoint(x: 256, y: 80), end: CGPoint(x: 256, y: 370), options: [])
    ctx.restoreGState()
    face(ctx, .sad, cy: 252, ink: rgb(30, 36, 54))
}

let out = CommandLine.arguments[1]
render("\(out)/Basketball/positive.png", basketball(.happy))
render("\(out)/Basketball/neutral.png", basketball(.neutral))
render("\(out)/Basketball/negative.png", basketball(.sad))
render("\(out)/Weather/positive.png", sun)
render("\(out)/Weather/neutral.png", fogCloud)
render("\(out)/Weather/negative.png", rainCloud)
print("Wrote artwork to \(out)")
