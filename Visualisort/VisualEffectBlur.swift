//
//  VisualEffectBlur.swift
//  Visualisort
//
//  Created by chr1s on 2/12/25.
//


import SwiftUI
import UIKit

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        let effect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        for subview in uiView.subviews {
            if let blurView = subview as? UIVisualEffectView {
                blurView.effect = UIBlurEffect(style: blurStyle)
            }
        }
    }
}
