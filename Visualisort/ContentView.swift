//
//  ContentView.swift
//  Visualisort
//
//  Created by chr1s on 2/11/25.
//

import SwiftUI
import Charts
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppState.timestamp, ascending: true)],
        animation: .default)
    private var savedSessions: FetchedResults<AppState>
    
    @State private var isShowingArray: Bool = false
    @State private var isShowingPicker: Bool = false
    @State private var isSorted: Bool = false
    @State private var isPlayingAnimation: Bool = false
    @State private var selectedAlgorithm: SortingAlgorithm = .mergeSort
    @State private var array: [Int] = [8, 10, 6, 3, 7, 2, 1, 5, 9, 4]
    @State private var steps: [[Int]] = []
    @State private var displayedStep: [Int] = []
    @State private var activeIndex: Int? = nil
    @State private var previousStep: [Int] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.white.ignoresSafeArea(.all)
                
                VStack {
                    VStack {
                        HStack {
                            Text("Visualisort")
                                .font(.system(size: 35).weight(.bold))
                                .textCase(.uppercase)
                                .foregroundStyle(ColorPalette.black)
                            Spacer()
                            Button { }
                            label: {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(ColorPalette.darkGray)
                            }
                        }
                        .padding(.top)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(ColorPalette.black, style: StrokeStyle(lineWidth: 1))
                            
                            ScrollViewReader { scrollView in
                                ScrollView(.horizontal, showsIndicators: true) {
                                    LazyHStack(alignment: .bottom, spacing: 0) {
                                        let maxValue = displayedStep.max() ?? 1
                                        let maxHeight: CGFloat = 150
                                        let minHeight: CGFloat = 30
                                        
                                        ForEach(displayedStep.indices, id: \.self) { index in
                                            VStack {
                                                Text(String(displayedStep[index]))
                                                    .font(.system(size: 10).monospacedDigit())
                                                    .foregroundStyle(ColorPalette.darkGray)
                                                    .lineLimit(1)
                                                    .frame(width: 30, alignment: .center)
                                                
                                                Rectangle()
                                                    .fill(ColorPalette.pink)
                                                    .frame(
                                                        width: 20,
                                                        height: minHeight + CGFloat(displayedStep[index]) / CGFloat(maxValue) * maxHeight
                                                    )
                                                    .animation(.easeInOut(duration: 0.2), value: displayedStep)
                                            }
                                            .id(index)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                }
                                .onChange(of: displayedStep) { newStep in
                                    if let changingIndex = findChangingIndex(oldArray: previousStep, newArray: newStep) {
                                        activeIndex = changingIndex
                                        withAnimation {
                                            scrollView.scrollTo(changingIndex, anchor: .center)
                                        }
                                    }
                                    previousStep = newStep
                                }
                            }
                        }
                        .frame(height: 250)
                        .padding(.vertical)
                    }
                    .padding(.horizontal, 15)
                    
                    ScrollView {
                        VStack {
                            VStack {
                                Button {
                                    withAnimation(.none) {
                                        isShowingArray.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Array")
                                            .bold()
                                            .textCase(.uppercase)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .padding(.horizontal, 5)
                                    }
                                }
                                .sheet(isPresented: $isShowingArray) {} content: {
                                    ArrayView(isShowingArray: $isShowingArray, isSorted: $isSorted, array: $array, steps: $steps, displayedStep: $displayedStep)
                                }
                                .buttonStyle(MainButtonStyle())
                            }
                            .padding(.vertical)
                            
                            HStack {
                                
                                Button {
                                    withAnimation(.none) {
                                        isShowingPicker.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedAlgorithm.rawValue)
                                            .bold()
                                            .textCase(.uppercase)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .padding(.horizontal, 5)
                                    }
                                }
                                .buttonStyle(MainButtonStyle())
                                
                                Button {
                                    sortArray()
                                    isPlayingAnimation = false
                                } label: {
                                    Text("Sort")
                                        .bold()
                                        .textCase(.uppercase)
                                }
                                .disabled(isPlayingAnimation)
                                .buttonStyle(SortButtonStyle())
                                .padding(.leading)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom)
                        
                        HStack {
                            VStack {
                                HStack {
                                    Text("Steps")
                                        .font(.system(size: 35).weight(.bold))
                                        .textCase(.uppercase)
                                        .foregroundStyle(ColorPalette.black)
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("Tap on a step to display it")
                                        .font(.system(size: 10).weight(.light))
                                        .textCase(.uppercase)
                                        .foregroundStyle(ColorPalette.darkGray)
                                    
                                    Spacer()
                                }
                                
                            }
                            
                            VStack {
                                Button {
                                    if !isPlayingAnimation {
                                        isPlayingAnimation.toggle()
                                        playAnimation()
                                    }
                                }
                                label: {
                                    HStack {
                                        Text("Play")
                                            .bold()
                                            .textCase(.uppercase)
                                        
                                        Image(systemName: "play")
                                    }
                                    .foregroundStyle(isSorted && !isPlayingAnimation ? ColorPalette.black : ColorPalette.lightGray)
                                }
                                .disabled(!isSorted || isPlayingAnimation)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom)
                        
                        VStack {
                            // The original array, i.e. step 0
                            Button {
                                displayedStep = array
                            } label: {
                                Text(array.map { String($0) }.joined(separator: ", "))
                                    .padding(.all)
                                    .foregroundStyle(ColorPalette.darkGray)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(ColorPalette.black, lineWidth: displayedStep == array ? 2 : 1)
                            }
                            .padding(.bottom)
                            
                            // All the other steps
                            ForEach(steps, id: \.self) { step in
                                Button {
                                    displayedStep = step
                                } label: {
                                    Text(step.map { String($0) }.joined(separator: ", "))
                                        .padding(.vertical)
                                        .padding(.leading)
                                        .foregroundStyle(ColorPalette.darkGray)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(ColorPalette.black, lineWidth: displayedStep == step ? 2 : 1)
                                }
                            }
                            .padding(.bottom)
                        }
                        .padding(.horizontal, 15)
                    }
                    Spacer()
                }
                
                if isShowingPicker {
                    CustomPicker(isShowingPicker: $isShowingPicker, isPlayingAnimation: $isPlayingAnimation, isSorted: $isSorted, selectedAlgorithm: $selectedAlgorithm, steps: $steps)
                }
            }
        }
        .onAppear {
            displayedStep = array
            loadSortingstate()
        }
        .preferredColorScheme(.light)
    }
    
    private func sortArray() {
        steps = []
        
        switch(selectedAlgorithm) {
        case .mergeSort:
            SortingAlgorithms.mergeSort(array: array, steps: &steps)
        case .bubbleSort:
            SortingAlgorithms.bubbleSort(array: array, steps: &steps)
        case .quickSort:
            SortingAlgorithms.quickSort(array: array, steps: &steps)
        case .insertionSort:
            SortingAlgorithms.insertionSort(array: array, steps: &steps)
        }
        
        isSorted = true
        displayedStep = array
        saveSortingState()
    }
    
    // Func to start the sorting animation
    private func playAnimation() {
        guard !steps.isEmpty else { return }
        
        isPlayingAnimation = true
        var stepIndex = 0
        
        // DispatchQueue to add a delay for the first step
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            displayedStep = array
            
            Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                    if stepIndex < steps.count {
                        displayedStep = steps[stepIndex]
                        stepIndex += 1
                    } else {
                        timer.invalidate()
                        isPlayingAnimation = false
                    }
                }
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    // Function to find the index where a sort is occurring
    private func findChangingIndex(oldArray: [Int], newArray: [Int]) -> Int? {
        for i in oldArray.indices {
            if oldArray[i] != newArray[i] {
                return i
            }
        }
        return nil
    }
    
    // Resets everything
    private func reset() {
        isSorted = false
        steps = []
        displayedStep = array
        isPlayingAnimation = false
    }
    
    // Save the current app state
    private func saveSortingState() {
        let newItem = AppState(context: viewContext)
        newItem.timestamp = Date()
        newItem.algorithm = selectedAlgorithm.rawValue
        newItem.array = array as NSObject
        newItem.steps = steps as NSObject
        newItem.displayedStep = displayedStep as NSObject
        
        do {
            try viewContext.save()
        } catch {
            print("Something went wrong: \(error)")
        }
    }
    
    private func loadSortingstate() {
        let fetchRequest: NSFetchRequest<AppState> = AppState.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AppState.timestamp, ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let savedState = try viewContext.fetch(fetchRequest).first {
                selectedAlgorithm = SortingAlgorithm(rawValue: savedState.algorithm ?? "") ?? .mergeSort
                array = savedState.array as? [Int] ?? []
                steps = savedState.steps as? [[Int]] ?? []
                displayedStep = savedState.displayedStep as? [Int] ?? []
                isSorted = !steps.isEmpty
            }
        } catch {
            print("Failed to load sorting state: \(error)")
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

enum SortingAlgorithm: String, CaseIterable, Identifiable, Codable {
    case mergeSort = "Merge Sort"
    case quickSort = "Quick Sort"
    case bubbleSort = "Bubble Sort"
    case insertionSort = "Insertion Sort"

    var id: String { self.rawValue }
}
