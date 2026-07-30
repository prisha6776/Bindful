import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var result: WasteResult? = nil
    @State private var isLoading = false
    @State private var errorMsg: String? = nil
    @State private var showResult = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "#FFF8E7").ignoresSafeArea()

            VStack(spacing: 24) {
                // Top bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundStyle(Color(hex: "#4A6741"))
                    }
                    Spacer()
                    Text("Upload Photo")
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 28)
                }
                .padding(.horizontal)
                .padding(.top, 12)

                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(maxHeight: 320)
                        .padding(.horizontal)
                } else {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 52))
                                .foregroundStyle(Color(hex: "#4A6741"))
                            Text("Choose a photo")
                                .font(.headline)
                                .foregroundStyle(Color(hex: "#4A6741"))
                            Text("Select any waste item from your gallery")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .background(Color(hex: "#4A6741").opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "#4A6741").opacity(0.3), lineWidth: 2)
                        )
                        .padding(.horizontal)
                    }
                }

                if let errorMsg {
                    Text(errorMsg)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if selectedImage != nil {
                    VStack(spacing: 12) {
                        Button {
                            analyze()
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Label("Analyze", systemImage: "sparkles")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#4A6741"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(isLoading)

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Choose different photo")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    selectedImage = img
                    errorMsg = nil
                    result = nil
                }
            }
        }
        .navigationDestination(isPresented: $showResult) {
            if let result, let img = selectedImage {
                ResultView(result: result, capturedImage: img) {
                    selectedImage = nil
                    selectedItem  = nil
                    self.result   = nil
                }
            }
        }
    }

    private func analyze() {
        guard let img = selectedImage else { return }
        isLoading = true
        errorMsg  = nil

        Task {
            do {
                let r = try await AIService.shared.classify(image: img)
                await MainActor.run {
                    result     = r
                    isLoading  = false
                    showResult = true
                }
            } catch AIError.lowConfidence {
                await MainActor.run {
                    isLoading = false
                    errorMsg  = "Image not clear enough. Try a closer or better-lit photo."
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMsg  = error.localizedDescription
                }
            }
        }
    }
}
