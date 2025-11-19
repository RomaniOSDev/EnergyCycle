//
//  EditActivityView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct EditActivityView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    @Environment(\.dismiss) var dismiss
    
    let activity: ScheduledActivity
    
    @State private var title: String
    @State private var selectedType: ActivityType
    @State private var scheduledTime: Date
    @State private var duration: TimeInterval
    @State private var selectedPriority: Priority
    @State private var showingRecommendation = false
    
    init(viewModel: EnergyCycleViewModel, activity: ScheduledActivity) {
        self.viewModel = viewModel
        self.activity = activity
        _title = State(initialValue: activity.title)
        _selectedType = State(initialValue: activity.type)
        _scheduledTime = State(initialValue: activity.scheduledTime)
        _duration = State(initialValue: activity.duration)
        _selectedPriority = State(initialValue: activity.priority)
    }
    
    var recommendedTime: Date? {
        viewModel.recommendTime(for: selectedType)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainBack
                    .ignoresSafeArea()
                
                Form {
                    Section("Task Title") {
                        TextField("Enter title", text: $title)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.color1)
                    
                    Section("Activity Type") {
                        Picker("Type", selection: $selectedType) {
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue)
                                        .foregroundColor(.white)
                                }
                                .tag(type)
                            }
                        }
                        .foregroundColor(.white)
                        .onChange(of: selectedType) { _ in
                            if let recommended = recommendedTime {
                                scheduledTime = recommended
                                showingRecommendation = true
                            }
                        }
                    }
                    .listRowBackground(Color.color1)
                    
                    if let recommended = recommendedTime, showingRecommendation {
                        Section {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Recommended time: \(recommended, style: .time)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.color1)
                    }
                    
                    Section("Execution Time") {
                        DatePicker("Time", selection: $scheduledTime, displayedComponents: [.date, .hourAndMinute])
                            .foregroundColor(.white)
                            .colorScheme(.dark)
                        
                        Picker("Duration", selection: $duration) {
                            Text("15 minutes").tag(TimeInterval(900))
                            Text("30 minutes").tag(TimeInterval(1800))
                            Text("1 hour").tag(TimeInterval(3600))
                            Text("2 hours").tag(TimeInterval(7200))
                            Text("3 hours").tag(TimeInterval(10800))
                            Text("4 hours").tag(TimeInterval(14400))
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.color1)
                    
                    Section("Priority") {
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                                    .foregroundColor(.white)
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.color1)
                    
                    Section {
                        Button(action: saveActivity) {
                            HStack {
                                Spacer()
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .disabled(title.isEmpty)
                        .tint(Color.color1)
                    }
                    .listRowBackground(Color.color1)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.colorText)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.colorText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveActivity()
                    }
                    .foregroundColor(.colorText)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveActivity() {
        let updatedActivity = ScheduledActivity(
            id: activity.id,
            title: title,
            type: selectedType,
            scheduledTime: scheduledTime,
            duration: duration,
            priority: selectedPriority
        )
        viewModel.updateActivity(updatedActivity)
        dismiss()
    }
}

#Preview {
    EditActivityView(
        viewModel: EnergyCycleViewModel(),
        activity: ScheduledActivity(
            title: "Test Task",
            type: .deepWork,
            scheduledTime: Date(),
            duration: 3600,
            priority: .high
        )
    )
}

