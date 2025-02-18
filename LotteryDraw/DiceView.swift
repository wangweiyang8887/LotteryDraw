import SwiftUI
import SceneKit
import simd

struct DiceView: View {
    @State private var diceNumbers: [Int] = [1]  // 改为数组存储多个骰子的点数
    @State private var isAnimating = false
    @State private var numberOfDice = 1  // 控制骰子数量
    @StateObject private var diceScene = DiceSceneController()
    
    var body: some View {
        VStack(spacing: 40) {
            // 骰子数量控制
            Stepper("骰子数量: \(numberOfDice)", value: $numberOfDice, in: 1...6)
                .padding(.horizontal)
                .onChange(of: numberOfDice) { _, newValue in
                    diceScene.updateDiceCount(to: newValue)
                    diceNumbers = Array(repeating: 1, count: newValue)
                }
            
            // 3D 骰子显示
            ZStack {
                Color(UIColor.systemBackground)
                    .opacity(0.0)
                
                SceneView(
                    scene: diceScene.scene,
                    pointOfView: diceScene.cameraNode,
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                )
                .background(Color.clear)
            }
            .frame(width: 300, height: 300)
            .background(Color.clear)
            
            // 点数显示
            HStack(spacing: 15) {
                ForEach(diceNumbers.indices, id: \.self) { index in
                    Text("\(diceNumbers[index])")
                        .font(.title2.bold())
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(radius: 2)
                        )
                }
            }
            
            // 摇骰子按钮
            Button(action: rollDice) {
                HStack(spacing: 10) {
                    Image(systemName: "dice.fill")
                    Text("摇骰子")
                }
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(width: 200)
                .padding()
                .background(
                    Capsule()
                        .fill(isAnimating ? .gray : .blue)
                        .shadow(radius: 5)
                )
            }
            .disabled(isAnimating)
        }
        .padding()
    }
    
    private func rollDice() {
        guard !isAnimating else { return }
        isAnimating = true
        diceScene.rollAllDice { numbers in
            diceNumbers = numbers
            isAnimating = false
        }
    }
}

// 骰子场景控制器
class DiceSceneController: ObservableObject {
    let scene: SCNScene
    let cameraNode: SCNNode
    private var diceNodes: [SCNNode] = []
    private let floorNode: SCNNode
    private var isWrapping = false
    private let boundarySize: Float = 3.0
    
    init() {
        // 1. 初始化场景
        scene = SCNScene()
        scene.physicsWorld.gravity = SCNVector3(0, -20, 0) // 增加重力使骰子更快落地
        
        // 2. 创建地板
        let floorGeometry = SCNFloor()
        floorGeometry.reflectivity = 0.0
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.clear
        floorMaterial.transparency = 0.0
        floorMaterial.writesToDepthBuffer = true
        floorMaterial.readsFromDepthBuffer = true
        floorGeometry.materials = [floorMaterial]
        
        floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, -0.5, 0) // 调整地板位置
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        floorNode.physicsBody?.friction = 0.8 // 增加摩擦力
        floorNode.physicsBody?.restitution = 0.2 // 减少反弹
        
