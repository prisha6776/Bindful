import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var camera = CameraModel()
    @State private var results:    [WasteResult] = []
    @State private var isLoading   = false
    @State private var errorMsg:   String? = nil
    @State private var showResult  = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            if isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
            }

            VStack {
                topBar
                Spacer()
                reticle
                Spacer()
                bottomBar
            }

            if isLoading {
                VStack(spacing: 14) {
                    ProgressView().tint(.white).scaleEffect(1.4)
                    Text("Analyzing...").font(.headline).foregroundStyle(.white)
                }
            }

            if let errorMsg {
                VStack {
                    Spacer()
                    Text(errorMsg)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 32)
                        .padding(.bottom, 160)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear   { camera.start() }
        .onDisappear { camera.stop() }
        .navigationDestination(isPresented: $showResult) {
            if let img = camera.lastCapturedImage, !results.isEmpty {
                MultiResultView(results: results, capturedImage: img) {
                    camera.start()
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var reticle: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white.opacity(0.8), lineWidth: 2)
            .frame(width: 260, height: 260)
            .overlay(
                Text("Point at an item to scan")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 280)
            )
    }

    private var bottomBar: some View {
        HStack {
            Spacer()
            Button { capture() } label: {
                ZStack {
                    Circle().stroke(Color.white.opacity(0.5), lineWidth: 4).frame(width: 80, height: 80)
                    Circle().fill(Color.white).frame(width: 66, height: 66)
                }
            }
            .disabled(isLoading)
            Spacer()
        }
        .padding(.bottom, 48)
    }

    private func capture() {
        camera.capturePhoto { image in
            guard let image else { return }
            isLoading = true
            errorMsg  = nil

            Task {
                do {
                    let r = try await AIService.shared.classifyMultiple(image: image)
                    await MainActor.run {
                        results    = r
                        isLoading  = false
                        showResult = true
                    }
                } catch AIError.lowConfidence {
                    await MainActor.run {
                        isLoading = false
                        showError("Move closer for a better look")
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        showError(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func showError(_ msg: String) {
        errorMsg = msg
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run { errorMsg = nil }
        }
    }
}

// MARK: Camera Model
// Sets up the back camera and lets us take a photo with it

@MainActor
final class CameraModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var completionHandler: ((UIImage?) -> Void)?
    private(set) var lastCapturedImage: UIImage?

    override init() {
        super.init()
        session.sessionPreset = .photo
        // hook up the back camera to the session
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input), session.canAddOutput(output)
        else { return }
        session.addInput(input)
        session.addOutput(output)
    }

    // runs off the main thread so the UI doesn't freeze while the camera starts/stops
    func start() {
        guard !session.isRunning else { return }
        Task.detached { [weak self] in await self?.session.startRunning() }
    }

    func stop() {
        guard session.isRunning else { return }
        Task.detached { [weak self] in await self?.session.stopRunning() }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        completionHandler = completion
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

// called automatically once the photo is ready
extension CameraModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                  didFinishProcessingPhoto photo: AVCapturePhoto,
                                  error: Error?) {
        let image = photo.fileDataRepresentation().flatMap { UIImage(data: $0) }
        Task { @MainActor [weak self] in
            self?.lastCapturedImage = image
            self?.completionHandler?(image)
            self?.completionHandler = nil
        }
    }
}

// MARK: Camera Preview

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.previewLayer.session = session
        v.previewLayer.videoGravity = .resizeAspectFill
        return v
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
