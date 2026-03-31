import SwiftUI

struct ActivityCardView: View {
    let activity: Activity
    let onMarkDone: () -> Void
    let onOpenDetail: () -> Void
    let onDelete: (() -> Void)?

    @Environment(\.locale) private var locale

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                onOpenDetail()
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    ActivityThumbnailView(imagePath: activity.imagePath)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.title)
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                        if let lastDone = activity.lastDoneDate {
                            Text(lastDone.timeAgoDisplay(locale: locale))
                                .font(.callout)
                                .foregroundStyle(AppColors.textSecondary)
                        } else {
                            Text("activity.never_marked")
                                .font(.callout)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    Spacer()
                    if activity.reminderType != nil {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundStyle(AppColors.accent)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .buttonStyle(.plain)

            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onMarkDone()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppColors.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(height: AppConstants.cardHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(alignment: .leading) {
            if let status = activity.reminderStatus {
                Rectangle()
                    .fill(statusColor(for: status.state))
                    .frame(width: 4)
                    .clipShape(
                        RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                    )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.divider, lineWidth: 0.5)
        )
        .contextMenu {
            Button {
                onOpenDetail()
            } label: {
                Label("activity.edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("activity.delete", systemImage: "trash")
            }
        }
    }

    private func statusColor(for state: ReminderStatusState) -> Color {
        switch state {
        case .ok: return AppColors.success
        case .soon: return AppColors.warning
        case .overdue: return AppColors.danger
        }
    }
}

#Preview {
    ActivityCardView(
        activity: Activity(
            title: "Позвонить родителям",
            lastDoneDate: Date().addingTimeInterval(-86400 * 3),
            reminderType: .oneWeek
        ),
        onMarkDone: {},
        onOpenDetail: {},
        onDelete: {}
    )
    .padding()
    .background(AppColors.backgroundPrimary)
}
