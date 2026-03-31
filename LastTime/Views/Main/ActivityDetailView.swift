import PhotosUI
import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity
    let onDismiss: () -> Void
    let onDelete: () -> Void

    @StateObject private var viewModel: ActivityDetailViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingHistory = false
    @State private var showingDeleteConfirmation = false
    @State private var isCategoryPickerPresented = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    init(activity: Activity, onDismiss: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.activity = activity
        self.onDismiss = onDismiss
        self.onDelete = onDelete
        _viewModel = StateObject(wrappedValue: ActivityDetailViewModel(activity: activity))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        detailPhotoSection

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("detail.title_label")
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.textSecondary)
                                TextField("detail.name_placeholder", text: $viewModel.title)
                                    .textFieldStyle(.plain)
                                    .padding(12)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .background(AppColors.backgroundSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                                            .stroke(AppColors.divider, lineWidth: 1)
                                    )
                            }

                            if let lastDone = activity.lastDoneDate {
                                HStack {
                                    Text("detail.last_done")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.textSecondary)
                                    Spacer()
                                    Text(lastDone.formattedHistory(locale: locale))
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                .padding(12)
                                .background(AppColors.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                            }

                            Button {
                                viewModel.isReminderPickerPresented = true
                            } label: {
                                HStack {
                                    Image(systemName: "bell")
                                    Text(viewModel.selectedReminder?.displayName(locale: locale) ?? String(localized: "addedit.reminder_placeholder", locale: locale))
                                    Spacer()
                                    if viewModel.selectedReminder != nil {
                                        Button {
                                            viewModel.selectedReminder = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                    }
                                    Image(systemName: "chevron.right")
                                }
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)
                                .padding(12)
                                .background(AppColors.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)

                            Button {
                                isCategoryPickerPresented = true
                            } label: {
                                HStack {
                                    Image(systemName: "folder")
                                    Text(detailCategoryDisplayName)
                                        .foregroundStyle(AppColors.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)
                                .padding(12)
                                .background(AppColors.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)

                            statsSection

                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                viewModel.markAsDone()
                                onDismiss()
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("detail.mark_done")
                                }
                                .font(.headline)
                                .foregroundStyle(AppColors.backgroundPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius))
                            }
                            .buttonStyle(.plain)

                            Button {
                                showingHistory = true
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                    Text("detail.history")
                                }
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)

                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Text("detail.delete_action")
                                .font(.body)
                                .foregroundStyle(AppColors.danger)
                        }
                        .padding(.top, 24)
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("detail.navigation_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("detail.close") {
                        viewModel.save()
                        onDismiss()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("addedit.save") {
                        viewModel.save()
                        onDismiss()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.accent)
                }
            }
            .onAppear {
                viewModel.loadStats()
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    guard let item = newItem else {
                        viewModel.removeImage()
                        return
                    }
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            viewModel.setImage(uiImage)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isReminderPickerPresented) {
                ReminderPickerView(
                    selectedReminder: $viewModel.selectedReminder,
                    onDismiss: { viewModel.isReminderPickerPresented = false }
                )
            }
            .sheet(isPresented: $isCategoryPickerPresented) {
                CategoryPickerView(
                    selectedCategoryId: $viewModel.selectedCategoryId,
                    categories: viewModel.categories,
                    onDismiss: { isCategoryPickerPresented = false },
                    onCreateCategory: { name, colorHex in
                        viewModel.addCategory(name: name, colorHex: colorHex)?.id
                    }
                )
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(activity: activity)
            }
            .confirmationDialog("detail.delete_confirmation_title", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("detail.delete_button", role: .destructive) {
                    viewModel.delete()
                    onDelete()
                    onDismiss()
                    dismiss()
                }
                Button("addedit.cancel", role: .cancel) {}
            } message: {
                Text("detail.delete_confirmation_message")
            }
        }
    }

    private var detailPhotoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("addedit.photo_label")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            if let image = viewModel.selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))

                    Button {
                        viewModel.removeImage()
                        selectedPhotoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    .padding(8)
                }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("addedit.add_photo")
                    }
                    .font(.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(AppColors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal)
    }

    private var detailCategoryDisplayName: String {
        guard let id = viewModel.selectedCategoryId,
              let cat = viewModel.categories.first(where: { $0.id == id }) else {
            return String(localized: "category.none", locale: locale)
        }
        return cat.name
    }

    @ViewBuilder
    private var statsSection: some View {
        if !viewModel.activityRecords.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("detail.stats_title")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                HStack(spacing: 12) {
                    if let avg = viewModel.averageIntervalDays {
                        StatChip(
                            title: String(localized: "detail.stats_avg_interval", locale: locale),
                            value: String(format: "%.1f", avg)
                        )
                    }
                    StatChip(
                        title: String(localized: "detail.stats_streak", locale: locale),
                        value: "\(viewModel.currentStreak)"
                    )
                    StatChip(
                        title: String(localized: "detail.stats_this_month", locale: locale),
                        value: "\(viewModel.countThisMonth)"
                    )
                }
            }
        }
    }
}

private struct StatChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
            Text(title)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
    }
}

#Preview {
    ActivityDetailView(
        activity: Activity(
            title: "Позвонить родителям",
            lastDoneDate: Date().addingTimeInterval(-86400 * 3),
            reminderType: .oneWeek
        ),
        onDismiss: {},
        onDelete: {}
    )
    .environmentObject(LanguageService())
}
