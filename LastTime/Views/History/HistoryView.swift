import SwiftUI

struct HistoryView: View {
    let activity: Activity
    @StateObject private var viewModel: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    init(activity: Activity) {
        self.activity = activity
        _viewModel = StateObject(wrappedValue: HistoryViewModel(activity: activity))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                if viewModel.records.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundStyle(AppColors.textSecondary)
                        Text("history.empty")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.records) { record in
                            Text(record.date.formattedHistory(locale: locale))
                                .foregroundStyle(AppColors.textPrimary)
                                .listRowBackground(AppColors.backgroundSecondary)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(activity.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("history.done") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.accent)
                }
            }
        }
    }
}

#Preview {
    HistoryView(activity: Activity(title: "Тест"))
}
