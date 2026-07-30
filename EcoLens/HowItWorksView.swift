import SwiftUI

struct HowItWorksView: View {
    var body: some View {
        ZStack {
            Color(hex: "#FFF8E7").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Header card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI-Powered Waste Sorting")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("EcoLens uses AI to identify waste items and tell you exactly how to dispose of them properly.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color(hex: "#4A6741"))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal)

                    // Three Simple Steps
                    SectionHeader("Three Simple Steps")

                    VStack(spacing: 12) {
                        StepCard(icon: "camera.viewfinder",
                                 title: "Step 1: Scan",
                                 description: "Point your camera at any item and tap the button.")
                        StepCard(icon: "brain.head.profile",
                                 title: "Step 2: AI Analysis",
                                 description: "The AI identifies the material and determines the correct disposal method.")
                        StepCard(icon: "checkmark.seal",
                                 title: "Step 3: Get Guidance",
                                 description: "Receive clear instructions on how to recycle, compost, or properly discard the item.")
                    }
                    .padding(.horizontal)

                    // Track Your Impact
                    SectionHeader("Track Your Impact")

                    StepCard(icon: "leaf.fill",
                             title: "Step 🌿: My Impact",
                             description: "Every scan saves to your history. See your daily streak and how many items you've kept out of landfill.",
                             iconCircleColor: Color(hex: "#4A6741"),
                             iconColor: .white)
                    .padding(.horizontal)

                    // Waste Categories
                    SectionHeader("Waste Categories")

                    VStack(spacing: 12) {
                        CategoryRow(
                            category: .recycle,
                            items: "Clean plastic bottles · Aluminum cans · Cardboard · Glass"
                        )
                        CategoryRow(
                            category: .compost,
                            items: "Food scraps · Coffee grounds · Yard waste · Paper towels"
                        )
                        CategoryRow(
                            category: .trash,
                            items: "Contaminated items · Styrofoam · Chip bags · Plastic wrap"
                        )
                    }
                    .padding(.horizontal)

                    // Why Proper Sorting Matters
                    SectionHeader("Why Proper Sorting Matters")

                    VStack(spacing: 14) {
                        HStack(spacing: 0) {
                            StatFact(value: "25%", label: "of curbside recycling is contaminated")
                            StatFact(value: "91%", label: "of plastic is never recycled")
                            StatFact(value: "24%", label: "of landfill waste is food that could be composted")
                        }

                        Text("These numbers reveal how much waste is being mismanaged globally. When one item is sorted incorrectly, it can contaminate an entire bin of recycling, sending it all to landfill. Food waste rotting in landfills produces methane, a gas that is 80 times more harmful than CO2. The consequences reach beyond the environment, affecting the air we breathe, the water we drink, and the communities we live in.")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Think before you throw; help the planet grow! 🌱")
                            .font(.subheadline.italic())
                            .foregroundStyle(Color(hex: "#4A6741"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(Color(hex: "#DCF0F5"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("How It Works")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: – Supporting Views

struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(Color(hex: "#1A1A1A"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 4)
    }
}

struct StepCard: View {
    let icon: String
    let title: String
    let description: String
    var iconCircleColor: Color = Color(hex: "#E0DDD8")
    var iconColor: Color = Color(hex: "#3A3A3A")

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconCircleColor)
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(hex: "#1A1A1A"))
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#666666"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct StatFact: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#4A6741"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 6)
    }
}

struct CategoryRow: View {
    let category: WasteCategory
    let items: String

    private var nameColor: Color {
        switch category {
        case .recycle: return Color(hex: "#2196F3")
        case .compost: return Color(hex: "#4CAF50")
        case .trash:   return Color(hex: "#424242")
        }
    }

    private var cardBackground: Color {
        switch category {
        case .recycle: return Color(hex: "#E3F2FD")
        case .compost: return Color(hex: "#E8F5E9")
        case .trash:   return Color(hex: "#F0F0EE")
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: category.hexColor))
                    .frame(width: 62, height: 62)
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue.capitalized)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(nameColor)
                Text(items)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#666666"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
