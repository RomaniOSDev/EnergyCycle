//
//  AddActivityView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct AddActivityView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var selectedType: ActivityType = .deepWork
    @State private var scheduledTime: Date = Date()
    @State private var duration: TimeInterval = 3600 // 1 час по умолчанию
    @State private var selectedPriority: Priority = .medium
    @State private var showingRecommendation = false
    
    var recommendedTime: Date? {
        viewModel.recommendTime(for: selectedType)
    }
    
    var body: some View {
        
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
                            Text("Add Task")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty)
                    .tint(Color.color1)
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.colorText)
                }
                .listRowBackground(Color.color1)
            }
            .background(Color.mainBack)
            .scrollContentBackground(.hidden)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.colorText)
            .preferredColorScheme(.dark)
            
        
    }
    
    private func saveActivity() {
        let activity = ScheduledActivity(
            title: title,
            type: selectedType,
            scheduledTime: scheduledTime,
            duration: duration,
            priority: selectedPriority
        )
        viewModel.addActivity(activity)
        dismiss()
    }
}

#Preview {
    AddActivityView(viewModel: EnergyCycleViewModel())
}

