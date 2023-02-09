//
//  ContentView.swift
//  BetterRest
//
//  Created by Matheus Müller on 07/02/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepingAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 0
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var timeToSleep: Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepingAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime
        } catch {
            return Date.now
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Please enter a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepingAmount.formatted()) hours", value: $sleepingAmount, in: 4...12, step: 0.5)
                } header: {
                    Text("Desire amount of sleep")
                        .font(.headline)
                }
                
                Section {
                    Picker("Amount", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("\($0) cups")
                        }
                    }
                } header: {
                    Text("Daily coffee intake")
                        .font(.headline)
                }
                
                Section {
                    Text(timeToSleep, style: .time)
                        .font(.system(size: 40))
                        .frame(maxWidth: .infinity, alignment: .center)
                } header: {
                    Text("Your ideal bedtime is...")
                        .font(.headline)
                }
            }
            .navigationTitle("BetterRest")
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
