import SwiftUI

struct ResultView: View {
    let result: WasteResult
    let capturedImage: UIImage
    let onScanAgain: () -> Void

    @EnvironmentObject var store: ScanStore
    @Environment(\.dismiss) private var dismiss
    @State private var saved = false

    private var categoryColor: Color { Color(hex: result.category.hexColor) }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Banner
                VStack(spacing: 10) {
                    Image(systemName: result.category.sfSymbol)
                        .font(.system(size: 56))
                        .foregroundStyle(.white)

                    Text(result.category.rawValue)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(result.item)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background(categoryColor)

                ScrollView {
                    VStack(spacing: 14) {

                        // Why this bin
                        InfoCard(
                            icon: "info.circle.fill",
                            iconColor: categoryColor,
                            title: "Why this bin?",
                            text: result.reason
                        )

                        // Disposal tip
                        InfoCard(
                            icon: "lightbulb.fill",
                            iconColor: categoryColor,
                            title: "Disposal tip",
                            text: result.tip
                        )

                        // Confidence
                        HStack {
                            Spacer()
                            Text("\(Int(result.confidence * 100))%")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(categoryColor)
                        }
                        .padding(.horizontal, 28)

                        // Scan again button
                        Button {
                            saveRecord()
                            dismiss()
                            onScanAgain()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Scan Another Item")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(categoryColor)
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .padding(.bottom, 32)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { saveRecord() }
    }

    private func saveRecord() {
        guard !saved else { return }
        saved = true
        store.add(ScanRecord(
            itemName: result.item,
            category: result.category,
            confidence: result.confidence,
            reason: result.reason
        ))
    }
}

struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline.bold())
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
