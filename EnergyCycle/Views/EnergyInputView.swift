//
//  EnergyInputView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct EnergyInputView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var physicalEnergy: Double = 0.5
    @State private var mentalEnergy: Double = 0.5
    @State private var selectedTime: Date
    
    init(viewModel: EnergyCycleViewModel, initialTime: Date = Date()) {
        self.viewModel = viewModel
        _selectedTime = State(initialValue: initialTime)
        
        // Загрузить текущие значения энергии для выбранного времени, если есть
        let currentEnergy = viewModel.getEnergyLevel(at: initialTime)
        _physicalEnergy = State(initialValue: currentEnergy.physical)
        _mentalEnergy = State(initialValue: currentEnergy.mental)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Measurement Time") {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: [.date, .hourAndMinute])
                        .foregroundColor(.white)
                        .colorScheme(.dark)
                }
                .listRowBackground(Color.color1)
                
                Section("Physical Energy") {
                    VStack(spacing: 12) {
                        Slider(value: $physicalEnergy, in: 0...1)
                            .tint(.white)
                        HStack {
                            Text("0%")
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("\(Int(physicalEnergy * 100))%")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("100%")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .font(.caption)
                    }
                }
                .listRowBackground(Color.color1)
                
                Section("Mental Energy") {
                    VStack(spacing: 12) {
                        Slider(value: $mentalEnergy, in: 0...1)
                            .tint(.white)
                        HStack {
                            Text("0%")
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("\(Int(mentalEnergy * 100))%")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("100%")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .font(.caption)
                    }
                }
                .listRowBackground(Color.color1)
                
                Section {
                    Button(action: saveEnergy) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .tint(Color.color1)
                }
                .listRowBackground(Color.color1)
            }
            .background(Color.mainBack)
            .scrollContentBackground(.hidden)
            .navigationTitle("Energy Assessment")
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
            }
        }
    }
    
    private func saveEnergy() {
        viewModel.updateEnergyLevel(
            at: selectedTime,
            physical: physicalEnergy,
            mental: mentalEnergy
        )
        dismiss()
    }
}

#Preview {
    EnergyInputView(viewModel: EnergyCycleViewModel())
}

