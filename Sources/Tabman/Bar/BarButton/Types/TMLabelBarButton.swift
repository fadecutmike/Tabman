//
//  TMLabelBarButton.swift
//  Tabman
//
//  Created by Merrick Sapsford on 06/06/2018.
//  Copyright © 2020 UI At Six. All rights reserved.
//

import UIKit

/// `TMBarButton` that consists of a single label - that's it!
///
/// Probably the most commonly seen example of a bar button.
open class TMLabelBarButton: TMBarButton {
    
    // MARK: Defaults
    
    private struct Defaults {
        static let contentInset = UIEdgeInsets(top: 12.0, left: 0.0, bottom: 12.0, right: 0.0)
        static let font = UIFont.preferredFont(forTextStyle: .headline)
        static let text = "Item"
        static let badgeLeadingInset: CGFloat = 8.0
    }
    
    // MARK: Properties
    
    open override var intrinsicContentSize: CGSize {
        if let fontIntrinsicContentSize = self.fontIntrinsicContentSize {
            return fontIntrinsicContentSize
        }
        return super.intrinsicContentSize
    }
    
    private var fontIntrinsicContentSize: CGSize?
    private let label = AnimateableLabel()
    private let badgeContainer = UIView()
    private var badgeContainerWidth: NSLayoutConstraint?
    private var badgeCenterX: NSLayoutConstraint?
    private var badgeCenterY: NSLayoutConstraint?
    
    open override var contentInset: UIEdgeInsets {
        get {
            return super.contentInset
        }
        set {
            super.contentInset = newValue
            calculateFontIntrinsicContentSize(for: text)
        }
    }
    
    /// Text to display in the button.
    open var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    /// Color of the text when unselected / normal.
    open override var tintColor: UIColor! {
        didSet {
            if !isSelected {
                label.textColor = tintColor
            }
        }
    }
    /// Color of the text when selected.
    open var selectedTintColor: UIColor! {
        didSet {
            if isSelected  {
                label.textColor = selectedTintColor
            }
        }
    }
    /// Font of the text when unselected / normal.
    open var font: UIFont = Defaults.font {
        didSet {
            calculateFontIntrinsicContentSize(for: text)
            if !isSelected || selectedFont == nil {
                label.font = font
            }
        }
    }
    /// Font of the text when selected.
    open var selectedFont: UIFont? {
        didSet {
            calculateFontIntrinsicContentSize(for: text)
            guard let selectedFont = self.selectedFont, isSelected else {
                return
            }
            label.font = selectedFont
        }
    }
    /// A Boolean that indicates whether the object automatically updates its font when the device's content size category changes.
    ///
    /// Defaults to `false`.
    @available(iOS 11, *)
    open var adjustsFontForContentSizeCategory: Bool {
        get {
            label.adjustsFontForContentSizeCategory
        }
        set {
            label.adjustsFontForContentSizeCategory = newValue
        }
    }
    
    open var badgeOffsetAdustment: CGPoint = .zero {
        didSet { updateBadgeOffsetConstraints() }
    }

