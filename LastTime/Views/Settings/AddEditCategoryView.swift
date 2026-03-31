import SwiftUI

struct AddEditCategoryView: View {
    let category: ActivityCategory?
    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    @State private var name: String = ""
    @State private var selectedColorHex: String = "5b8fb9"
    @Environment(\.dismiss) private var dismiss

    private static let presetColors: [String] = [
        "5b8fb9", "5b9b6d", "c9a227", "b8595b", "8b5b9b",
        "3d5a73", "5b7a8b", "6d8b5b", "9b7a5b", "9b5b6d"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("category.name_label")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                        TextField("category.name_placeholder", text: $name)
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("category.color_label")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                            ForEach(Self.presetColors, id: \.self) { hex in
                                Button {
                                    selectedColorHex = hex
                                } label: {
                                    Circle()
                                        .fill(AppColors.color(hex: hex))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColorHex == hex ? AppColors.textPrimary : .clear, lineWidth: 3)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle(category == nil ? "category.add_title" : "category.edit_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("addedit.cancel") {
                        onCancel()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("addedit.save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.accent)
                }
            }
            .onAppear {
                if let cat = category {
                    name = cat.name
                    selectedColorHex = cat.colorHex
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSave(trimmed, selectedColorHex)
        dismiss()
    }
}
