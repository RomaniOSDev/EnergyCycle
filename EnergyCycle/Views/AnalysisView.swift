//
//  AnalysisView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct AnalysisView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    
    var body: some View {
        ZStack {
            Color.mainBack
                .ignoresSafeArea()
            ScrollView {
                Text("Analysis")
                    .font(.system(size: 35, weight: .heavy, design: .monospaced))
                VStack(spacing: 20) {
                    // Статистика дня
                    DayStatisticsView(energyCycle: viewModel.energyCycle)
                        .padding(.horizontal)
                    
                    // Анализ эффективности планирования
                    PlanningEffectivenessView(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    // Рекомендации на завтра
                    TomorrowRecommendationsView(viewModel: viewModel)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .foregroundColor(.colorText)
        }
    }
}

struct DayStatisticsView: View {
    let energyCycle: EnergyCycle
    
    var averagePhysicalEnergy: Double {
        let values = energyCycle.energyLevels.map { $0.physicalEnergy }
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }
    
    var averageMentalEnergy: Double {
        let values = energyCycle.energyLevels.map { $0.mentalEnergy }
        return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Day Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                StatisticCardView(
                    title: "Avg Physical",
                    value: Int(averagePhysicalEnergy * 100),
                    unit: "%",
                    color: .red
                )
                
                StatisticCardView(
                    title: "Avg Mental",
                    value: Int(averageMentalEnergy * 100),
                    unit: "%",
                    color: .blue
                )
            }
            
            HStack(spacing: 20) {
                StatisticCardView(
                    title: "Planned",
                    value: energyCycle.plannedActivities.count,
                    unit: "tasks",
                    color: .green
                )
                
                StatisticCardView(
                    title: "Completed",
                    value: energyCycle.actualActivities.count,
                    unit: "tasks",
                    color: .orange
                )
            }
        }
        .padding(20)
        .cardStyle()
    }
}

struct StatisticCardView: View {
    let title: String
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.mainBack.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct PlanningEffectivenessView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    
    var effectivenessScore: Double {
        let activities = viewModel.todayActivities
        guard !activities.isEmpty else { return 0 }
        
        var score = 0.0
        var count = 0
        
        for activity in activities {
            if let recommendedTime = viewModel.recommendTime(for: activity.type) {
                let timeDiff = abs(recommendedTime.timeIntervalSince(activity.scheduledTime))
                // Чем ближе к рекомендуемому времени, тем выше оценка
                // Максимальная разница для оценки - 4 часа
                let maxDiff: TimeInterval = 14400
                let normalizedDiff = min(timeDiff / maxDiff, 1.0)
                score += (1.0 - normalizedDiff)
                count += 1
            }
        }
        
        return count > 0 ? score / Double(count) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Planning Effectiveness")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Score")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(Int(effectivenessScore * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(effectivenessScore > 0.7 ? .green : effectivenessScore > 0.4 ? .orange : .red)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.mainBack.opacity(0.4))
                            .frame(height: 14)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        effectivenessScore > 0.7 ? Color.green : effectivenessScore > 0.4 ? Color.orange : Color.red,
                                        (effectivenessScore > 0.7 ? Color.green : effectivenessScore > 0.4 ? Color.orange : Color.red).opacity(0.7)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(effectivenessScore), height: 14)
                            .shadow(color: (effectivenessScore > 0.7 ? Color.green : effectivenessScore > 0.4 ? Color.orange : Color.red).opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 14)
                
                Text(effectivenessMessage)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    var effectivenessMessage: String {
        if effectivenessScore > 0.7 {
            return "Excellent planning! Tasks are optimally distributed."
        } else if effectivenessScore > 0.4 {
            return "Good planning, but there's room for improvement."
        } else {
            return "Consider replanning tasks for better effectiveness."
        }
    }
}

struct TomorrowRecommendationsView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommendations for Tomorrow")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                RecommendationItemView(
                    icon: "sunrise.fill",
                    title: "Morning Assessment",
                    description: "Assess your energy level in the morning for accurate planning"
                )
                
                RecommendationItemView(
                    icon: "clock.fill",
                    title: "Plan Ahead",
                    description: "Add tasks considering your energy peaks"
                )
                
                RecommendationItemView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Changes",
                    description: "Regularly update energy levels throughout the day"
                )
            }
        }
        .padding(20)
        .cardStyle()
    }
}

struct RecommendationItemView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.color1.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(.color1)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .lineSpacing(2)
                    .foregroundColor(.white.opacity(0.75))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AnalysisView(viewModel: EnergyCycleViewModel())
}

