import SwiftUI

struct ReminderPickerView: View {
    @Binding var selectedReminder: ReminderType?
    let onDismiss: () -> Void
    @Environment(\.locale) private var locale
    @State private var showingCustomInput = false
    @State private var customDays: Int = 7

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                List {
                    Button {
                        selectedReminder = nil
                        onDismiss()
                    } label: {
                        HStack {
                            Text("reminder.none")
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            if selectedReminder == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                    }
                    .listRowBackground(AppColors.backgroundSecondary)

                    ForEach(ReminderType.presetCases, id: \.id) { type in
                        Button {
                            selectedReminder = type
                            onDismiss()
                        } label: {
                            HStack {
                                Text(type.displayName(locale: locale))
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                if isSelected(type) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColors.accent)
                                }
                            }
                        }
                        .listRowBackground(AppColors.backgroundSecondary)
                    }

                    Button {
                        if case .custom(let days) = selectedReminder {
                            customDays = days
                        }
                        showingCustomInput = true
                    } label: {
                        HStack {
                            Text(customRowLabel)
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            if case .custom = selectedReminder {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppColors.accent)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .listRowBackground(AppColors.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("reminder.navigation_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("reminder.done") {
                        onDismiss()
                    }
                    .foregroundStyle(AppColors.accent)
                }
            }
            .sheet(isPresented: $showingCustomInput) {
                customIntervalSheet
            }
            .onAppear {
                if case .custom(let days) = selectedReminder {
                    customDays = days
                }
            }
        }
    }

    private var customRowLabel: String {
        if case .custom(let days) = selectedReminder {
            return String(localized: "reminder.custom_days", locale: locale).replacingOccurrences(of: "%d", with: "\(days)")
        }
        return String(localized: "reminder.custom", locale: locale)
    }

    private var customIntervalSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 24) {
                    Text("reminder.custom_hint")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                    HStack {
                        Text("reminder.days_label")
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text("\(customDays)")
                            .font(.title2.bold())
                            .foregroundStyle(AppColors.textPrimary)
                        Stepper("", value: $customDays, in: 1...365)
                            .labelsHidden()
                    }
                    .padding()
                    .background(AppColors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("reminder.custom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("reminder.done") {
                        selectedReminder = .custom(days: customDays)
                        showingCustomInput = false
                        onDismiss()
                    }
                    .foregroundStyle(AppColors.accent)
                }
            }
        }
    }

    private func isSelected(_ type: ReminderType) -> Bool {
        selectedReminder?.id == type.id
    }
}

#Preview {
    ReminderPickerView(selectedReminder: .constant(.oneWeek), onDismiss: {})
}
