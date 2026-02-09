//
//  CategoryShareSheet.swift
//  Reps
//
//  Purpose: Share sheet for category completion cards
//  Design: Strava-style — large card preview fills the screen,
//          clean bottom action bar for photo pick + share
//

import SwiftUI
import PhotosUI

/// Strava-inspired share editor.
///
/// Layout:
/// - X button top-left
/// - Card preview fills available space
/// - Bottom bar: camera | gallery | (remove) | share button
struct CategoryShareSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    let completedCount: Int
    let totalCount: Int
    let streak: Int
    let subtitle: String

    // MARK: - State

    @State private var selectedPhoto: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showCamera = false

    // MARK: - Computed

    private var categoryColor: Color { Color(hex: categoryColorHex) }

    private var cardView: ShareableCategoryCard {
        ShareableCategoryCard(
            categoryName: categoryName,
            categoryIcon: categoryIcon,
            categoryColorHex: categoryColorHex,
            completedCount: completedCount,
            totalCount: totalCount,
            streak: streak,
            subtitle: subtitle,
            backgroundImage: selectedPhoto
        )
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: dismiss + title
                topBar
                    .padding(.top, Spacing.sm)

                // Card preview — fills available space
                GeometryReader { geo in
                    let previewWidth = geo.size.width - (Spacing.xl * 2)
                    let previewHeight = previewWidth * (1920.0 / 1080.0)
                    let scale = previewWidth / 1080.0

                    ScrollView(.vertical, showsIndicators: false) {
                        cardView
                            .frame(width: 1080, height: 1920)
                            .scaleEffect(scale, anchor: .topLeading)
                            .frame(width: previewWidth, height: previewHeight)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                            .shadowLevel1()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.lg)
                    }
                }
                .padding(.horizontal, Spacing.xl)

                // Bottom action bar
                bottomBar
            }
        }
        .onChange(of: photosPickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedPhoto = image
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $selectedPhoto)
                .ignoresSafeArea()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.mediumGray)
                    .frame(width: 32, height: 32)
                    .background(Color.darkGray2)
                    .clipShape(Circle())
            }

            Spacer()

            Text("Share your win")
                .font(.system(size: Typography.h4Size, weight: .bold))
                .foregroundStyle(Color.pureWhite)

            Spacer()

            // Invisible balance element
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Bottom Action Bar

    private var bottomBar: some View {
        HStack(spacing: Spacing.md) {
            // Camera
            Button { showCamera = true } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.pureWhite)
                    .frame(width: 48, height: 48)
                    .background(Color.darkGray2)
                    .clipShape(Circle())
            }

            // Gallery
            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.pureWhite)
                    .frame(width: 48, height: 48)
                    .background(Color.darkGray2)
                    .clipShape(Circle())
            }

            // Remove photo
            if selectedPhoto != nil {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPhoto = nil
                        photosPickerItem = nil
                    }
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.strainRed)
                        .frame(width: 48, height: 48)
                        .background(Color.darkGray2)
                        .clipShape(Circle())
                }
            }

            Spacer()

            // Share button
            Button {
                ShareService.renderAndShare(
                    view: cardView,
                    size: CGSize(width: 1080, height: 1920)
                )
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                    Text("Share")
                        .font(.system(size: Typography.bodySize, weight: .bold))
                }
                .foregroundStyle(Color.brandBlack)
                .padding(.horizontal, Spacing.xxl)
                .frame(height: 48)
                .background(categoryColor)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.md)
        .background(
            Color.darkGray1
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.darkGray2),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Camera View (UIKit bridge)

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    CategoryShareSheet(
        categoryName: "Health",
        categoryIcon: "heart.fill",
        categoryColorHex: "2DD881",
        completedCount: 4,
        totalCount: 4,
        streak: 7,
        subtitle: "completed today"
    )
}
