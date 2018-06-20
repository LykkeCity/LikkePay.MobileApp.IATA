import Foundation
import Material
import UIKit

class FloatTextField: TextField {
    @IBInspectable
    open override var font: UIFont? {
        didSet {
            if (isEmpty) {
                placeholderLabel.font = Theme.shared.regularFontOfSize(16)
            } else {
                placeholderLabel.font = Theme.shared.mediumFontOfSize(16)
            }
        }
    }
    
    /// Controls the visibility of detailLabel
    @IBInspectable
    open var isErrorRevealed = false {
        didSet {
            detailLabel.isHidden = !isErrorRevealed
            if (isErrorRevealed) {
                dividerColor = Theme.shared.redErrorStatusColor
                placeholderNormalColor = Theme.shared.redErrorStatusColor
                dividerActiveColor = Theme.shared.redErrorStatusColor
                placeholderActiveColor = Theme.shared.redErrorStatusColor
            } else{
                dividerActiveColor = Theme.shared.greenColor
                placeholderActiveColor = Theme.shared.greenColor
                dividerColor = Theme.shared.greyStatusColor
                placeholderNormalColor = Theme.shared.greyStatusColor
            }
            layoutSubviews()
        }
    }
    
    open override func prepare() {
        super.prepare()
        prepareTextHandlers()
        detailColor = Theme.shared.redErrorStatusColor
    }
}


extension TextField {
    func prepareTextHandlers() {
        addTarget(self, action: #selector(handleEditingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
        addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)
    }
}

extension TextField {
    /// Updates the placeholderLabel text color.
    func updatePlaceholderLabelColor() {
        tintColor = placeholderActiveColor
        placeholderLabel.textColor = isEditing ? placeholderActiveColor : placeholderNormalColor
    }
    
    /// Update the placeholder text to the active state.
    func updatePlaceholderTextToActiveState() {
        if isEditing {
            placeholderLabel.font = Theme.shared.regularFontOfSize(14)
        }
    }
    /// Update the placeholder text to the normal state.
    func updatePlaceholderTextToNormalState() {
        guard isPlaceholderUppercasedWhenEditing else {
            return
        }
        
        guard isEmpty else {
            return
        }
        
        placeholderLabel.text = placeholderLabel.text?.capitalized
    }
}


extension TextField {
    /// Handles the text editing did begin state.
    @objc
    func handleEditingDidBegin() {
        placeholderEditingDidBeginAnimation()
    }
    
    // Live updates the textField text.
    @objc
    func handleEditingChanged(textField: UITextField) {
        (delegate as? TextFieldDelegate)?.textField?(textField: self, didChange: textField.text)
    }
    
    /// Handles the text editing did end state.
    @objc
    func handleEditingDidEnd() {
        placeholderEditingDidEndAnimation()
    }
    
}

extension TextField {
    /// The animation for the placeholder when editing begins.
    fileprivate func placeholderEditingDidBeginAnimation() {
        guard .default == placeholderAnimation else {
            placeholderLabel.isHidden = true
            return
        }
        
        updatePlaceholderLabelColor()
        
        guard isPlaceholderAnimated else {
            updatePlaceholderTextToActiveState()
            return
        }
        
        guard isEmpty else {
            updatePlaceholderTextToActiveState()
            return
        }
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.placeholderLabel.transform = CGAffineTransform(scaleX: self.placeholderActiveScale, y: self.placeholderActiveScale)
            
            self.updatePlaceholderTextToActiveState()
            
            switch self.textAlignment {
            case .left, .natural:
                self.placeholderLabel.frame.origin.x = self.leftViewWidth + self.textInset + self.placeholderHorizontalOffset
            case .right:
                self.placeholderLabel.frame.origin.x = (self.bounds.width * (1.0 - self.placeholderActiveScale)) - self.textInset + self.placeholderHorizontalOffset
            default:break
            }
            
            self.placeholderLabel.frame.origin.y = -self.placeholderLabel.bounds.height + self.placeholderVerticalOffset
        })
    }
    
    /// The animation for the placeholder when editing ends.
    fileprivate func placeholderEditingDidEndAnimation() {
        guard .default == placeholderAnimation else {
            placeholderLabel.isHidden = !isEmpty
            return
        }
        
        updatePlaceholderLabelColor()
        updatePlaceholderTextToNormalState()
        
        guard isPlaceholderAnimated else {
            return
        }
        
        guard isEmpty else {
            return
        }
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.placeholderLabel.transform = CGAffineTransform.identity
            self.placeholderLabel.frame.origin.x = self.leftViewWidth + self.textInset
            self.placeholderLabel.frame.origin.y = 0
        })
        
        if (isEmpty) {
            placeholderLabel.font = Theme.shared.regularFontOfSize(16)
            placeholderLabel.textColor = Theme.shared.placeholderTextFieldColor
        } else {
            placeholderLabel.font = Theme.shared.mediumFontOfSize(16)
            placeholderLabel.textColor = Theme.shared.textFieldColor
        }
    }
}
