//
//  CategoryShareSheet.swift
//  Reps
//
//  Purpose: Full-screen share sheet for category completion cards
//  Design: Photo picker (camera + gallery), live card preview, share button
//

import SwiftUI
import PhotosUI

/// Sheet presented when a user completes all tasks in a category.
///
/// Allows them to:
/// 1. See a live preview of their branded card
/// 2. Pick a photo from gallery or take one with camera
/// 3. Share the rendered card via the system share sheet
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

    // MARK: - State

    @State private var selectedPhoto: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showCamera = false

    // MARK: - Computed

    private var categoryColor: Color {
        Color(hex: categoryColorHex)
    }

    private var cardView: ShareableCategoryCard {
        ShareableCategoryCard(
            categoryName: categoryName,
            categoryIcon: categoryIcon,
            categoryColorHex: categoryColorHex,
            completedCount: completedCount,
            totalCount: totalCount,
            streak: streak,
            backgroundImage: selectedPhoto
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.04)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Card preview
                    cardPreview
                        .padding(.top, Spacing.md)

                    Spacer()

                    // Photo source buttons
                    photoButtons
                        .padding(.bottom, Spacing.lg)

                    // Share button
                    shareButton
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.pureWhite)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Share your win")
                        .font(.system(size: Typography.h4Size, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                }
            }
            .toolbarBackground(Color(red: 0.04, green: 0.04, blue: 0.04), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
    }

    // MARK: - Subviews

    private var cardPreview: some View {
        cardView
            .frame(width: 1080, height: 1920)
            .scaleEffect(0.22)
            .frame(width: 1080 * 0.22, height: 1920 * 0.22)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: categoryColor.opacity(0.3), radius: 20, y: 10)
    }

    private var photoButtons: some View {
        HStack(spacing: Spacing.lg) {
            // Camera button
            Button {
                showCamera = true
            } label: {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                    Text("CAMERA")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundStyle(Color.pureWhite)
                .frame(width: 80, height: 70)
                .background(Color.darkGray2)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
            }

            // Gallery button
            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 22, weight: .semibold))
                    Text("GALLERY")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundStyle(Color.pureWhite)
                .frame(width: 80, height: 70)
                .background(Color.darkGray2)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
            }

            // Remove photo button (only if photo selected)
            if selectedPhoto != nil {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPhoto = nil
                        photosPickerItem = nil
                    }
                } label: {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                        Text("REMOVE")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.5)
                    }
                    .foregroundStyle(Color.strainRed)
                    .frame(width: 80, height: 70)
                    .background(Color.darkGray2)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
                }
            }
        }
    }

    private var shareButton: some View {
        Button {
            ShareService.renderAndShare(
                view: cardView,
                size: CGSize(width: 1080, height: 1920)
            )
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .bold))
                Text("Share")
                    .font(.system(size: Typography.bodySize, weight: .bold))
            }
            .foregroundStyle(Color.brandBlack)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(categoryColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
    }
}

// MARK: - Camera View (UIKit bridge)

/// Wraps UIImagePickerController for camera access
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

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

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

#Preview("Category Share Sheet") {
    CategoryShareSheet(
        categoryName: "Health",
        categoryIcon: "heart.fill",
        categoryColorHex: "2DD881",
        completedCount: 4,
        totalCount: 4,
        streak: 7
    )
}
