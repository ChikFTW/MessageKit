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
    
    open var bounceOffset: CGFloat = 7.5 { didSet { layoutSubviews() } }
    
    open var dotColor: UIColor = UIColor.lightGray {
        didSet {
            dots.forEach { $0.backgroundColor = dotColor }
        }
    }
    
    open var isBounceEnabled: Bool = false
    
    open var isFadeEnabled: Bool = true
    
    public private(set) var isAnimating: Bool = false
    
    private struct AnimationKeys {
        static let bounce = "typingIndicator.bounce"
        static let opacity = "typingIndicator.opacity"
    }
    
    // MARK: - Subviews
    
    public let leftDot = Circle()
    
    public let middleDot = Circle()
    
    public let rightDot = Circle()
    
    public let stackView = UIStackView()
    
    public var dots: [Circle] {
        return [leftDot, middleDot, rightDot]
    }
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        dots.forEach {
            $0.backgroundColor = dotColor
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        addSubview(stackView)
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
    }
    
    // MARK: - Animation Layers
    
    open func bounceAnimationLayer() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.byValue = -bounceOffset
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    open func opacityAnimationLayer() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0.5
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    // MARK: - Animation API
    
    open func startAnimating() {
        defer { isAnimating = true }
        guard !isAnimating else { return }
        var delay: TimeInterval = 0
        for dot in dots {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let this = self else { return }
                if this.isBounceEnabled {
                    dot.layer.add(this.bounceAnimationLayer(), forKey: AnimationKeys.bounce)
                }
                if this.isFadeEnabled {
                    dot.layer.add(this.opacityAnimationLayer(), forKey: AnimationKeys.opacity)
                }
            }
            delay += 0.33
        }
    }
    
    open func stopAnimating() {
        defer { isAnimating = false }
        guard isAnimating else { return }
        dots.forEach { $0.layer.removeAnimation(forKey: AnimationKeys.bounce) }
    }
    
}
