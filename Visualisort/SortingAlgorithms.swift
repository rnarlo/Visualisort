//
//  SortingAlgorithms.swift
//  Visualisort
//
//  Created by chr1s on 2/14/25.
//

import Foundation

struct SortingAlgorithms {
    
    // MARK: - Merge Sort
    static func mergeSort(array: [Int], steps: inout [[Int]]) {
        var tempArray = array
        mergeSortHelper(&tempArray, left: 0, right: tempArray.count - 1, steps: &steps)
    }
    
    private static func mergeSortHelper(_ array: inout [Int], left: Int, right: Int, steps: inout [[Int]]) {
        if left < right {
            let middle = (left + right) / 2
            mergeSortHelper(&array, left: left, right: middle, steps: &steps)
            mergeSortHelper(&array, left: middle + 1, right: right, steps: &steps)
            merge(&array, left: left, middle: middle, right: right, steps: &steps)
        }
    }
    
    private static func merge(_ array: inout [Int], left: Int, middle: Int, right: Int, steps: inout [[Int]]) {
        let leftArray = Array(array[left...middle])
        let rightArray = Array(array[middle+1...right])
        
        var i = 0, j = 0, k = left
        let previousState = array
        
        while i < leftArray.count && j < rightArray.count {
            if leftArray[i] <= rightArray[j] {
                array[k] = leftArray[i]
                i += 1
            } else {
                array[k] = rightArray[j]
                j += 1
            }
            k += 1
        }
        
        while i < leftArray.count {
            array[k] = leftArray[i]
            i += 1
            k += 1
        }
        
        while j < rightArray.count {
            array[k] = rightArray[j]
            j += 1
            k += 1
        }
        
        if previousState != array {
            steps.append(array)
        }
    }
    
    // MARK: Insertion Sort
        static func insertionSort(array: [Int], steps: inout [[Int]]) {
            var tempArray = array
            for i in 1..<tempArray.count {
                let previousState = tempArray
                
                let key = tempArray[i]
                var j = i - 1
                while j >= 0 && tempArray[j] > key {
                    tempArray[j + 1] = tempArray[j]
                    j -= 1
                    
                    tempArray[j + 1] = key
                    if previousState != tempArray {
                        steps.append(tempArray)
                    }
                }
            }
        }
    
    // MARK: - Bubble Sort
    static func bubbleSort(array: [Int], steps: inout [[Int]]) {
        var tempArray = array

        let n = tempArray.count
        for i in 0..<n-1 {
            let previousState = tempArray
            for j in 0..<(n-i-1) {
                if tempArray[j] > tempArray[j+1] {
                    tempArray.swapAt(j, j+1)
                    if previousState != tempArray {
                        steps.append(tempArray)
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Sort
    static func quickSort(array: [Int], steps: inout [[Int]]) {
        var tempArray = array
        quickSortHelper(&tempArray, low: 0, high: tempArray.count - 1, steps: &steps)
    }
    
    private static func quickSortHelper(_ array: inout [Int], low: Int, high: Int, steps: inout [[Int]]) {
        if low < high {
            let pivotIndex = partition(&array, low: low, high: high, steps: &steps)
            quickSortHelper(&array, low: low, high: pivotIndex - 1, steps: &steps)
            quickSortHelper(&array, low: pivotIndex + 1, high: high, steps: &steps)
        }
    }
    
    private static func partition(_ array: inout [Int], low: Int, high: Int, steps: inout [[Int]]) -> Int {
        let previousState = array
        let pivot = array[high]
        var i = low
        
        for j in low..<high {
            if array[j] < pivot {
                array.swapAt(i, j)
                i += 1
            }
        }
        
        array.swapAt(i, high)
        if previousState != array {
            steps.append(array)
        }
        return i
    }
}

