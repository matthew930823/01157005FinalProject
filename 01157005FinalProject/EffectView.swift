
import SwiftUI

struct FireEffect: View {
    @State private var ripples: [Ripple] = []
    var index: Int = 0
    @Binding var scale: CGFloat
    var evolution:Bool
    var opacity : CGFloat
    var body: some View {
        ZStack {
            if index == 1 {
                Image("小火龍") // 使用你的圖像名稱
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .colorMultiply(evolution ? .black : .white)
            }else if index == 2 {
                Image("火恐龍") // 使用你的圖像名稱
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .colorMultiply(evolution ? .black : .white)
            }else if index == 3 {
                Image("噴火龍") // 使用你的圖像名稱
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .colorMultiply(evolution ? .black : .white)
            }else if index == 4 {
                Image("超極巨噴火龍") // 使用你的圖像名稱
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .colorMultiply(evolution ? .black : .white)
            }
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(Color.red.opacity(ripple.opacity), lineWidth: ripple.lineWidth)
                    .scaleEffect(ripple.scale)
                    .frame(width: ripple.size, height: ripple.size)
                    .animation(.easeOut(duration: ripple.duration), value: ripple.scale)
                    .position(x: ripple.position.x, y: ripple.position.y)
            }
        }
        .onTapGesture {location in
            generateRipple(at: location)
            withAnimation(.easeInOut(duration: 0.1)) {
                scale = 0.8
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        scale = 1
                    }
                }
            }
        }
    }
    
    private func generateRipple(at location: CGPoint) {
        let ripple = Ripple(
            id: UUID(),
            size: CGFloat.random(in: 50...100),
            scale: 0.1,
            opacity: 0.5,
            lineWidth: CGFloat.random(in: 2...4),
            duration: Double.random(in: 1.0...1.5),
            position: CGPoint(x: location.x ,
                              y: location.y)
        )
        
        ripples.append(ripple)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = ripples.firstIndex(where: { $0.id == ripple.id }) {
                withAnimation {
                    ripples[index].scale = 3.5
                    ripples[index].opacity = 0.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + ripple.duration) {
                    if index < ripples.count, ripples[index].id == ripple.id {
                        ripples.remove(at: index)
                    }
                }
            }
        }
    }
}

struct Ripple: Identifiable {
    let id: UUID
    var size: CGFloat
    var scale: CGFloat
    var opacity: Double
    var lineWidth: CGFloat
    var duration: Double
    var position: CGPoint
}

