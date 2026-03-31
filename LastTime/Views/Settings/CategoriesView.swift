import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var categoryToEdit: ActivityCategory?
    @State private var showingAddSheet = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary.ignoresSafeArea()

            Group {
                if viewModel.categories.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            Button {
                                categoryToEdit = category
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(AppColors.color(hex: category.colorHex))
                                        .frame(width: 12, height: 12)
                                    Text(category.name)
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(AppColors.backgroundSecondary)
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteCategory(category)
                                } label: {
                                    Text("activity.delete")
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("settings.categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditCategoryView(
                category: nil,
                onSave: { name, colorHex in
                    viewModel.addCategory(name: name, colorHex: colorHex)
                },
                onCancel: { showingAddSheet = false }
            )
        }
        .sheet(item: $categoryToEdit) { category in
            AddEditCategoryView(
                category: category,
                onSave: { name, colorHex in
                    viewModel.updateCategory(id: category.id, name: name, colorHex: colorHex)
                    categoryToEdit = nil
                },
                onCancel: { categoryToEdit = nil }
            )
        }
        .onAppear {
            viewModel.loadCategories()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("category.empty")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text("category.empty_hint")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
