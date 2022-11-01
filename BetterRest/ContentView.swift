//
//  ContentView.swift
//  BetterRest
//
//  Created by Hasan Kaya on 27.10.2022.
//

import CoreML
import SwiftUI
struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(red: 225/255, green: 173/255, blue: 250/255),Color(red: 252/255, green: 180/255, blue: 180/255)], startPoint: .top, endPoint: .bottom)
                VStack {
                    VStack {
                        Text("When dou you want to wake up ?")
                            .font(.headline)
                            .padding()
                        
                        DatePicker(" ", selection: $wakeUp ,displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .padding()
                    }
                    .frame(width: 350,height: 150)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                    VStack {
                        Text("Desired Amount of sleep")
                            .font(.headline)
                            
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount,in: 4...12,step: 0.25)
                            .frame(width: 300,height: 100)
                            
                    }
                    .frame(width: 350,height: 150)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                    VStack {
                        Text("Daily coffee intake")
                            .font(.headline)
                            .padding()
                            
                        Stepper(coffeAmount == 1 ? "1 cup " : "\(coffeAmount) cups", value: $coffeAmount,in: 1...20,step: 1)
                            .frame(width: 300,height: 50)
                            .padding()
                            
                    }
                    .frame(width: 350,height: 150)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                    
                }
                
               
                
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button(action: calculateBedtime) {
                    Text("Calculate")
                    Image(systemName: "bed.double.fill")
                }
            }
            .ignoresSafeArea()
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            
        }
    }
    func calculateBedtime(){
        do {
            let config = MLModelConfiguration()
            let model = try BetterRest_1(configuration: config)
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hourToSecond = (components.hour ?? 0) * 60 * 60
            let minuteToSecond = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hourToSecond + minuteToSecond), estimatedSleep: Double(sleepAmount), coffee: Double(coffeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is... "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch  {
            alertTitle = "Error"
            alertMessage = "Sorry there was a problem to calculate your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
