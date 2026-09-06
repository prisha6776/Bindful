import SwiftUI

struct ImpactView: View {
    @EnvironmentObject var store: ScanStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // Items diverted card
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white.opacity(0.85))

                        Text("\(store.itemsDiverted)")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("items diverted from landfill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))

                        Text(store.motivationMessage)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color.brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

                    // Streak
                    HStack(spacing: 14) {
                        Text("🔥")
                            .font(.system(size: 36))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(store.streak) day streak")
                                .font(.system(size: 18, weight: .bold))
                            Text(store.streak == 0
                                 ? "Scan today to start your streak!"
                                 : "Great start! Come back tomorrow!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Stat boxes
                    HStack(spacing: 12) {
                        StatBox(icon: "arrow.3.trianglepath",
                                count: store.recycleCount,
                                label: "Recycled",
                                color: Color(hex: WasteCategory.recycle.hexColor))
                        StatBox(icon: "leaf",
                                count: store.compostCount,
                                label: "Composted",
                                color: Color(hex: WasteCategory.compost.hexColor))
                        StatBox(icon: "trash",
                                count: store.trashCount,
                                label: "Trashed",
                                color: .secondary)
                    }
                    .padding(.horizontal)

                    // Recent scans
                    if !store.records.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Scans")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                ForEach(store.records.prefix(20)) { record in
                                    ScanRow(record: record)
                                    if record.id != store.records.prefix(20).last?.id {
                                        Divider().padding(.leading, 72)
                                    }
                                }
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("My Impact")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
    }
}

// MARK: Stat Box

struct StatBox: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text("\(count)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: Scan Row

struct ScanRow: View {
    let record: ScanRecord

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: record.category.hexColor).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: record.category.sfSymbol)
                    .foregroundStyle(Color(hex: record.category.hexColor))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(record.itemName)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(record.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(record.category.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: record.category.hexColor))
                Text(record.date.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
