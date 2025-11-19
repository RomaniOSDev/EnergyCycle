//
//  ActivitiesView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct ActivitiesView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    @State private var showingAddActivity = false
    @State private var selectedActivityForEdit: ScheduledActivity?
    
    var body: some View {
        ZStack {
            Color.mainBack
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    Text("Tasks")
                        .font(.system(size: 35, weight: .heavy, design: .monospaced))
                    
                    VStack(spacing: 16) {
                        if viewModel.todayActivities.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 50))
                                    .foregroundColor(.colorText.opacity(0.5))
                                Text("No scheduled tasks")
                                    .foregroundColor(.colorText.opacity(0.7))
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(viewModel.todayActivities) { activity in
                                ActivityListRowViewWithActions(
                                    activity: activity,
                                    viewModel: viewModel,
                                    onEdit: {
                                        selectedActivityForEdit = activity
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                }
                .foregroundColor(.colorText)
                
                // Floating add button
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddActivity = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.color1, Color.color1.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: Color.color1.opacity(0.4), radius: 8, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView(viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
            .sheet(item: $selectedActivityForEdit) { activity in
                EditActivityView(viewModel: viewModel, activity: activity)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

struct ActivityListRowViewWithActions: View {
    let activity: ScheduledActivity
    @ObservedObject var viewModel: EnergyCycleViewModel
    let onEdit: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Swipe actions background
            HStack(spacing: 0) {
                // Complete button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.completeActivity(activity)
                        offset = 0
                        isSwiped = false
                    }
                }) {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("Complete")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80)
                    .frame(maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                
                // Edit button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        offset = 0
                        isSwiped = false
                        onEdit()
                    }
                }) {
                    VStack {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                        Text("Edit")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80)
                    .frame(maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                
                // Delete button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.removeActivity(activity)
                        offset = 0
                        isSwiped = false
                    }
                }) {
                    VStack {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                        Text("Delete")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80)
                    .frame(maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .cornerRadius(20)
            
            // Main content
            NavigationLink(destination: ActivityDetailView(activity: activity, viewModel: viewModel)) {
                ActivityListRowView(activity: activity)
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -240)
                        } else if isSwiped {
                            offset = value.translation.width - 240
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if value.translation.width < -100 {
                                offset = -240
                                isSwiped = true
                            } else if value.translation.width > 100 && isSwiped {
                                offset = 0
                                isSwiped = false
                            } else {
                                offset = isSwiped ? -240 : 0
                            }
                        }
                    }
            )
        }
    }
}

struct ActivityListRowView: View {
    let activity: ScheduledActivity
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                activity.type.color.opacity(0.4),
                                activity.type.color.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .blur(radius: 4)
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                activity.type.color.opacity(0.3),
                                activity.type.color.opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(activity.type.color.opacity(0.4), lineWidth: 1.5)
                    )
                
                Image(systemName: activity.type.icon)
                    .foregroundColor(activity.type.color)
                    .font(.system(size: 24, weight: .bold))
            }
            .shadow(color: activity.type.color.opacity(0.3), radius: 6, x: 0, y: 3)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text(activity.scheduledTime, style: .time)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.caption)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "hourglass")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(Int(activity.duration / 60)) min")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Priority badge
            VStack(spacing: 4) {
                Text(activity.priority.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        activity.priority.color.opacity(0.3),
                                        activity.priority.color.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .foregroundColor(activity.priority.color)
                    .overlay(
                        Capsule()
                            .stroke(activity.priority.color.opacity(0.5), lineWidth: 1.5)
                    )
                    .shadow(color: activity.priority.color.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.color1,
                            Color.color1.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
        .shadow(color: Color.color1.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct ActivityDetailView: View {
    let activity: ScheduledActivity
    @ObservedObject var viewModel: EnergyCycleViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
            ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(activity.type.color.opacity(0.2))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: activity.type.icon)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(activity.type.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(activity.type.rawValue)
                            .font(.headline)
                            .foregroundColor(.colorText.opacity(0.8))
                        Text(activity.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.colorText)
                    }
                }
                .padding(.bottom, 8)
                
                Divider()
                    .background(Color.colorText.opacity(0.2))
                
                VStack(alignment: .leading, spacing: 16) {
                    DetailRowView(title: "Time", value: activity.scheduledTime.formatted(date: .omitted, time: .shortened))
                    DetailRowView(title: "Duration", value: "\(Int(activity.duration / 60)) minutes")
                    DetailRowView(title: "Priority", value: activity.priority.rawValue)
                    
                    if let recommendedTime = viewModel.recommendTime(for: activity.type) {
                        let timeDiff = abs(recommendedTime.timeIntervalSince(activity.scheduledTime))
                        if timeDiff > 1800 { // more than 30 minutes difference
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                Text("Recommended time: \(recommendedTime, style: .time)")
                                    .font(.subheadline)
                                    .foregroundColor(.colorText)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.orange.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color.mainBack)
        }
        .background(Color.mainBack)
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.colorText)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.colorText)
                }
            }
        }
        
    }
}

struct DetailRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.color1.opacity(0.3))
                    .frame(width: 6, height: 6)
                Text(title)
                    .foregroundColor(.colorText.opacity(0.7))
            }
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.colorText)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ActivitiesView(viewModel: EnergyCycleViewModel())
}