        // 3. 设置相机
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 4, z: 6) // 调整相机位置
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi/4, y: 0, z: 0) // 调整相机角度
        
        // 4. 添加基础节点到场景
        scene.rootNode.addChildNode(floorNode)
        scene.rootNode.addChildNode(cameraNode)
        
        // 5. 设置环境
        setupEnvironment()
        scene.background.contents = UIColor.clear
        
        // 6. 添加第一个骰子
        addDice()
        
        // 7. 添加位置监听
        setupPositionMonitoring()
    }
    
    private func setupPositionMonitoring() {
        // 不再需要位置监听
    }
    
    @objc private func checkDicePosition() {
        // 不再需要检查位置
    }
    
    private func wrapDice(_ diceNode: SCNNode, to newPosition: SCNVector3) {
        // 不再需要包装位置
    }
    
    func rollAllDice(completion: @escaping ([Int]) -> Void) {
        for node in diceNodes {
            // 重置骰子位置和旋转
            node.position = getInitialPosition(for: diceNodes.firstIndex(of: node) ?? 0)
            node.eulerAngles = SCNVector3Zero
            
            // 只在 X-Z 平面上施加力
            let horizontalForce = Float.random(in: 2...4)
            let angle = Float.random(in: 0...(2 * .pi))
            let force = SCNVector3(
                horizontalForce * cos(angle), // X方向
                1, // 轻微向上力
                horizontalForce * sin(angle)  // Z方向
            )
            
            // 减小扭矩，主要在Y轴上旋转
            let torque = SCNVector4(
                Float.random(in: -0.3...0.3),
                Float.random(in: -1...1),
                Float.random(in: -0.3...0.3),
                Float.random(in: 5...8)
            )
            
            node.physicsBody?.resetTransform()
            node.physicsBody?.applyForce(force, asImpulse: true)
            node.physicsBody?.applyTorque(torque, asImpulse: true)
        }
        
        // 缩短等待时间
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let numbers = self.diceNodes.map { self.determineUpFacingNumber(for: $0) }
            completion(numbers)
        }
    }
    
    // 静态方法创建骰子材质
    private static func createDiceMaterials() -> [SCNMaterial] {
        return (1...6).map { number in
            let material = SCNMaterial()
            material.diffuse.contents = createDiceFaceImage(number: number)
            material.locksAmbientWithDiffuse = true
            return material
        }
    }
    
    // 静态方法创建骰子面图像
    private static func createDiceFaceImage(number: Int) -> UIImage {
        let size = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // 白色背景
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 黑色点数
            UIColor.black.setFill()
            let dotPositions = getDotPositions(for: number, in: size)
            let dotSize = CGSize(width: 40, height: 40)
            
            for position in dotPositions {
                let rect = CGRect(
                    x: position.x - dotSize.width/2,
                    y: position.y - dotSize.height/2,
                    width: dotSize.width,
                    height: dotSize.height
                )
                context.cgContext.fillEllipse(in: rect)
            }
        }
    }
    
    // 静态方法获取点的位置
    private static func getDotPositions(for number: Int, in size: CGSize) -> [CGPoint] {
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let offset: CGFloat = 60
        
        switch number {
        case 1:
            return [center]
        case 2:
            return [
                CGPoint(x: center.x - offset, y: center.y - offset),
                CGPoint(x: center.x + offset, y: center.y + offset)
            ]
        case 3:
            return [
                CGPoint(x: center.x - offset, y: center.y - offset),
                center,
                CGPoint(x: center.x + offset, y: center.y + offset)
            ]
        case 4:
            return [
                CGPoint(x: center.x - offset, y: center.y - offset),
                CGPoint(x: center.x + offset, y: center.y - offset),
                CGPoint(x: center.x - offset, y: center.y + offset),
                CGPoint(x: center.x + offset, y: center.y + offset)
            ]
        case 5:
            return [
                CGPoint(x: center.x - offset, y: center.y - offset),
                CGPoint(x: center.x + offset, y: center.y - offset),
                center,
                CGPoint(x: center.x - offset, y: center.y + offset),
                CGPoint(x: center.x + offset, y: center.y + offset)
            ]
        case 6:
            return [
                CGPoint(x: center.x - offset, y: center.y - offset),
                CGPoint(x: center.x + offset, y: center.y - offset),
                CGPoint(x: center.x - offset, y: center.y),
                CGPoint(x: center.x + offset, y: center.y),
                CGPoint(x: center.x - offset, y: center.y + offset),
                CGPoint(x: center.x + offset, y: center.y + offset)
            ]
        default:
            return []
        }
    }
    
    private func setupEnvironment() {
        // 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 100
        scene.rootNode.addChildNode(ambientLight)
        
        // 定向光
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 800
        directionalLight.position = SCNVector3(x: 5, y: 5, z: 5)
        directionalLight.eulerAngles = SCNVector3(x: -Float.pi/4, y: Float.pi/4, z: 0)
        scene.rootNode.addChildNode(directionalLight)
    }
    
    private func determineUpFacingNumber(for diceNode: SCNNode) -> Int {
        // 获取骰子的旋转矩阵
        let rotation = diceNode.presentation.simdTransform
        
        // 计算Y轴（向上）方向在世界空间中的方向
        let column1 = rotation.columns.1
        let upVector = simd_normalize(SIMD3<Float>(column1.x, column1.y, column1.z))
        
        // 确定哪个面朝上
        let dotProducts = [
            simd_dot(upVector, SIMD3<Float>(0, 1, 0)),   // 顶面 (1)
            simd_dot(upVector, SIMD3<Float>(0, -1, 0)),  // 底面 (6)
            simd_dot(upVector, SIMD3<Float>(1, 0, 0)),   // 右面 (3)
            simd_dot(upVector, SIMD3<Float>(-1, 0, 0)),  // 左面 (4)
            simd_dot(upVector, SIMD3<Float>(0, 0, 1)),   // 前面 (2)
            simd_dot(upVector, SIMD3<Float>(0, 0, -1))   // 后面 (5)
        ]
        
        // 找到最大点积对应的面
        if let maxIndex = dotProducts.enumerated().max(by: { $0.1 < $1.1 })?.offset {
            // 返回对应的点数
            return [1, 6, 3, 4, 2, 5][maxIndex]
        }
        
        return Int.random(in: 1...6)
    }
    
    // 获取新骰子的初始位置
    private func getInitialPosition(for index: Int) -> SCNVector3 {
        let spacing: Float = 1.5 // 增加间距
        let offset = Float(index - (diceNodes.count) / 2) * spacing
        return SCNVector3(offset, 0.5, 0) // 降低初始高度
    }
    
    // 更新骰子数量
    func updateDiceCount(to count: Int) {
        // 移除多余的骰子
        while diceNodes.count > count {
            let node = diceNodes.removeLast()
            node.removeFromParentNode()
        }
        
        // 添加缺少的骰子
        while diceNodes.count < count {
            addDice()
        }
        
        // 重新排列所有骰子的位置
        for (index, node) in diceNodes.enumerated() {
            node.position = getInitialPosition(for: index)
        }
    }
    
    // 添加单个骰子
    private func addDice() {
        let diceGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        diceGeometry.materials = Self.createDiceMaterials()
        
        let diceNode = SCNNode(geometry: diceGeometry)
        let initialPosition = getInitialPosition(for: diceNodes.count)
        diceNode.position = initialPosition
        
        // 修改物理属性
        let shape = SCNPhysicsShape(geometry: diceGeometry, options: [
            SCNPhysicsShape.Option.keepAsCompound: true
        ])
        diceNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        diceNode.physicsBody?.mass = 1.0
        diceNode.physicsBody?.friction = 0.7 // 增加摩擦力
        diceNode.physicsBody?.restitution = 0.3
        diceNode.physicsBody?.angularDamping = 0.4 // 增加角度阻尼
        diceNode.physicsBody?.damping = 0.4 // 增加线性阻尼
        
        diceNodes.append(diceNode)
        scene.rootNode.addChildNode(diceNode)
    }
} 
