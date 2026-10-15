import SpriteKit
import UIKit

/// Vector cat drawn facing up. The scene renders it once per color to a texture.
enum CatArt {
    static func makeNode(color: UIColor, size s: CGFloat) -> SKNode {
        let root = SKNode()
        let outline = color.darker(0.3)
        let r = s * 0.33

        // Invisible square keeps the rendered texture centered on the body.
        let frame = SKShapeNode(rectOf: CGSize(width: s, height: s))
        frame.fillColor = .clear
        frame.strokeColor = .clear
        frame.lineWidth = 0
        root.addChild(frame)

        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: 0, y: -r * 0.6))
        tailPath.addQuadCurve(to: CGPoint(x: r * 0.85, y: -r * 1.3), control: CGPoint(x: r * 0.95, y: -r * 0.7))
        let tail = SKShapeNode(path: tailPath)
        tail.strokeColor = outline
        tail.lineWidth = r * 0.3
        tail.lineCap = .round
        tail.zPosition = -0.2
        root.addChild(tail)

        for side: CGFloat in [-1, 1] {
            let earPath = CGMutablePath()
            earPath.move(to: CGPoint(x: side * r * 0.25, y: r * 0.75))
            earPath.addLine(to: CGPoint(x: side * r * 0.8, y: r * 1.28))
            earPath.addLine(to: CGPoint(x: side * r * 0.95, y: r * 0.35))
            earPath.closeSubpath()
            let ear = SKShapeNode(path: earPath)
            ear.fillColor = color
            ear.strokeColor = outline
            ear.lineWidth = s * 0.03
            ear.lineJoin = .round
            ear.zPosition = -0.1
            root.addChild(ear)
        }

        let body = SKShapeNode(circleOfRadius: r)
        body.fillColor = color
        body.strokeColor = outline
        body.lineWidth = s * 0.035
        root.addChild(body)

        for side: CGFloat in [-1, 1] {
            let eye = SKShapeNode(circleOfRadius: r * 0.22)
            eye.fillColor = .white
            eye.strokeColor = outline
            eye.lineWidth = s * 0.015
            eye.position = CGPoint(x: side * r * 0.38, y: r * 0.22)
            eye.zPosition = 0.1
            root.addChild(eye)

            // Pupils sit toward the top so the cat looks where it will run.
            let pupil = SKShapeNode(circleOfRadius: r * 0.11)
            pupil.fillColor = UIColor(white: 0.1, alpha: 1)
            pupil.strokeColor = .clear
            pupil.position = CGPoint(x: side * r * 0.38, y: r * 0.31)
            pupil.zPosition = 0.2
            root.addChild(pupil)
        }

        let nosePath = CGMutablePath()
        nosePath.move(to: CGPoint(x: -r * 0.1, y: r * 0.02))
        nosePath.addLine(to: CGPoint(x: r * 0.1, y: r * 0.02))
        nosePath.addLine(to: CGPoint(x: 0, y: -r * 0.1))
        nosePath.closeSubpath()
        let nose = SKShapeNode(path: nosePath)
        nose.fillColor = Palette.heart
        nose.strokeColor = .clear
        nose.zPosition = 0.1
        root.addChild(nose)

        // Smile under the nose.
        let mouthPath = CGMutablePath()
        mouthPath.move(to: CGPoint(x: -r * 0.24, y: -r * 0.14))
        mouthPath.addQuadCurve(to: CGPoint(x: 0, y: -r * 0.12), control: CGPoint(x: -r * 0.12, y: -r * 0.32))
        mouthPath.addQuadCurve(to: CGPoint(x: r * 0.24, y: -r * 0.14), control: CGPoint(x: r * 0.12, y: -r * 0.32))
        let mouth = SKShapeNode(path: mouthPath)
        mouth.strokeColor = outline
        mouth.lineWidth = s * 0.02
        mouth.lineCap = .round
        mouth.zPosition = 0.1
        root.addChild(mouth)

        // Chevron on the forehead makes the running direction unmistakable.
        let chevronPath = CGMutablePath()
        chevronPath.move(to: CGPoint(x: -r * 0.26, y: r * 0.6))
        chevronPath.addLine(to: CGPoint(x: 0, y: r * 0.84))
        chevronPath.addLine(to: CGPoint(x: r * 0.26, y: r * 0.6))
        let chevron = SKShapeNode(path: chevronPath)
        chevron.strokeColor = outline
        chevron.lineWidth = r * 0.13
        chevron.lineCap = .round
        chevron.lineJoin = .round
        chevron.zPosition = 0.1
        root.addChild(chevron)

        return root
    }
}
