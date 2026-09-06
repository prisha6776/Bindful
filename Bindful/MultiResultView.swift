import SwiftUI

struct MultiResultView: View {
    let results: [WasteResult]
    let capturedImage: UIImage
    let onScanAgain: () -> Void

    @EnvironmentObject var store: ScanStore
    @Environment(\.dismiss) private var dismiss
    @State private var saved = false

    private var recycleCount: Int { results.filter { $0.category == .recycle }.count }
    private var compostCount: Int { results.filter { $0.category == .compost }.count }
    private var trashCount:   Int { results.filter { $0.category == .trash   }.count }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .overlay(Color.black.opacity(0.35))
                        .overlay(
                            VStack(spacing: 6) {
                                Text("\(results.count) item\(results.count == 1 ? "" : "s") found")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)

                                HStack(spacing: 20) {
                                    if recycleCount > 0 {
                                        CategoryBadge(icon: "arrow.3.trianglepath",
                                                      count: recycleCount,
                                                      color: Color(hex: WasteCategory.recycle.hexColor))
                                    }
                                    if compostCount > 0 {
                                        CategoryBadge(icon: "leaf.fill",
                                                      count: compostCount,
                                                      color: Color(hex: WasteCategory.compost.hexColor))
                                    }
                                    if trashCount > 0 {
                                        CategoryBadge(icon: "trash.fill",
                                                      count: trashCount,
                                                      color: Color(hex: WasteCategory.trash.hexColor))
                                    }
                                }
                            }
                        )
                }

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(results.enumerated()), id: \.offset) { _, result in
                            ResultItemCard(result: result)
                        }

                        Button {
                            saveAll()
                            dismiss()
                            onScanAgain()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Scan Another")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.brandGreen)
                            .clipShape(Capsule())
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { saveAll() }
    }

    private func saveAll() {
        guard !saved else { return }
        saved = true
        for result in results {
            store.add(ScanRecord(
                itemName: result.item,
                category: result.category,
                confidence: result.confidence,
                reason: result.reason
            ))
        }
    }
}

// MARK: Supporting Views

struct ResultItemCard: View {
    let result: WasteResult

    private var categoryColor: Color { Color(hex: result.category.hexColor) }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: result.category.sfSymbol)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(result.item)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Text(result.category.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(categoryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(categoryColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                Text(result.reason)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(result.tip)
                    .font(.caption)
                    .foregroundStyle(categoryColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(categoryColor.opacity(0.25), lineWidth: 1.5)
        )
    }
}

struct CategoryBadge: View {
    let icon: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
            Text("\(count)")
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.85))
        .clipShape(Capsule())
    }
}
