import UIKit

/// Draws a cat facing up. Used as a SpriteKit texture on the board and as an
/// image in the SwiftUI menus, so both always look the same.
enum CatArt {
    private static var cache: [String: UIImage] = [:]

    static func image(for breed: CatBreed, asleep: Bool = false, size: CGFloat = 128) -> UIImage {
        let key = "\(breed.id)-\(asleep)-\(Int(size))"
        if let cached = cache[key] { return cached }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { context in
            draw(breed, asleep: asleep, size: size, in: context.cgContext)
        }
        cache[key] = image
        return image
    }

    private static func draw(_ breed: CatBreed, asleep: Bool, size s: CGFloat, in ctx: CGContext) {
        // Origin in the middle and y pointing up, like SpriteKit.
        ctx.translateBy(x: s / 2, y: s / 2)
        ctx.scaleBy(x: 1, y: -1)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        let r = s * 0.33
        let fill = breed.color.cgColor
        let outline = breed.color.darker(0.3).cgColor
        // On dark fur the dark outline vanishes, so the direction mark goes light.
        let mark = breed.color.hsbBrightness < 0.5 ? UIColor.white.withAlphaComponent(0.85).cgColor : outline

        let tail = CGMutablePath()
        tail.move(to: CGPoint(x: 0, y: -r * 0.6))
        tail.addQuadCurve(to: CGPoint(x: r * 0.85, y: -r * 1.3), control: CGPoint(x: r * 0.95, y: -r * 0.7))
        stroke(tail, color: outline, width: r * 0.3, in: ctx)

        for side: CGFloat in [-1, 1] {
            let ear = CGMutablePath()
            ear.move(to: CGPoint(x: side * r * 0.25, y: r * 0.75))
            ear.addLine(to: CGPoint(x: side * r * 0.8, y: r * 1.28))
            ear.addLine(to: CGPoint(x: side * r * 0.95, y: r * 0.35))
            ear.closeSubpath()
            fillAndStroke(ear, fill: fill, stroke: outline, width: s * 0.03, in: ctx)

            let inner = CGMutablePath()
            inner.move(to: CGPoint(x: side * r * 0.45, y: r * 0.8))
            inner.addLine(to: CGPoint(x: side * r * 0.78, y: r * 1.1))
            inner.addLine(to: CGPoint(x: side * r * 0.85, y: r * 0.6))
            inner.closeSubpath()
            ctx.addPath(inner)
            ctx.setFillColor(Palette.heart.withAlphaComponent(0.6).cgColor)
            ctx.fillPath()
        }

        let bodyRect = CGRect(x: -r, y: -r, width: r * 2, height: r * 2)
        ctx.setFillColor(fill)
        ctx.fillEllipse(in: bodyRect)

        ctx.saveGState()
        ctx.addEllipse(in: bodyRect)
        ctx.clip()
        drawPattern(breed, radius: r, in: ctx)
        ctx.restoreGState()

        ctx.setStrokeColor(outline)
        ctx.setLineWidth(s * 0.035)
        ctx.strokeEllipse(in: bodyRect)

        for side: CGFloat in [-1, 1] {
            let center = CGPoint(x: side * r * 0.38, y: r * 0.22)
            if asleep {
                let lid = CGMutablePath()
                lid.move(to: CGPoint(x: center.x - r * 0.17, y: center.y))
                lid.addQuadCurve(to: CGPoint(x: center.x + r * 0.17, y: center.y),
                                 control: CGPoint(x: center.x, y: center.y - r * 0.16))
                stroke(lid, color: outline, width: s * 0.03, in: ctx)
            } else {
                let eye = CGRect(x: center.x - r * 0.22, y: center.y - r * 0.22, width: r * 0.44, height: r * 0.44)
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fillEllipse(in: eye)
                ctx.setStrokeColor(outline)
                ctx.setLineWidth(s * 0.015)
                ctx.strokeEllipse(in: eye)
                // Pupils sit toward the top so the cat looks where it will run.
                let pupil = CGRect(x: center.x - r * 0.11, y: center.y - r * 0.02, width: r * 0.22, height: r * 0.22)
                ctx.setFillColor(UIColor(white: 0.1, alpha: 1).cgColor)
                ctx.fillEllipse(in: pupil)
            }
        }

        let nose = CGMutablePath()
        nose.move(to: CGPoint(x: -r * 0.1, y: r * 0.02))
        nose.addLine(to: CGPoint(x: r * 0.1, y: r * 0.02))
        nose.addLine(to: CGPoint(x: 0, y: -r * 0.1))
        nose.closeSubpath()
        ctx.addPath(nose)
        ctx.setFillColor(Palette.heart.cgColor)
        ctx.fillPath()

        let mouth = CGMutablePath()
        mouth.move(to: CGPoint(x: -r * 0.24, y: -r * 0.14))
        mouth.addQuadCurve(to: CGPoint(x: 0, y: -r * 0.12), control: CGPoint(x: -r * 0.12, y: -r * 0.32))
        mouth.addQuadCurve(to: CGPoint(x: r * 0.24, y: -r * 0.14), control: CGPoint(x: r * 0.12, y: -r * 0.32))
        stroke(mouth, color: outline, width: s * 0.02, in: ctx)

        // Chevron on the forehead makes the running direction unmistakable.
        let chevron = CGMutablePath()
        chevron.move(to: CGPoint(x: -r * 0.26, y: r * 0.6))
        chevron.addLine(to: CGPoint(x: 0, y: r * 0.84))
        chevron.addLine(to: CGPoint(x: r * 0.26, y: r * 0.6))
        stroke(chevron, color: mark, width: r * 0.13, in: ctx)
    }

    private static func drawPattern(_ breed: CatBreed, radius r: CGFloat, in ctx: CGContext) {
        let color = breed.patternColor.cgColor
        switch breed.pattern {
        case .plain:
            break
        case .tabby:
            for side: CGFloat in [-1, 1] {
                for i in 0..<3 {
                    let y = r * (0.1 - CGFloat(i) * 0.28)
                    let stripe = CGMutablePath()
                    stripe.move(to: CGPoint(x: side * r * 1.05, y: y))
                    stripe.addLine(to: CGPoint(x: side * r * 0.68, y: y - r * 0.05))
                    stroke(stripe, color: color, width: r * 0.12, in: ctx)
                }
            }
        case .patch:
            ctx.setFillColor(color)
            ctx.fillEllipse(in: CGRect(x: r * 0.02, y: -r * 0.12, width: r * 1.0, height: r * 1.0))
        }
    }

    private static func stroke(_ path: CGPath, color: CGColor, width: CGFloat, in ctx: CGContext) {
        ctx.addPath(path)
        ctx.setStrokeColor(color)
        ctx.setLineWidth(width)
        ctx.strokePath()
    }

    private static func fillAndStroke(_ path: CGPath, fill: CGColor, stroke: CGColor, width: CGFloat, in ctx: CGContext) {
        ctx.addPath(path)
        ctx.setFillColor(fill)
        ctx.setStrokeColor(stroke)
        ctx.setLineWidth(width)
        ctx.drawPath(using: .fillStroke)
    }
}
