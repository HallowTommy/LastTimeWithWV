import SwiftUI

struct TemplateCardView: View {
    let title: String
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
            Spacer()
            if isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    onAdd()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.divider, lineWidth: 0.5)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        TemplateCardView(title: "Позвонить родителям", isAdded: false, onAdd: {})
        TemplateCardView(title: "Постирать постельное бельё", isAdded: true, onAdd: {})
    }
    .padding()
    .background(AppColors.backgroundPrimary)
}
