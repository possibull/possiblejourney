import SwiftUI

struct ProgramCalendarView: View {
    let startDate: Date
    let numberOfDays: Int
    let completedDates: Set<Date>
    
    @State private var selectedMonthIndex: Int = 0
    private var calendar: Calendar { Calendar.current }
    private var programDates: [Date] {
        (0..<numberOfDays).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
    }
    private var months: [(monthStart: Date, dates: [Date])] {
        let grouped = Dictionary(grouping: programDates) { date in
            let comps = calendar.dateComponents([.year, .month], from: date)
            return calendar.date(from: comps)!
        }
        return grouped.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }
    private var currentMonthIndex: Int {
        let today = calendar.startOfDay(for: Date())
        let comps = calendar.dateComponents([.year, .month], from: today)
        let thisMonth = calendar.date(from: comps)!
        return months.firstIndex(where: { calendar.isDate($0.monthStart, inSameDayAs: thisMonth) }) ?? 0
    }
    
    private var completedDaysCount: Int {
        completedDates.count
    }
    
    var body: some View {
        let enumeratedMonths = Array(months.enumerated())
        TabView(selection: $selectedMonthIndex) { // Vertical paging
            ForEach(enumeratedMonths, id: \ .element.monthStart) { pair in
                let idx = pair.offset
                let month = pair.element
                VStack(spacing: 0) {
                    let comps = calendar.dateComponents([.year, .month], from: month.monthStart)
                    let yearString: String = {
                        if let year = comps.year {
                            return String(format: "%04d", year)
                        } else {
                            return ""
                        }
                    }()
                    
                    // Progress summary
                    VStack(spacing: 8) {
                        Text("\(calendar.monthSymbols[comps.month! - 1]) \(yearString)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("\(completedDaysCount) of \(numberOfDays) days completed")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)
                    
                    CalendarMonthGrid(monthDates: month.dates, startDate: startDate, completedDates: completedDates)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .shadow(color: Color(.black).opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 8)
                }
                .tag(idx)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // Enable paging, hide dots
        .ignoresSafeArea(edges: .bottom)
        .background(Color(.systemBackground))
        .onAppear {
            selectedMonthIndex = currentMonthIndex // Start on current month
        }
    }
}

struct CalendarMonthGrid: View {
    let monthDates: [Date]
    let startDate: Date
    let completedDates: Set<Date>
    private var calendar: Calendar { Calendar.current }
    
    var body: some View {
        guard let first = monthDates.first else { return AnyView(EmptyView()) }
        let comps = calendar.dateComponents([.year, .month], from: first)
        let firstOfMonth = calendar.date(from: comps)!
        let weekday = calendar.component(.weekday, from: firstOfMonth) // 1 = Sunday
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)!.count
        let programDaySet = Set(monthDates.map { calendar.startOfDay(for: $0) })
        let allDays: [Date?] =
            Array(repeating: nil, count: weekday - 1) +
            (1...daysInMonth).map { day in
                calendar.date(bySetting: .day, value: day, of: firstOfMonth)
            }
        
        // Ensure we have complete weeks (7 days each)
        let totalCells = allDays.count
        let completeWeeks = (totalCells + 6) / 7 // Round up to ensure complete weeks
        let paddedDays = allDays + Array(repeating: nil, count: completeWeeks * 7 - totalCells)
        
        let rows = stride(from: 0, to: paddedDays.count, by: 7).map { i in
            Array(paddedDays[i..<min(i+7, paddedDays.count)])
        }
        // Map program days to their program day number (1-based)
        let programDayNumbers: [Date: Int] = {
            var dict = [Date: Int]()
            for (idx, date) in monthDates.enumerated() {
                dict[calendar.startOfDay(for: date)] = idx + 1
            }
            return dict
        }()
        let today = calendar.startOfDay(for: Date())
        return AnyView(
            VStack(spacing: 12) {
                // Day of week headers
                HStack(spacing: 0) {
                    ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                        Text(d)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                    }
                }
                ForEach(rows, id: \.self) { week in
                    HStack(spacing: 0) {
                        ForEach(week, id: \.self) { day in
                            if let date = day {
                                let isProgramDay = programDaySet.contains(calendar.startOfDay(for: date))
                                let isCompleted = completedDates.contains { calendar.isDate($0, inSameDayAs: date) }
                                let isToday = calendar.isDate(today, inSameDayAs: date)
                                if isProgramDay && isCompleted, let progNum = programDayNumbers[calendar.startOfDay(for: date)] {
                                    ZStack {
                                        // Blue circle for completed days
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 32, height: 32)
                                        // Day of month in white (centered)
                                        Text("\(calendar.component(.day, from: date))")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        // Program day number in white, smaller
                                        Text("\(progNum)")
                                            .font(.system(size: 12, weight: .heavy))
                                            .foregroundColor(.white)
                                            .offset(y: 12)
                                        // Today highlight (on top)
                                        if isToday {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blue, lineWidth: 2)
                                                .frame(width: 48, height: 48)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                                } else {
                                    ZStack {
                                        // Day of month (blue if program day, gray otherwise)
                                        Text("\(calendar.component(.day, from: date))")
                                            .font(.system(size: 20, weight: isProgramDay ? .bold : .regular))
                                            .foregroundColor(isProgramDay ? .blue : Color(.systemGray3))
                                        // Today highlight
                                        if isToday {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blue, lineWidth: 2)
                                                .frame(width: 48, height: 48)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                                }
                            } else {
                                Text("").frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        )
    }
}

#Preview {
    let today = Calendar.current.startOfDay(for: Date())
    let completed = Set([0, 1, 2, 10, 15].compactMap { Calendar.current.date(byAdding: .day, value: $0, to: today) })
    ProgramCalendarView(startDate: today, numberOfDays: 75, completedDates: completed)
} 