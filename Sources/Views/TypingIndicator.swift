/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class TypingIndicator: UIView {
    
    // MARK: - Properties
    
    /// The number of dots rendered in the typing indicator. The `DEFAULT` value is 3
    open var numberOfDots: Int = 3 {
        didSet {
            let wasAnimating = isAnimating
            stopAnimating()
            generateDots()
            layoutSubviews()
            if wasAnimating {
                startAnimating()
            }
        }
    }
    
    /// The distance between each dot, determied by the views frame and the number of dotes
    open var spacing: CGFloat {
        let fillWidth = bounds.width - (CGFloat(numberOfDots) * dotSize)
        return fillWidth / CGFloat(numberOfDots - 1)
    }
    
    /// The offset distance that the dot will animate towards
    open var bounceOffset: CGFloat = 7.5 { didSet { layoutSubviews() } }
    
    /// The duration of each bounce animation
    open var bounceDuration: TimeInterval = 0.35 {
        didSet {
            guard isAnimating else { return }
            stopAnimating()
            startAnimating()
        }
    }
    
    /// The height/width that each dot will be rendered with, determined by the
    /// height of the view and the bounce offset
    open var dotSize: CGFloat {
        return bounds.height - bounceOffset
    }
    
    /// The color of each dot
    open var dotColor: UIColor = .white {
        didSet {
            dots.forEach { $0.backgroundColor = dotColor }
        }
    }
    
    /// A boolean value indicating if the dots are animating
    public private(set) var isAnimating: Bool = false
    
    /// A reference to the `Circle` views
    private var dots: [Circle] = []
    
    /// The animation layer key for bouncing
    private let bounceAnimationKey = "bounce"
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        if frame.width == 0 || frame.height == 0 {
            let defaultSpacing = 5
            let defaultDotWidth = 30
            let defaultWidth = CGFloat(numberOfDots * defaultDotWidth) + CGFloat((numberOfDots - 1) * defaultSpacing)
            self.frame = CGRect(x: 0, y: 0, width: defaultWidth, height: CGFloat(defaultDotWidth) + bounceOffset)
        }
        generateDots()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Removes existing dotes from the view and generates new ones
    private func generateDots() {
        if !dots.isEmpty {
            dots.forEach { $0.removeFromSuperview() }
            dots.removeAll()
        }
        for _ in 0..<numberOfDots {
            let dot = Circle(radius: dotSize)
            dot.backgroundColor = dotColor
            addSubview(dot)
            dots.append(dot)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        var xOffset: CGFloat = 0
        for dot in dots {
            dot.frame.origin.x = xOffset
            xOffset += dotSize + spacing
        }
    }
    
    // MARK: - Animation
    
    /// The animation layer added to each dot
    ///
    /// - Returns: CABasicAnimation
    open func bounceAnimationLayer() -> CABasicAnimation {
        let anim = CABasicAnimation(keyPath: "position.y")
        anim.byValue = bounceOffset
        anim.duration = bounceDuration
        anim.repeatCount = .infinity
        anim.autoreverses = true
        return anim
    }
    
    /// Starts the animation of each dot
    open func startAnimating() {
        defer { isAnimating = true }
        guard !isAnimating else { return }
        var del: TimeInterval = 0
        for dot in dots {
            let layer = bounceAnimationLayer()
            let key = bounceAnimationKey
            DispatchQueue.main.asyncAfter(deadline: .now() + del) {
                dot.layer.add(layer, forKey: key)
            }
            del += bounceDuration / Double(numberOfDots - 1)
        }
    }
    
    /// Ends the animation of each dot
    open func stopAnimating() {
        defer { isAnimating = false }
        guard isAnimating else { return }
        dots.forEach { $0.layer.removeAnimation(forKey: bounceAnimationKey) }
    }
    
}
