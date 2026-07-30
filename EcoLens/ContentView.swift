import SwiftUI

struct ContentView: View {
    @State private var showCamera      = false
    @State private var showImpact      = false
    @State private var showHowItWorks  = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Cream top fill so camera logo doesn't get clipped by status bar
                    VStack {
                        Color(hex: "#FCE8C0")
                            .frame(height: geo.safeAreaInsets.top + 40)
                        Spacer()
                    }
                    .ignoresSafeArea()

                    // Full screen background (already has logo + title + subtitle)
                    Image("EcoLensFront")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .padding(.top, geo.safeAreaInsets.top + 40)
                        .ignoresSafeArea(edges: .bottom)

                    VStack(spacing: 0) {
                        // Push down to where the scan button sits in the background image
                        Spacer().frame(height: geo.size.height * 0.40)

                        // Scan Item button (tappable version of what's shown in the image)
                        Button { showCamera = true } label: {
                            Image("scanitemb")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.82)
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
                .foregroundStyle(Color(hex: "#4A6741"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(hex: "#E8E49A"))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color(hex: "#B8C99A").opacity(0.5), lineWidth: 1))
        }
    }
}

// MARK: – Color Hex Extension

extension Color {
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
