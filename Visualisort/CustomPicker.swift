//
//  CustomPicker.swift
//  Visualisort
//
//  Created by chr1s on 2/12/25.
//

import SwiftUI

struct CustomPicker: View {
    @Binding var isShowingPicker: Bool
    @Binding var isPlayingAnimation: Bool
    @Binding var isSorted: Bool
    @Binding var selectedAlgorithm: SortingAlgorithm
    @Binding var steps: [[Int]]
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemChromeMaterialDark)
                .opacity(isVisible ? 0.4 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: isVisible)
                .ignoresSafeArea(.all)

            VStack {
                Spacer()
                
                if isShowingPicker {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            
                            VStack {
                                VStack {
                                    Spacer()
                                    
                                    Text("Select Algorithm")
                                        .bold()
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Divider()
                                        .overlay(ColorPalette.darkGray)
                                        .frame(height: 1)
                                }
                                .frame(height: 60)
                                
                                ForEach(SortingAlgorithm.allCases) { algorithm in
                                    Button {
                                        selectedAlgorithm = algorithm
                                        isShowingPicker = false
                                        isPlayingAnimation = false
                                        isSorted = false
                                        steps = []
                                    } label: {
                                        HStack {
                                            Spacer()
                                            Text(algorithm.rawValue)
                                                .foregroundStyle(ColorPalette.darkGray)
                                            Spacer()
                                        }
                                    }
                                    .frame(height: 50)
                                }
                                
                                VStack {
                                    Divider()
                                        .overlay(ColorPalette.darkGray)
                                        .frame(height: 1)
                                    
                                    Spacer()
                                    
                                    Button {
                                        isShowingPicker = false
                                    }
                                    label: {
                                        HStack {
                                            Spacer()
                                            Text("Cancel")
                                                .bold()
                                                .foregroundStyle(ColorPalette.black)
                                            Spacer()
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .frame(height: 60)
                            }
                            .font(.system(size: 16))
                            .background(ColorPalette.white)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .transition(.scale(scale: 1.1).combined(with: .opacity))
                            .frame(width: geometry.size.width * 0.85)
                            .scaleEffect(isVisible ? 1 : 0.3)
                            .opacity(isVisible ? 1 : 0)
                            
                            Spacer()
                        }
                    }
                    .frame(height: 400)
                    .transition(.move(edge: .bottom))
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
        
        .onDisappear {
            withAnimation(.easeInOut) {
                isVisible = false
            }
        }
    }
}
