import SwiftUI

struct CategoryFilterBarView: View {
    let categories: [ActivityCategory]
    @Binding var selectedCategoryId: UUID?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedCategoryId = nil
                } label: {
                    Text("category.all")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(selectedCategoryId == nil ? AppColors.backgroundPrimary : AppColors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedCategoryId == nil ? AppColors.accent : AppColors.backgroundSecondary)
                        .clipShape(Capsule())
                }
                ForEach(categories) { category in
                    Button {
                        selectedCategoryId = category.id
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppColors.color(hex: category.colorHex))
                                .frame(width: 8, height: 8)
                            Text(category.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedCategoryId == category.id ? AppColors.backgroundPrimary : AppColors.textSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedCategoryId == category.id ? AppColors.accent : AppColors.backgroundSecondary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
