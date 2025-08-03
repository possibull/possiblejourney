import SwiftUI

struct ProgramCalendarView: View {
    let startDate: Date
    let numberOfDays: Int
    let completedDates: Set<Date>
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    @State private var selectedMonthIndex: Int = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    // Check for August 4th birthday theme activation
    private func checkAugust4thBirthdayActivation() {
        print("🔍 Calendar Birthday Check - Selected Date: \(selectedDate)")
        print("🔍 Calendar Birthday Check - Current Theme: \(themeManager.currentTheme)")
        themeManager.checkBirthdayActivationForDate(selectedDate)
    }
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
    
    private var themeAccentColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
        case .bea:
            return Color(red: 0.9, green: 0.8, blue: 1.0) // Pastel purple
        case .usa:
            return Color(red: 0.8, green: 0.1, blue: 0.2) // Red for USA theme
        case .dark:
            return Color.blue
        case .light, .system:
            return Color.blue
        }
    }
    
    private var themeSecondaryColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
        case .bea:
            return Color(red: 1.0, green: 0.98, blue: 0.8) // Pastel yellow
        case .usa:
            return Color(red: 0.1, green: 0.3, blue: 0.8) // Blue for USA theme
        case .dark:
            return Color.blue.opacity(0.7)
        case .light, .system:
            return Color.blue.opacity(0.7)
        }
    }
    
    var body: some View {
        let enumeratedMonths = Array(months.enumerated())
        VStack {
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
                    
                    CalendarMonthGrid(
                        monthDates: month.dates, 
                        startDate: startDate, 
                        completedDates: completedDates,
                        selectedDate: selectedDate,
                        onDateSelected: { date in
                            print("📅 Date selected in CalendarMonthGrid: \(date)")
                            onDateSelected(date)
                        }
                    )
                        .padding(.vertical, 12)
                        .themeAwareCard()
                        .padding(.horizontal, 8)
                }
                .tag(idx)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Group {
                        if themeManager.currentTheme == .birthday {
                            Color(red: 1.0, green: 0.95, blue: 0.7).opacity(0.3) // Pastel yellow background
                        } else {
                            Color(.systemBackground)
                        }
                    }
                )
            }
        }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // Enable paging, hide dots
        .ignoresSafeArea(edges: .bottom)
        .background(Color(.systemBackground))
        .onAppear {
            print("📅 TabView onAppear - Calendar view is being presented")
        }

        .onAppear {
            print("📅 Calendar onAppear - START")
            print("📅 Calendar onAppear - selectedDate: \(selectedDate)")
            print("📅 Calendar onAppear - currentMonthIndex: \(currentMonthIndex)")
            selectedMonthIndex = currentMonthIndex // Start on current month
            
            // Check for August 4th birthday theme activation
            print("📅 Calendar onAppear - Current theme: \(themeManager.currentTheme)")
            checkAugust4thBirthdayActivation()
            print("📅 Calendar onAppear - END")
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            // Check for August 4th birthday theme activation when date changes
            print("📅 Date changed from \(oldValue) to \(newValue)")
            checkAugust4thBirthdayActivation()
        }
        .onChange(of: themeManager.currentTheme) { oldValue, newValue in
            // Check for August 4th birthday theme activation when theme changes
            print("🎨 Theme changed from \(oldValue) to \(newValue)")
            checkAugust4thBirthdayActivation()
        }
    }
}

struct CalendarMonthGrid: View {
    let monthDates: [Date]
    let startDate: Date
    let completedDates: Set<Date>
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    @EnvironmentObject var themeManager: ThemeManager
    private var calendar: Calendar { Calendar.current }
    
    private var themeAccentColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
        case .bea:
            return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
        case .usa:
            return Color(red: 0.8, green: 0.1, blue: 0.2) // Red for USA theme
        case .dark:
            return Color.blue
        case .light, .system:
            return Color.blue
        }
    }
    
    private var themeSecondaryColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 1.0, green: 0.95, blue: 0.7) // Pastel yellow
        case .bea:
            return Color(red: 1.0, green: 0.98, blue: 0.8) // Pastel yellow
        case .usa:
            return Color(red: 0.1, green: 0.3, blue: 0.8) // Blue for USA theme
        case .dark:
            return Color.blue.opacity(0.7)
        case .light, .system:
            return Color.blue.opacity(0.7)
        }
    }
    
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
        let selectedDay = calendar.startOfDay(for: selectedDate)
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
                                let isSelected = calendar.isDate(selectedDay, inSameDayAs: date)
                                if isProgramDay && isCompleted, let progNum = programDayNumbers[calendar.startOfDay(for: date)] {
                                    ZStack {
                                        // Theme-aware circle for completed days
                                        Circle()
                                            .fill(themeAccentColor)
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
                                                .stroke(themeAccentColor, lineWidth: 2)
                                                .frame(width: 48, height: 48)
                                        }
                                        // Selected date highlight
                                        if isSelected && !isToday {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeSecondaryColor, lineWidth: 3)
                                                .frame(width: 48, height: 48)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                                    .onTapGesture {
                                        onDateSelected(date)
                                    }
                                } else {
                                    ZStack {
                                        // Day of month (theme color if program day, gray otherwise)
                                        Text("\(calendar.component(.day, from: date))")
                                            .font(.system(size: 20, weight: isProgramDay ? .bold : .regular))
                                            .foregroundColor(isProgramDay ? themeAccentColor : Color(.systemGray3))
                                        // Today highlight
                                        if isToday {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeAccentColor, lineWidth: 2)
                                                .frame(width: 48, height: 48)
                                        }
                                        // Selected date highlight
                                        if isSelected && !isToday {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeSecondaryColor, lineWidth: 3)
                                                .frame(width: 48, height: 48)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                                    .onTapGesture {
                                        if isProgramDay {
                                            onDateSelected(date)
                                        }
                                    }
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
    ProgramCalendarView(
        startDate: today, 
        numberOfDays: 75, 
        completedDates: completed,
        selectedDate: today,
        onDateSelected: { _ in }
    )
} 