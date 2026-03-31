import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategoryId: UUID?
    let categories: [ActivityCategory]
    let onDismiss: () -> Void
    var onCreateCategory: ((String, String) -> UUID?)? = nil
    @State private var showingAddCategory = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                List {
                    Button {
                        selectedCategoryId = nil
                        onDismiss()
                    } label: {
                        HStack {
                            Text("category.none")
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            if selectedCategoryId == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                    }
                    .listRowBackground(AppColors.backgroundSecondary)

                    if onCreateCategory != nil {
                        Button {
                            showingAddCategory = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(AppColors.accent)
                                Text("category.add_new")
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                            }
                        }
                        .listRowBackground(AppColors.backgroundSecondary)
                    }

                    ForEach(categories) { category in
                        Button {
                            selectedCategoryId = category.id
                            onDismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(AppColors.color(hex: category.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                if selectedCategoryId == category.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColors.accent)
                                }
                            }
                        }
                        .listRowBackground(AppColors.backgroundSecondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("category.picker_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("reminder.done") {
                        onDismiss()
                    }
                    .foregroundStyle(AppColors.accent)
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddEditCategoryView(
                    category: nil,
                    onSave: { name, colorHex in
                        if let id = onCreateCategory?(name, colorHex) {
                            selectedCategoryId = id
                            showingAddCategory = false
                            onDismiss()
                        }
                    },
                    onCancel: { showingAddCategory = false }
                )
            }
        }
    }
}
