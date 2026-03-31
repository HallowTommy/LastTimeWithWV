import SwiftUI

struct MainListView: View {
    @StateObject private var viewModel = MainListViewModel()
    @State private var showingAddSheet = false
    @State private var activityForDetail: Activity?

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                SearchBarView(text: $viewModel.searchText, placeholder: "search.placeholder")
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                DashboardSummaryView(
                    overdueCount: viewModel.overdueCount,
                    dueThisWeekCount: viewModel.dueThisWeekCount,
                    doneTodayCount: viewModel.doneTodayCount,
                    onOverdueTap: { viewModel.filter = .overdue }
                )
                .padding(.horizontal)

                FilterBarView(selectedFilter: $viewModel.filter)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                if !viewModel.categories.isEmpty {
                    CategoryFilterBarView(
                        categories: viewModel.categories,
                        selectedCategoryId: $viewModel.selectedCategoryId
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                HStack {
                    SortOrderView(sortOrder: $viewModel.sortOrder)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 16)

                if viewModel.filteredActivities.isEmpty {
                    emptyState
                } else {
                    activityList
                }
            }
        }
        .navigationTitle("main.navigation_title")
        .navigationBarTitleDisplayMode(.large)
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
            AddEditActivityView(onSave: { viewModel.loadData() }, onCancel: {})
        }
        .onAppear {
            viewModel.loadData()
        }
        .sheet(item: $activityForDetail) { activity in
            ActivityDetailView(
                activity: activity,
                onDismiss: { viewModel.loadData() },
                onDelete: { viewModel.loadData() }
            )
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(
            RadialGradient(
                colors: [AppColors.accentMuted.opacity(0.15), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
        )
        .ignoresSafeArea()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textSecondary)
            Text("main.empty_title")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text("main.empty_subtitle")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var activityList: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.cardSpacing) {
                ForEach(viewModel.filteredActivities) { activity in
                    ActivityCardView(
                        activity: activity,
                        onMarkDone: { viewModel.markAsDone(activity) },
                        onOpenDetail: { activityForDetail = activity },
                        onDelete: { viewModel.deleteActivity(activity) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    NavigationStack {
        MainListView()
            .environmentObject(LanguageService())
    }
}
