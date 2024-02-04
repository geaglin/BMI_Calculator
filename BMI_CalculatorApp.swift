import SwiftUI

class BMICalculatorViewModel: ObservableObject {
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var heightFeet: String = ""
    @Published var heightInches: String = ""
    @Published var selectedWeightUnit: Int = 0 // 0 for lbs, 1 for kgs
    @Published var selectedHeightUnit: Int = 0 // 0 for cm, 1 for ft/inches
    @Published var bmiResult: Double?
    @Published var showingAlert = false
    var bmiCategory: String {
        guard let bmi = bmiResult else { return "" }
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<24.9: return "Normal"
        case 24.9..<29.9: return "Overweight"
        default: return "Obese"
        }
    }
    func calculateBMI() {
        let weightInKgs: Double
        if let weightValue = Double(weight) {
            weightInKgs = selectedWeightUnit == 1 ? weightValue * 0.453592 : weightValue
        } else {
            showingAlert = true
            return
        }

        let heightInMeters: Double
        if selectedHeightUnit == 0 {
            guard let heightValue = Double(height) else {
                showingAlert = true
                return
            }
            heightInMeters = heightValue / 100.0
        } else {
            guard let feet = Double(heightFeet), let inches = Double(heightInches) else {
                showingAlert = true
                return
            }
            heightInMeters = (feet * 0.3048) + (inches * 0.0254)
        }

        bmiResult = weightInKgs / (heightInMeters * heightInMeters)

    }
}


struct BMIContentView: View {
    @StateObject private var viewModel = BMICalculatorViewModel()

    var body: some View {
        VStack {
            Text("BMI Calculator")
                .font(.largeTitle)
                .padding(.bottom, 20)

            TextField(viewModel.selectedWeightUnit == 0 ? "Weight (kgs)" : "Weight (lbs)", text: $viewModel.weight)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                if viewModel.selectedHeightUnit == 0 {
                    TextField("Height (cm)", text: $viewModel.height)
                        .keyboardType(.decimalPad)
                } else {
                    TextField("Height (ft)", text: $viewModel.heightFeet)
                        .keyboardType(.decimalPad)

                    TextField("Height (in)", text: $viewModel.heightInches)
                        .keyboardType(.decimalPad)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            Picker("Weight Unit", selection: $viewModel.selectedWeightUnit) {
                Text("lbs").tag(1)
                Text("kgs").tag(0)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Picker("Height Unit", selection: $viewModel.selectedHeightUnit) {
                Text("ft").tag(1)
                Text("cm").tag(0)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button(action: viewModel.calculateBMI) {
                Text("Calculate BMI")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            if let bmi = viewModel.bmiResult {
                Text("Your BMI: \(String(format: "%.2f", bmi))")
                    .font(.title)
                    .padding(.top, 20)
                Text("BMI Classification: \(viewModel.bmiCategory)")
                                    .font(.headline)
                                    .padding()
                           }
                       }
                       .padding()

        .alert(isPresented: $viewModel.showingAlert) {
            Alert(title: Text("Invalid Input"), message: Text("Please enter valid numbers."), dismissButton: .default(Text("OK")))
        }
    }
}

@main
struct BMICalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            BMIContentView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BMIContentView()
    }
}
