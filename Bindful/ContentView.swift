import SwiftUI

struct ContentView: View {
    @State private var showCamera      = false
    @State private var showImpact      = false
    @State private var showHowItWorks  = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Full screen background (already has logo + title + subtitle)
                    Image("FinalButton!")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .ignoresSafeArea()

                    VStack(spacing: 6) {
                        // eyeballed this % so the title sits right under the logo
                        Spacer().frame(height: geo.size.height * 0.335)

                        Text("Bindful")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black)

                        Text("AI-powered waste sorting")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#6B9B6B"))

                        Spacer()
                    }

                    VStack(spacing: 0) {
                        // Push down to where the scan button sits in the background image
                        Spacer().frame(height: geo.size.height * 0.47)

                        // Scan Item button (tappable version of what's shown in the image)
                        Button { showCamera = true } label: {
                            ZStack {
                                Image("buttonNEWW")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width * 0.82, height: geo.size.width * 0.82 * (846.0/2516.0))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.black, lineWidth: 2))

                                Text("Scan Item")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.black)
                                    .offset(x: 0, y: 16)
                            }
                        }

                        Spacer().frame(height: 14)

                        // Secondary buttons
                        HStack(spacing: 14) {
                            SecondaryButton(title: "My Impact") { showImpact = true }
                            SecondaryButton(title: "How It Works") { showHowItWorks = true }
                        }
                        .padding(.horizontal, 28)

                        Spacer()
                    }
                }
            }
            .ignoresSafeArea()
            .navigationDestination(isPresented: $showCamera)     { CameraView() }
            .navigationDestination(isPresented: $showImpact)     { ImpactView() }
            .navigationDestination(isPresented: $showHowItWorks) { HowItWorksView() }
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.brandGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(hex: "#E8E49A"))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.black, lineWidth: 2))
        }
    }
}

// MARK: Shared Colors

extension Color {
    static let brandGreen = Color(hex: "#4A6741")
    static let appBackground = Color(hex: "#FFF8E7")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default: (a,r,g,b) = (255,255,255,255)
        }
        self.init(.sRGB,
                  red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}
