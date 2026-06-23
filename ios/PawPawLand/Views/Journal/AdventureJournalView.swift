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
                    statsRow
                    calendarSection
                    recentVisitsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(PawColors.background)
            .navigationTitle("My Adventure")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundStyle(PawColors.gold)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            StatPill(value: "\(appState.explorationStats.visitedParks)", label: "Parks Visited")
            Divider().frame(height: 40).background(PawColors.surfaceBorder)
            StatPill(value: "\(appState.explorationStats.totalCheckIns)", label: "Check-ins")
            Divider().frame(height: 40).background(PawColors.surfaceBorder)
            StatPill(value: "\(appState.explorationStats.badgesEarned)", label: "Badges Earned")
        }
        .padding(.vertical, 16)
        .background(PawColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(PawColors.surfaceBorder, lineWidth: 1)
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(PawColors.textSecondary)
                }

                Spacer()

                Text(monthYearString(from: displayedMonth))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)

                Spacer()

                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(PawColors.textSecondary)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(PawColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(daysInMonth, id: \.self) { day in
                    if let day {
                        CalendarDayCell(
                            day: day,
                            hasCheckIn: appState.datesWithCheckIns(in: displayedMonth).contains(day),
                            isToday: isToday(day: day),
                            isSelected: isSelected(day: day)
                        )
                        .onTapGesture {
                            selectedDate = dateFor(day: day)
                        }
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
            .padding(16)
            .background(PawColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(PawColors.surfaceBorder, lineWidth: 1)
            }

            ExplorationProgressBar(stats: appState.explorationStats)
        }
    }

    private var recentVisitsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Recent Visits")

            if appState.checkIns.isEmpty {
                PawCard {
                    VStack(spacing: 8) {
                        Image(systemName: "pawprint")
                            .font(.system(size: 28))
                            .foregroundStyle(PawColors.textTertiary)
                        Text("No adventures yet")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(PawColors.textSecondary)
                        Text("Check in at a park to start your journal")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(PawColors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            } else {
                ForEach(appState.checkIns) { checkIn in
                    RecentVisitRow(checkIn: checkIn, park: appState.park(by: checkIn.parkId))
                }
            }
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...]) + Array(symbols[..<firstWeekday])
    }

    private var daysInMonth: [Int?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let monthFirstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }

        let numberOfDays = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 0
        let leadingBlanks = (monthFirstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Int?] = Array(repeating: nil, count: leadingBlanks)
        days += (1...numberOfDays).map { Optional($0) }
        return days
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func dateFor(day: Int) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: displayedMonth)
        components.day = day
        return calendar.date(from: components)
    }

    private func isToday(day: Int) -> Bool {
        guard let date = dateFor(day: day) else { return false }
        return calendar.isDateInToday(date)
    }

    private func isSelected(day: Int) -> Bool {
        guard let selectedDate, let date = dateFor(day: day) else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
}

struct CalendarDayCell: View {
    let day: Int
    let hasCheckIn: Bool
    let isToday: Bool
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected || isToday {
                    Circle()
                        .fill(isSelected ? PawColors.gold : PawColors.gold.opacity(0.2))
                        .frame(width: 36, height: 36)
                }

                Text("\(day)")
                    .font(.system(size: 15, weight: isToday || isSelected ? .bold : .medium, design: .rounded))
                    .foregroundStyle(textColor)
            }

            if hasCheckIn {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(PawColors.gold)
            } else {
                Color.clear.frame(height: 8)
            }
        }
        .frame(height: 48)
    }

    private var textColor: Color {
        if isSelected { return Color(red: 0.12, green: 0.08, blue: 0.02) }
        if isToday { return PawColors.gold }
        return PawColors.textPrimary
    }
}

struct RecentVisitRow: View {
    let checkIn: CheckIn
    let park: DogPark?

    var body: some View {
        HStack(spacing: 14) {
            ParkThumbnail(seed: park?.imageSeed ?? "default", size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(checkIn.parkName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)

                Text(formattedDate)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            }

            Spacer()

            if let mood = checkIn.mood {
                Text(mood.emoji)
                    .font(.system(size: 22))
            }
        }
        .padding(14)
        .background(PawColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(PawColors.surfaceBorder, lineWidth: 1)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(checkIn.timestamp) {
            formatter.dateFormat = "'Today' • h:mm a"
        } else if Calendar.current.isDateInYesterday(checkIn.timestamp) {
            formatter.dateFormat = "'Yesterday' • h:mm a"
        } else {
            formatter.dateFormat = "MMM d • h:mm a"
        }
        return formatter.string(from: checkIn.timestamp)
    }
}

#Preview {
    AdventureJournalView()
        .environment(AppState())
}
