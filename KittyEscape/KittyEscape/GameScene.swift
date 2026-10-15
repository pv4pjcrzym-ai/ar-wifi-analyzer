import SpriteKit
import UIKit

extension Direction {
    /// Cat art faces up; SpriteKit rotates counterclockwise.
    var rotation: CGFloat {
        switch self {
        case .up: return 0
        case .right: return -.pi / 2
        case .down: return .pi
        case .left: return .pi / 2
        }
    }
}

final class GameScene: SKScene {
    unowned let session: GameSession

    private let boardNode = SKNode()
    private var catNodes: [Int: SKSpriteNode] = [:]
    private var textures: [Int: SKTexture] = [:]
    private var cellSize: CGFloat = 44
    private var origin = CGPoint.zero
    private var isReady = false

    // Room left for the SwiftUI HUD above and below the board.
    private static let topInset: CGFloat = 170
    private static let bottomInset: CGFloat = 130
    private static let sideInset: CGFloat = 16
    private static let hintName = "hint"

    init(session: GameSession) {
        self.session = session
        super.init(size: CGSize(width: 390, height: 844))
        scaleMode = .resizeFill
        anchorPoint = .zero
        backgroundColor = Palette.background
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        if boardNode.parent == nil { addChild(boardNode) }
        isReady = true
        rebuild(animated: true)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard isReady, oldSize != size else { return }
        rebuild(animated: false)
    }

    // MARK: - Board

    func rebuild(animated: Bool) {
        guard isReady, view != nil else { return }
        boardNode.removeAllActions()
        boardNode.removeAllChildren()
        boardNode.position = .zero
        catNodes.removeAll()

        let board = session.board
        let availableWidth = size.width - Self.sideInset * 2
        let availableHeight = size.height - Self.topInset - Self.bottomInset
        cellSize = floor(min(availableWidth / CGFloat(board.columns),
                             availableHeight / CGFloat(board.rows),
                             72))
        let boardSize = CGSize(width: cellSize * CGFloat(board.columns), height: cellSize * CGFloat(board.rows))
        let center = CGPoint(x: size.width / 2, y: Self.bottomInset + availableHeight / 2)
        origin = CGPoint(x: center.x - boardSize.width / 2 + cellSize / 2,
                         y: center.y - boardSize.height / 2 + cellSize / 2)

        let backing = SKShapeNode(rectOf: CGSize(width: boardSize.width + 16, height: boardSize.height + 16),
                                  cornerRadius: 24)
        backing.position = center
        backing.fillColor = Palette.boardBacking
        backing.strokeColor = .clear
        backing.zPosition = -2
        boardNode.addChild(backing)

        for col in 0..<board.columns {
            for row in 0..<board.rows {
                let tile = SKShapeNode(rectOf: CGSize(width: cellSize - 4, height: cellSize - 4),
                                       cornerRadius: cellSize * 0.22)
                tile.position = point(for: GridPoint(col: col, row: row))
                tile.fillColor = Palette.tile
                tile.strokeColor = .clear
                tile.zPosition = -1
                boardNode.addChild(tile)
            }
        }

        for cat in board.cats.values.sorted(by: { $0.id < $1.id }) {
            let node = makeCatNode(cat)
            boardNode.addChild(node)
            catNodes[cat.id] = node
            if animated {
                node.setScale(0)
                let delay = 0.02 * Double(cat.position.col + board.rows - cat.position.row)
                node.run(.sequence([
                    .wait(forDuration: delay),
                    .scale(to: 1.15, duration: 0.14),
                    .scale(to: 1, duration: 0.08),
                ]))
            }
        }
    }

    private func makeCatNode(_ cat: Cat) -> SKSpriteNode {
        let node = SKSpriteNode(texture: texture(forColor: cat.colorIndex))
        node.size = CGSize(width: cellSize, height: cellSize)
        node.position = point(for: cat.position)
        node.zRotation = cat.direction.rotation
        return node
    }

    private func texture(forColor index: Int) -> SKTexture? {
        if let cached = textures[index] { return cached }
        guard let view else { return nil }
        let texture = view.texture(from: CatArt.makeNode(color: Palette.catColor(index), size: 128))
        textures[index] = texture
        return texture
    }

    private func point(for gridPoint: GridPoint) -> CGPoint {
        CGPoint(x: origin.x + CGFloat(gridPoint.col) * cellSize,
                y: origin.y + CGFloat(gridPoint.row) * cellSize)
    }

    private func gridPoint(at location: CGPoint) -> GridPoint {
        GridPoint(col: Int(((location.x - origin.x) / cellSize).rounded()),
                  row: Int(((location.y - origin.y) / cellSize).rounded()))
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        switch session.tap(gridPoint(at: touch.location(in: self))) {
        case .escaped(let cat):
            animateEscape(cat)
        case .blocked(let cat, let blocker):
            animateBump(cat, blocker: blocker)
        case .empty:
            break
        }
    }

    // MARK: - Juice

    private func animateEscape(_ cat: Cat) {
        guard let node = catNodes.removeValue(forKey: cat.id) else { return }
        boardNode.childNode(withName: Self.hintName)?.removeFromParent()
        node.removeAllActions()
        node.position = point(for: cat.position)
        node.setScale(1)
        node.zPosition = 10

        let distance = max(size.width, size.height) + cellSize
        let move = SKAction.move(by: CGVector(dx: CGFloat(cat.direction.dx) * distance,
                                              dy: CGFloat(cat.direction.dy) * distance),
                                 duration: Double(distance / 1500))
        move.timingMode = .easeIn
        node.run(.sequence([
            .scale(to: 1.2, duration: 0.06),
            .group([move, .scale(to: 1, duration: 0.15)]),
            .removeFromParent(),
        ]))

        spawnPuff(at: node.position, color: Palette.catColor(cat.colorIndex))
        spawnHeart(at: node.position)
        Haptics.tap()

        if case .won = session.phase { celebrate() }
    }

