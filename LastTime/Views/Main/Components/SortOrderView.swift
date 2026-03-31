import SwiftUI

struct SortOrderView: View {
    @Binding var sortOrder: MainListViewModel.SortOrder

    var body: some View {
        Menu {
            ForEach([MainListViewModel.SortOrder.byLastDone, .byTitle, .byNextReminder], id: \.self) { order in
                Button {
                    sortOrder = order
                } label: {
                    HStack {
                        Text(LocalizedStringKey(order.localizationKey))
                        if sortOrder == order {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppColors.accent)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down.circle")
                    .font(.subheadline)
                Text(LocalizedStringKey(sortOrder.localizationKey))
                    .font(.subheadline)
            }
            .foregroundStyle(AppColors.textSecondary)
        }
    }
}
