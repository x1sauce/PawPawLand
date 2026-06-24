import SwiftUI

struct AdventureJournalView: View {
    @Environment(AppState.self) private var appState
    @State private var displayedMonth = Date()
    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ringsSection
                    calendarSection
                    recentMomentsSection
                    ComingSoonBanner(
                        title: "Park Leaderboards",
                        subtitle: "See how your pack ranks city-wide — woof woof incoming!"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(PawColors.heroGradient)
            .navigationTitle("Weekly Rings")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
    }

    private var ringsSection: some View {
        PawCard {
            HStack(spacing: 20) {
                ActivityRingsView(goals: appState.activityGoals, size: 160)
                ActivityRingLegend(goals: appState.activityGoals)
            }
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(title: "Adventure calendar")
                Spacer()
                Text(monthTitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            }

            PawCard {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(PawColors.textTertiary)
                            .frame(maxWidth: .infinity)
                    }

                    ForEach(daysInMonth, id: \.self) { day in
                        if day == 0 {
                            Color.clear.frame(height: 36)
                        } else {
                            calendarDay(day)
                        }
                    }
                }
            }
        }
    }

    private var recentMomentsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Recent paw moments")

            if appState.checkIns.isEmpty {
                Text("No moments yet — share your first walk!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            } else {
                ForEach(appState.checkIns.prefix(5)) { checkIn in
                    momentRow(checkIn)
                }
            }
        }
    }

    private func momentRow(_ checkIn: CheckIn) -> some View {
        PawCard {
            HStack(spacing: 12) {
                ParkThumbnail(seed: checkIn.imageSeed ?? "park", size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    Text(checkIn.parkName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(PawColors.textPrimary)
                    if let caption = checkIn.caption, !caption.isEmpty {
                        Text(caption)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(PawColors.textSecondary)
                            .lineLimit(2)
                    }
                    HStack(spacing: 6) {
                        if let mood = checkIn.mood {
                            Text(mood.emoji)
                        }
                        Text(checkIn.timestamp, style: .relative)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(PawColors.textTertiary)
                    }
                }
                Spacer()
            }
        }
    }

    private func calendarDay(_ day: Int) -> some View {
        let date = dateFor(day: day)
        let hasCheckIn = !appState.checkIns(for: date).isEmpty
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false

        return Button {
            selectedDate = date
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(PawColors.gold.opacity(0.25))
                        .frame(width: 34, height: 34)
                }
                Text("\(day)")
                    .font(.system(size: 14, weight: hasCheckIn ? .bold : .medium, design: .rounded))
                    .foregroundStyle(hasCheckIn ? PawColors.gold : PawColors.textSecondary)
                if hasCheckIn {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(PawColors.coral)
                        .offset(x: 10, y: -10)
                }
            }
            .frame(height: 36)
        }
        .buttonStyle(.plain)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var weekdaySymbols: [String] {
        calendar.shortWeekdaySymbols
    }

    private var daysInMonth: [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        return Array(repeating: 0, count: leading) + Array(range)
    }

    private func dateFor(day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: displayedMonth)
        components.day = day
        return calendar.date(from: components) ?? displayedMonth
    }
}

#Preview {
    AdventureJournalView()
        .environment(AppState())
}
