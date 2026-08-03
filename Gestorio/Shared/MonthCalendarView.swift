import SwiftUI

struct MonthCalendarView: View {
    @Binding var displayedMonth: Date
    var markedDates: Set<Date>
    var selectedDate: Date?
    var onSelect: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            header
            weekdayHeader
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInGrid, id: \.self) { day in
                    if let day {
                        dayCell(for: day)
                    } else {
                        Color.clear
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.headline)

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        let orderedSymbols = Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])
        return HStack {
            ForEach(orderedSymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(for day: Date) -> some View {
        let isMarked = markedDates.contains(calendar.startOfDay(for: day))
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: day) } ?? false

        return Button {
            onSelect(day)
        } label: {
            VStack(spacing: 4) {
                Text(day, format: .dateTime.day())
                    .font(.body)
                    .foregroundStyle(isSelected ? Color.white : Color.primary)

                Circle()
                    .fill(isMarked ? Color.accentColor : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(isSelected ? Color.accentColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func changeMonth(by offset: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else {
            return
        }
        displayedMonth = newMonth
    }

    private var daysInGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyCount = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyCount)
        var currentDay = monthInterval.start

        while currentDay < monthInterval.end {
            days.append(currentDay)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else {
                break
            }
            currentDay = nextDay
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }
}

#Preview {
    MonthCalendarView(
        displayedMonth: .constant(.now),
        markedDates: [Calendar.current.startOfDay(for: .now)],
        selectedDate: nil,
        onSelect: { _ in }
    )
    .padding()
}
