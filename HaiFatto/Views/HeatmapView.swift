// Hai fatto? — HeatmapView
import SwiftUI

struct HeatmapView: View {
    let completionDates: [Date]
    
    private let calendar = Calendar.current
    private let columns = 52
    private let rows = 7
    private let cellSize: CGFloat = 12
    private let spacing: CGFloat = 4
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Stats Header
            HStack(spacing: 24) {
                StatView(title: String(localized: "heatmap.stat.total"), value: "\(completionDates.count)")
                StatView(title: String(localized: "heatmap.stat.streak.current"), value: "\(calculateCurrentStreak())")
                StatView(title: String(localized: "heatmap.stat.streak.longest"), value: "\(calculateLongestStreak())")
                Spacer()
            }
            .padding(.horizontal)
            
            // Heatmap Grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    // Day Labels
                    VStack(alignment: .trailing, spacing: spacing) {
                        ForEach(0..<7) { row in
                            Text(dayLabel(for: row))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(height: cellSize)
                                .opacity(row % 2 == 0 ? 1 : 0)
                        }
                    }
                    .padding(.top, 20) // align with grid cells under month labels
                    
                    // Grid
                    VStack(alignment: .leading, spacing: 4) {
                        // Month Labels
                        HStack(spacing: 0) {
                            ForEach(0..<12) { monthIndex in
                                Text(monthLabel(for: monthIndex))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: (cellSize + spacing) * 4.3, alignment: .leading)
                            }
                        }
                        
                        HStack(spacing: spacing) {
                            ForEach(0..<columns, id: \.self) { col in
                                VStack(spacing: spacing) {
                                    ForEach(0..<rows, id: \.self) { row in
                                        let date = dateFor(column: col, row: row)
                                        let count = countFor(date: date)
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(colorFor(count: count))
                                            .frame(width: cellSize, height: cellSize)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 2)
                                                    .stroke(Color.primary.opacity(0.2), lineWidth: isToday(date) ? 1.5 : 0)
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Helpers
    
    private func dateFor(column: Int, row: Int) -> Date {
        let now = Date()
        let endOfWeek = calendar.date(byAdding: .day, value: 7 - calendar.component(.weekday, from: now), to: now)!
        let totalDays = (columns * rows) - 1
        let cellIndex = (column * rows) + row
        let daysAgo = totalDays - cellIndex
        return calendar.date(byAdding: .day, value: -daysAgo, to: endOfWeek) ?? now
    }
    
    private func countFor(date: Date) -> Int {
        completionDates.filter { calendar.isDate($0, inSameDayAs: date) }.count
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func colorFor(count: Int) -> Color {
        if count == 0 {
            return Color.gray.opacity(0.2)
        } else if count == 1 {
            return Color.green.opacity(0.5)
        } else {
            return Color.green
        }
    }
    
    private func dayLabel(for row: Int) -> String {
        let days = [String(localized: "day.sun"), String(localized: "day.mon"), String(localized: "day.tue"), String(localized: "day.wed"), String(localized: "day.thu"), String(localized: "day.fri"), String(localized: "day.sat")]
        return days[row]
    }
    
    private func monthLabel(for index: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let date = calendar.date(byAdding: .month, value: -11 + index, to: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    private func calculateCurrentStreak() -> Int {
        var streak = 0
        let today = calendar.startOfDay(for: Date())
        var current = today
        
        let uniqueDays = Set(completionDates.map { calendar.startOfDay(for: $0) })
        
        if uniqueDays.contains(today) {
            streak += 1
        } else if !uniqueDays.contains(calendar.date(byAdding: .day, value: -1, to: today)!) {
            return 0
        }
        
        current = calendar.date(byAdding: .day, value: -1, to: today)!
        while uniqueDays.contains(current) {
            streak += 1
            current = calendar.date(byAdding: .day, value: -1, to: current)!
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let uniqueDays = Set(completionDates.map { calendar.startOfDay(for: $0) }).sorted()
        guard !uniqueDays.isEmpty else { return 0 }
        
        var longest = 1
        var current = 1
        
        for i in 1..<uniqueDays.count {
            if let expectedDate = calendar.date(byAdding: .day, value: 1, to: uniqueDays[i-1]),
               expectedDate == uniqueDays[i] {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        
        return longest
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .bold()
        }
    }
}