    open override func layout(in view: UIView) {
        super.layout(in: view)
        imgView.image = item.image
        
        view.addSubview(label)
        view.addSubview(imgView)
        view.addSubview(badgeContainer)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let offsetConst = getConstantBadgeOffsetValue()
        let badgeCenterX = badgeContainer.centerXAnchor.constraint(equalTo: label.trailingAnchor, constant: offsetConst.x)
        let badgeCenterY = badgeContainer.centerYAnchor.constraint(equalTo: label.topAnchor, constant: offsetConst.y)
        
        let badgeContainerWidth = badgeContainer.widthAnchor.constraint(equalToConstant: 0.0)
        let labelCenterConstraint = label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let labelCenterConstraintX = label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: item.image == nil ? 0.0 : 15.0)
        
        
        let imgConLeft = imgView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -6.0)
        let imgCenterY = imgView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let imgWidth = imgView.widthAnchor.constraint(equalToConstant: item.image == nil ? 0.0 : 24.0)
        let imgHeight = imgView.heightAnchor.constraint(equalToConstant: item.image == nil ? 0.0 : 24.0)
        
        let constraints = [
            badgeCenterX,
            badgeCenterY,
            labelCenterConstraint,
            labelCenterConstraintX,
            badgeContainerWidth,
            
            imgConLeft,
            imgCenterY,
            imgWidth,
            imgHeight
        ]

        self.badgeContainerWidth = badgeContainerWidth
        self.badgeCenterX = badgeCenterX
        self.badgeCenterY = badgeCenterY
        
        NSLayoutConstraint.activate(constraints)
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        adjustsAlphaOnSelection = false
        label.text = Defaults.text
        label.font = self.font
        if #available(iOS 13, *) {
            tintColor = .label
        } else {
            tintColor = .black
        }
        selectedTintColor = .systemBlue
        
        
        contentInset = Defaults.contentInset
        calculateFontIntrinsicContentSize(for: label.text)
    }
    
    // MARK: Layout
    
    private func getConstantBadgeOffsetValue() -> CGPoint {
        .init(x: badgeContainer.frame.width*3.0 + 8.0 + badgeOffsetAdustment.x, y: badgeContainer.frame.height*2.5 - 2.0 + badgeOffsetAdustment.y)
    }
    
    private func updateBadgeOffsetConstraints() {
        let offsetConst = getConstantBadgeOffsetValue()
        badgeCenterX?.constant = offsetConst.x
        badgeCenterY?.constant = offsetConst.y
        badgeContainer.layoutIfNeeded()
    }
    
    private func updateBadgeConstraints() {
        badgeContainerWidth?.constant =  badge.value != nil ? badge.bounds.size.width : 0.0
    }
    
    open override func layoutBadge(_ badge: TMBadgeView, in view: UIView) {
        super.layoutBadge(badge, in: view)
        
        badgeContainer.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor),
            badge.topAnchor.constraint(greaterThanOrEqualTo: badgeContainer.topAnchor),
            badgeContainer.bottomAnchor.constraint(greaterThanOrEqualTo: badge.bottomAnchor),
            badge.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor)
            ])
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        badge.layoutIfNeeded()
        updateBadgeConstraints()
    }
    
    open override func populate(for item: TMBarItemable) {
        super.populate(for: item)
        
        label.text = item.title
        calculateFontIntrinsicContentSize(for: item.title)
    
        updateBadgeConstraints()
    }
    
    open override func update(for selectionState: TMBarButton.SelectionState) {
        super.update(for: selectionState)
        
        let transitionColor = tintColor.interpolate(with: selectedTintColor,
                                                    percent: selectionState.rawValue)
        
        label.textColor = transitionColor
        
        // Because we can't animate nicely between fonts 😩
        // Cross dissolve on 'end' states between font properties.
        if let selectedFont = self.selectedFont {
            if selectionState == .selected && label.font != selectedFont {
                UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.label.font = self.selectedFont
                }, completion: nil)
            } else if selectionState != .selected && label.font == selectedFont {
                UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.label.font = self.font
                }, completion: nil)
            }
        }
    }
}

private extension TMLabelBarButton {
    
    /// Calculates an intrinsic content size based on font properties.
    ///
    /// Make the intrinsic size a calculated size based off a
    /// string value and font that requires the biggest size from `.font` and `.selectedFont`.
    ///
    /// - Parameter string: Value used for calculation.
    private func calculateFontIntrinsicContentSize(for string: String?) {
        guard let value = string else {
            return
        }
        let string = value as NSString
        let font = self.font
        let selectedFont = self.selectedFont ?? self.font
        
        let fontRect = string.boundingRect(with: .zero, options: .usesFontLeading, attributes: [.font: font], context: nil)
        let selectedFontRect = string.boundingRect(with: .zero, options: .usesFontLeading, attributes: [.font: selectedFont], context: nil)
        
        var largestWidth = max(selectedFontRect.size.width, fontRect.size.width)
        var largestHeight = max(selectedFontRect.size.height, fontRect.size.height)
        
        largestWidth += contentInset.left + contentInset.right
        largestHeight += contentInset.top + contentInset.bottom
        
        self.fontIntrinsicContentSize = CGSize(width: largestWidth, height: largestHeight)
        invalidateIntrinsicContentSize()
    }
}

private extension TMLabelBarButton {
    
    func makeTextLayer(for label: UILabel) -> CATextLayer {
        let layer = CATextLayer()
        layer.frame = label.convert(label.frame, to: self)
        layer.string = label.text
        layer.font = label.font
        layer.fontSize = label.font.pointSize
        return layer
    }
}
