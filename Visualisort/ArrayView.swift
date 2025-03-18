//
//  ArrayView.swift
//  Visualisort
//
//  Created by chr1s on 2/13/25.
//

import SwiftUI
import UIKit

struct NumericInput: Identifiable {
    let id = UUID()
    var value: String {
        didSet {
            value = value.filter { $0.isNumber }
        }
    }
}

struct ArrayView: View {
    @Binding var isShowingArray: Bool
    @Binding var isSorted: Bool
    @Binding var array: [Int]
    @Binding var steps: [[Int]]
    @Binding var displayedStep: [Int]
    
    @FocusState private var focusedIndex: UUID?
    @State private var editMode: EditMode = .inactive
    @State private var unsavedArray: [NumericInput] = []
    
    init(isShowingArray: Binding<Bool>, isSorted: Binding<Bool>, array: Binding<[Int]>, steps: Binding<[[Int]]>, displayedStep: Binding<[Int]>) {
        self._isShowingArray = isShowingArray
        self._isSorted = isSorted
        self._array = array
        self._steps = steps
        self._displayedStep = displayedStep

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(ColorPalette.white)
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = UIColor(ColorPalette.white)
        UIToolbar.appearance().standardAppearance = toolbarAppearance
        UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance
    }

    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach($unsavedArray) { $item in
                        HStack {
                            Button {
                                withAnimation {
                                    if let index = unsavedArray.firstIndex(where: { $0.id == item.id }) {
                                        unsavedArray.remove(at: index)
                                    }
                                }
                            }
                            label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(ColorPalette.red)
                                    .frame(width: 15)
                            }
                            .padding(.trailing, 8)
                            .frame(width: editMode == .active ? 24 : 0)
                            .opacity(editMode == .active ? 1 : 0)
                            .animation(.easeInOut, value: editMode)
                            
                            TextField("Enter Value", text: $item.value)
                                .keyboardType(.numberPad)
                                .focused($focusedIndex, equals: item.id)
                            
                            Spacer()
                            
                        }
                        .listRowBackground(ColorPalette.white)
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = unsavedArray.firstIndex(where: { $0.id == item.id }) {
                                    unsavedArray.remove(at: index)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(ColorPalette.red)
                        }
                    }
                    .onMove { from, to in
                        withAnimation {
                            unsavedArray.move(fromOffsets: from, toOffset: to)
                        }
                    }
                }
                .environment(\.editMode, $editMode)
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .background(ColorPalette.white)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorPalette.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editMode == .active ? "Done" : "Edit") {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    }
                    .bold()
                    .foregroundStyle(ColorPalette.black)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isShowingArray.toggle()
                    }
                    .bold()
                    .foregroundStyle(ColorPalette.black)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation {
                            unsavedArray.append(NumericInput(value: ""))
                        }
                    } label: {
                        HStack {
//                            Text("Add Number")
                            Image(systemName: "plus")
                        }
                        .bold()
                        .foregroundStyle(ColorPalette.black)
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            withAnimation {
                                randomizeArray()
                            }
                        } label: {
                            HStack {
                                // Text("Randomize")
                                Image(systemName: "dice")
                            }
                            .bold()
                            .foregroundStyle(ColorPalette.black)
                        }
                        
                        Button {
                            withAnimation {
                                // The default array
                                unsavedArray = [8, 10, 6, 3, 7, 2, 1, 5, 9, 4].map { NumericInput(value: "\($0)") }
                            }
                        } label: {
                            HStack {
                                // Text("Reset")
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .bold()
                            .foregroundStyle(ColorPalette.black)
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        array = unsavedArray.map { Int($0.value) ?? 0 }
                        steps = []
                        displayedStep = array
                        isSorted = false
                        isShowingArray.toggle()
                    }
                    .bold()
                    .foregroundStyle(unsavedArray.map { Int($0.value) ?? 0 } == array ? ColorPalette.black.opacity(0.5) : ColorPalette.black)
                    .disabled(unsavedArray.map { Int($0.value) ?? 0 } == array)
                }
            }
            .background(ColorPalette.white)
            .onAppear {
                unsavedArray = array.map { NumericInput(value: "\($0)") }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    func removeRows(from offsets: IndexSet) {
        withAnimation {
            unsavedArray.remove(atOffsets: offsets)
        }
    }
    
    func randomizeArray() {
        let arraySize: Int = Int.random(in: 20...60)
        unsavedArray = []
        let tempArray: [Int] = Int.getUniqueRandomNumbers(min: 1, max: 100, count: arraySize)
        unsavedArray = tempArray.map { NumericInput(value: "\($0)") }
    }
}

// For generating unique numbers
extension Int {
    static func getUniqueRandomNumbers(min: Int, max: Int, count: Int) -> [Int] {
        var set = Set<Int>()
        while set.count < count {
            set.insert(Int.random(in: min...max))
        }
        return Array(set)
    }
}
