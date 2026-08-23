// Hai fatto? — ConfettiView
import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var xVelocity: CGFloat
    var yVelocity: CGFloat
    var size: CGFloat
    var color: Color
    var shapeType: Int // 0: circle, 1: rectangle, 2: triangle
    var rotation: Double
    var rotationVelocity: Double
}

struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .mint]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiShape(type: particle.shapeType)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .ignoresSafeArea()
            .onChange(of: isActive) { oldValue, newValue in
                if newValue {
                    fireConfetti(in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func fireConfetti(in size: CGSize) {
        let count = Int.random(in: 50...80)
        var newParticles = [ConfettiParticle]()
        
        let startX = size.width / 2
        let startY = -20.0
        
        for _ in 0..<count {
            let xVel = CGFloat.random(in: -300...300)
            let yVel = CGFloat.random(in: 100...400)
            let pSize = CGFloat.random(in: 4...8)
            let color = colors.randomElement() ?? .blue
            let shape = Int.random(in: 0...2)
            let rotVel = Double.random(in: -360...360)
            
            let particle = ConfettiParticle(
                x: startX,
                y: startY,
                xVelocity: xVel,
                yVelocity: yVel,
                size: pSize,
                color: color,
                shapeType: shape,
                rotation: 0,
                rotationVelocity: rotVel
            )
            newParticles.append(particle)
        }
        
        particles = newParticles
        
        // Animate particles
        withAnimation(.easeOut(duration: 2.5)) {
            for i in 0..<particles.count {
                particles[i].x += particles[i].xVelocity
                particles[i].y += particles[i].yVelocity * 2 + 500 // gravity effect
                particles[i].rotation += particles[i].rotationVelocity
            }
        }
        
        // Reset after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isActive = false
            particles = []
        }
    }
}

struct ConfettiShape: Shape {
    var type: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch type {
        case 0:
            path.addEllipse(in: rect)
        case 1:
            path.addRect(rect)
        case 2:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        default:
            path.addRect(rect)
        }
        return path
    }
}
