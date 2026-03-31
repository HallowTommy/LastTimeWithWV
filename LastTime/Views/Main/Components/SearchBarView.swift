import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: LocalizedStringKey = "search.placeholder"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textSecondary)
            TextField(placeholder, text: $text)
                .foregroundStyle(AppColors.textPrimary)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .padding(12)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                .stroke(AppColors.divider, lineWidth: 1)
        )
    }
}

#Preview {
    SearchBarView(text: .constant(""))
        .padding()
        .background(AppColors.backgroundPrimary)
}
