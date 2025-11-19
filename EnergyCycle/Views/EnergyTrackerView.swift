//
//  EnergyTrackerView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct EnergyTrackerView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    @State private var showingEnergyInput = false
    @State private var selectedTime = Date()
    
    var body: some View {
        ZStack {
            Color.mainBack
                .ignoresSafeArea()
            ScrollView {
                Text("Energy Tracker")
                    .font(.system(size: 35, weight: .heavy, design: .monospaced))
                VStack(spacing: 20) {
                    // График энергии
                    EnergyChartView(energyCycle: viewModel.energyCycle)
                        .frame(height: 300)
                        .padding()
                    
                    // Energy measurement points
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Measurement Points")
                            .font(.headline)
                            .foregroundColor(.colorText)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.energyCycle.energyLevels.sorted(by: { $0.time < $1.time })) { point in
                            EnergyPointRowView(point: point)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Add measurement button
                    Button(action: {
                        selectedTime = Date()
                        showingEnergyInput = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Add Measurement")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.white)
                        .primaryButtonStyle()
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical)
            }
            .foregroundColor(.colorText)
            .sheet(isPresented: $showingEnergyInput) {
                EnergyInputView(viewModel: viewModel, initialTime: selectedTime)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

struct EnergyChartView: View {
    let energyCycle: EnergyCycle
    
    var sortedPoints: [EnergyPoint] {
        energyCycle.energyLevels.sorted(by: { $0.time < $1.time })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.color1)
                    .font(.title3)
                Text("Energy Chart")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.colorText)
            }
            
            GeometryReader { geometry in
                ZStack {
                    // Сетка
                    GridView()
                    
                    // График физической энергии
                    if sortedPoints.count > 1 {
                        EnergyLine(
                            points: sortedPoints,
                            valueKeyPath: \.physicalEnergy,
                            color: .red,
                            geometry: geometry
                        )
                        
                        // График ментальной энергии
                        EnergyLine(
                            points: sortedPoints,
                            valueKeyPath: \.mentalEnergy,
                            color: .blue,
                            geometry: geometry
                        )
                    }
                    
                    // Легенда
                    VStack {
                        HStack(spacing: 16) {
                            LegendItem(color: .red, label: "Physical")
                            LegendItem(color: .blue, label: "Mental")
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .frame(height: 250)
        }
        .padding(20)
        .secondaryCardStyle()
    }
}

struct GridView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Горизонтальные линии
                for i in 0...4 {
                    let y = geometry.size.height * CGFloat(i) / 4.0
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                
                // Вертикальные линии
                for i in 0...4 {
                    let x = geometry.size.width * CGFloat(i) / 4.0
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
            }
            .stroke(Color.colorText.opacity(0.2), lineWidth: 0.5)
        }
    }
}

struct EnergyLine: View {
    let points: [EnergyPoint]
    let valueKeyPath: KeyPath<EnergyPoint, Double>
    let color: Color
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            // Shadow/glow effect
            Path { path in
                guard !points.isEmpty else { return }
                
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: points.first!.time)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                let dayDuration = endOfDay.timeIntervalSince(startOfDay)
                
                let minX: CGFloat = 0
                let maxX = geometry.size.width
                let minY: CGFloat = 0
                let maxY = geometry.size.height
                
                var isFirst = true
                
                for point in points {
                    let timeOffset = point.time.timeIntervalSince(startOfDay)
                    let x = minX + (maxX - minX) * CGFloat(timeOffset / dayDuration)
                    let value = point[keyPath: valueKeyPath]
                    let y = maxY - (maxY - minY) * CGFloat(value)
                    
                    if isFirst {
                        path.move(to: CGPoint(x: x, y: y))
                        isFirst = false
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color.opacity(0.3), lineWidth: 6)
            .blur(radius: 4)
            
            // Main line
            Path { path in
                guard !points.isEmpty else { return }
                
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: points.first!.time)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                let dayDuration = endOfDay.timeIntervalSince(startOfDay)
                
                let minX: CGFloat = 0
                let maxX = geometry.size.width
                let minY: CGFloat = 0
                let maxY = geometry.size.height
                
                var isFirst = true
                
                for point in points {
                    let timeOffset = point.time.timeIntervalSince(startOfDay)
                    let x = minX + (maxX - minX) * CGFloat(timeOffset / dayDuration)
                    let value = point[keyPath: valueKeyPath]
                    let y = maxY - (maxY - minY) * CGFloat(value)
                    
                    if isFirst {
                        path.move(to: CGPoint(x: x, y: y))
                        isFirst = false
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundColor(.colorText.opacity(0.7))
        }
    }
}

struct EnergyPointRowView: View {
    let point: EnergyPoint
    
    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                        .foregroundColor(.color1)
                    Text(point.time, style: .time)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.colorText)
                }
                
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("\(Int(point.physicalEnergy * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.colorText.opacity(0.8))
                    }
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Text("\(Int(point.mentalEnergy * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.colorText.opacity(0.8))
                    }
                }
            }
            
            Spacer()
            
            if point.userReported {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 18))
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.colorText.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.colorText.opacity(0.5))
                        .font(.system(size: 16))
                }
            }
        }
        .padding(16)
        .smallCardStyle()
    }
}

#Preview {
    EnergyTrackerView(viewModel: EnergyCycleViewModel())
}

