//
//  DashboardView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    @State private var showingEnergyInput = false
    @State private var showingAddActivity = false
    @State private var selectedRecommendation: (ActivityType, Date)?
    
    var body: some View {
        ZStack {
            Color.mainBack
                .ignoresSafeArea()
            ScrollView {
                Text("Energy Cycle")
                    .font(.system(size: 35, weight: .heavy, design: .monospaced))
                VStack(spacing: 20) {
                    // Текущий уровень энергии
                    EnergyCardView(
                        physical: viewModel.currentEnergyLevel.physical,
                        mental: viewModel.currentEnergyLevel.mental
                    )
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.colorText)
                            .opacity(0.3)
                    }
                    
                    // Quick energy assessment
                    Button(action: {
                        showingEnergyInput = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Assess Energy Level")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.white)
                        .primaryButtonStyle()
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Upcoming tasks
                    if !viewModel.todayActivities.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming Tasks")
                                .font(.headline)
                                .foregroundColor(.colorText)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.todayActivities.prefix(3)) { activity in
                                ActivityRowView(activity: activity)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Рекомендации
                    RecommendationsView(
                        viewModel: viewModel,
                        onRecommendationTap: { activityType, recommendedTime in
                            selectedRecommendation = (activityType, recommendedTime)
                            showingAddActivity = true
                        }
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .foregroundColor(.colorText)
            .sheet(isPresented: $showingEnergyInput) {
                EnergyInputView(viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showingAddActivity) {
                if let recommendation = selectedRecommendation {
                    AddActivityView(
                        viewModel: viewModel,
                        activityType: recommendation.0,
                        recommendedTime: recommendation.1
                    )
                    .preferredColorScheme(.dark)
                } else {
                    AddActivityView(viewModel: viewModel)
                        .preferredColorScheme(.dark)
                }
            }
        }
    }
}

struct EnergyCardView: View {
    let physical: Double
    let mental: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.color1)
                    .font(.title3)
                Text("Current Energy Level")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.colorText)
            }
            
            HStack(spacing: 20) {
                EnergyBarView(title: "Physical", value: physical, color: .red)
                EnergyBarView(title: "Mental", value: mental, color: .blue)
            }
        }
        .padding(20)
        .secondaryCardStyle()
    }
}

struct EnergyBarView: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.colorText.opacity(0.8))
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.mainBack.opacity(0.4))
                        .frame(height: 10)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(value), height: 10)
                        .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 10)
        }
    }
}

struct ActivityRowView: View {
    let activity: ScheduledActivity
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(activity.type.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: activity.type.icon)
                    .foregroundColor(activity.type.color)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.colorText)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(activity.scheduledTime, style: .time)
                        .font(.caption)
                }
                .foregroundColor(.colorText.opacity(0.7))
            }
            
            Spacer()
            
            Text(activity.priority.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(activity.priority.color.opacity(0.2))
                )
                .foregroundColor(activity.priority.color)
        }
        .padding(16)
        .smallCardStyle()
    }
}

struct RecommendationsView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    var onRecommendationTap: ((ActivityType, Date) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                Text("Recommendations")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.colorText)
            }
            
            let recommendations = generateRecommendations()
            
            if recommendations.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("All tasks are optimally scheduled!")
                            .font(.subheadline)
                            .foregroundColor(.colorText.opacity(0.7))
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(recommendations, id: \.0) { activityType, recommendedTime in
                    RecommendationRowView(
                        activityType: activityType,
                        recommendedTime: recommendedTime,
                        onTap: {
                            onRecommendationTap?(activityType, recommendedTime)
                        }
                    )
                }
            }
        }
        .padding(20)
        .secondaryCardStyle()
    }
    
    private func generateRecommendations() -> [(ActivityType, Date)] {
        var recommendations: [(ActivityType, Date)] = []
        
        // Check each activity type
        for activityType in ActivityType.allCases {
            if let recommendedTime = viewModel.recommendTime(for: activityType) {
                // Check if there are already scheduled activities of this type
                let hasScheduled = viewModel.todayActivities.contains { $0.type == activityType }
                
                if !hasScheduled {
                    recommendations.append((activityType, recommendedTime))
                }
            }
        }
        
        return recommendations.sorted { $0.1 < $1.1 }
    }
}

struct RecommendationRowView: View {
    let activityType: ActivityType
    let recommendedTime: Date
    var onTap: (() -> Void)?
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onTap?()
            }
        }) {
            HStack(spacing: 16) {
            // Icon with gradient and glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                activityType.color.opacity(0.4),
                                activityType.color.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .blur(radius: 4)
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                activityType.color.opacity(0.3),
                                activityType.color.opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(activityType.color.opacity(0.4), lineWidth: 1.5)
                    )
                
                Image(systemName: activityType.icon)
                    .foregroundColor(activityType.color)
                    .font(.system(size: 22, weight: .bold))
            }
            .shadow(color: activityType.color.opacity(0.3), radius: 6, x: 0, y: 3)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(activityType.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.colorText)
                
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.color1.opacity(0.3))
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundColor(.color1)
                    }
                    
                    Text("Recommended: \(recommendedTime, style: .time)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.colorText.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.color1)
                .font(.title3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.mainBack.opacity(0.8),
                            Color.mainBack.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.color1.opacity(0.3),
                            Color.color1.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .shadow(color: Color.color1.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .buttonStyle(PlainButtonStyle())
        }
        
    }


#Preview {
    DashboardView(viewModel: EnergyCycleViewModel())
}