    private func animateBump(_ cat: Cat, blocker: Cat) {
        guard let node = catNodes[cat.id] else { return }
        let home = point(for: cat.position)
        node.removeAction(forKey: "bump")
        node.position = home

        let cells = CGFloat(abs(blocker.position.col - cat.position.col) + abs(blocker.position.row - cat.position.row))
        let gap = (cells - 0.6) * cellSize
        let forward = SKAction.move(by: CGVector(dx: CGFloat(cat.direction.dx) * gap,
                                                 dy: CGFloat(cat.direction.dy) * gap),
                                    duration: 0.05 + 0.04 * Double(cells))
        forward.timingMode = .easeIn
        let back = SKAction.move(to: home, duration: 0.25)
        back.timingMode = .easeOut
        node.run(.sequence([forward, back]), withKey: "bump")
        node.run(.sequence([
            .colorize(with: .red, colorBlendFactor: 0.6, duration: 0.05),
            .colorize(withColorBlendFactor: 0, duration: 0.35),
        ]), withKey: "flash")

        if let blockerNode = catNodes[blocker.id] {
            let blockerHome = point(for: blocker.position)
            blockerNode.removeAction(forKey: "shake")
            blockerNode.position = blockerHome
            blockerNode.run(shake(amplitude: cellSize * 0.08, then: blockerHome), withKey: "shake")
        }

        boardNode.removeAction(forKey: "shake")
        boardNode.position = .zero
        boardNode.run(shake(amplitude: 5, then: .zero), withKey: "shake")
        Haptics.error()
    }

    private func shake(amplitude: CGFloat, then home: CGPoint) -> SKAction {
        var steps: [SKAction] = []
        for i in 0..<6 {
            let sign: CGFloat = i.isMultiple(of: 2) ? 1 : -1
            steps.append(.move(to: CGPoint(x: home.x + sign * amplitude, y: home.y), duration: 0.03))
        }
        steps.append(.move(to: home, duration: 0.03))
        return .sequence(steps)
    }

    func showHint(_ cat: Cat) {
        guard let node = catNodes[cat.id] else { return }
        boardNode.childNode(withName: Self.hintName)?.removeFromParent()

        let ring = SKShapeNode(circleOfRadius: cellSize * 0.52)
        ring.name = Self.hintName
        ring.strokeColor = Palette.hint
        ring.lineWidth = 4
        ring.glowWidth = 3
        ring.position = node.position
        ring.zPosition = 5
        boardNode.addChild(ring)

        let pulse = SKAction.sequence([.scale(to: 1.15, duration: 0.3), .scale(to: 0.95, duration: 0.3)])
        ring.run(.sequence([.repeat(pulse, count: 4), .fadeOut(withDuration: 0.2), .removeFromParent()]))
        node.run(.sequence([.repeat(pulse, count: 4), .scale(to: 1, duration: 0.1)]), withKey: "hint")
    }

    private func spawnPuff(at position: CGPoint, color: UIColor) {
        let count = 8
        for i in 0..<count {
            let angle = CGFloat(i) / CGFloat(count) * .pi * 2
            let dot = SKShapeNode(circleOfRadius: cellSize * 0.08)
            dot.fillColor = color
            dot.strokeColor = .clear
            dot.position = position
            dot.zPosition = 8
            boardNode.addChild(dot)
            let reach = cellSize * 0.6
            dot.run(.sequence([
                .group([
                    .moveBy(x: cos(angle) * reach, y: sin(angle) * reach, duration: 0.3),
                    .fadeOut(withDuration: 0.3),
                    .scale(to: 0.3, duration: 0.3),
                ]),
                .removeFromParent(),
            ]))
        }
    }

    private func spawnHeart(at position: CGPoint) {
        let heart = SKLabelNode(text: "♥")
        heart.fontName = "AvenirNext-Heavy"
        heart.fontSize = cellSize * 0.5
        heart.fontColor = Palette.heart
        heart.verticalAlignmentMode = .center
        heart.position = position
        heart.zPosition = 9
        boardNode.addChild(heart)
        heart.run(.sequence([
            .group([.moveBy(x: 0, y: cellSize, duration: 0.6), .fadeOut(withDuration: 0.6)]),
            .removeFromParent(),
        ]))
    }

    private func celebrate() {
        Haptics.success()
        for i in 0..<60 {
            let piece = SKShapeNode(rectOf: CGSize(width: 8, height: 14), cornerRadius: 2)
            piece.fillColor = Palette.confetti[i % Palette.confetti.count]
            piece.strokeColor = .clear
            piece.position = CGPoint(x: .random(in: 0...size.width), y: size.height + .random(in: 0...120))
            piece.zPosition = 50
            addChild(piece)
            let duration = TimeInterval.random(in: 1.6...2.8)
            piece.run(.sequence([
                .group([
                    .moveBy(x: .random(in: -80...80), y: -(size.height + 200), duration: duration),
                    .rotate(byAngle: .random(in: -8...8), duration: duration),
                ]),
                .removeFromParent(),
            ]))
        }
    }
}
