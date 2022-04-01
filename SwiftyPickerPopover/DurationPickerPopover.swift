//
//  DurationPickerPopover.swift
//  SwiftyPickerPopover
//
//  Created by Grégory ORIOL on 2022/03/29.
//  Copyright © 2022 Grégory ORIOL.
//
//
/*  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*/

/// DurationPickerPopover has 3 UIPickerView separated by labels.
public class DurationPickerPopover: AbstractPopover {

    // MARK: Types

    /// Type of choice value
    public typealias ItemType = String
    /// Popover type
    public typealias PopoverType = DurationPickerPopover
    /// Action type for buttons
    public typealias ActionHandlerType = (PopoverType, (h: Int, m: Int, s: Int), Int) -> Void
    /// Button parameters type
    public typealias ButtonParameterType = (title: String, font: UIFont?, color: UIColor?, action: ActionHandlerType?)
    /// Type of the rule closure to convert from a raw value to the display string
    public typealias DisplayStringForType = ((ItemType?)->String?)

    // MARK: Constants
    let kValueForCleared: ItemType = ""

    // MARK: - Properties

    /// Labels for h/m/s
    var labels = (h: "h", m: "m", s: "s")
    /// Value
    var value: Int = 0
    /// Shows a -/+ sign to make negative values
    var isNegativeAllowed: Bool = false

    ///Font
//    private(set) var fonts: [UIFont?]?
//    private(set) var fontSizes: [CGFloat?]?
//    let kDefaultFontSize: CGFloat = 12
//    private(set) var fontColors: [UIColor?]?
//    let kDefaultFontColor: UIColor = .black

    /// Convert a raw value to the string for displaying it
//    private(set) var displayStringFor: DisplayStringForType?

    /// Done button parameters
    private(set) var doneButton: ButtonParameterType = (title: "Done".localized, font: nil, color: nil, action: nil)
    /// Cancel button parameters
    private(set) var cancelButton: ButtonParameterType = (title: "Cancel".localized, font: nil, color: nil, action: nil)
    /// Clear button parameters
    private(set) var clearButton: ButtonParameterType = (title: "Clear".localized, font: nil, color: nil, action: nil)

    /// Action for picker value change
    private(set) var valueChangeAction: ActionHandlerType?

    // MARK: - Initializer

    /// Initialize a Popover with the following arguments.
    ///
    /// - Parameters:
    ///   - title: Title for navigation bar.
    ///   - choices: Options for picker.
    ///   - selectedRow: Selected rows of picker.
    ///   - columnPercent: Rate of each column of picker
    public init(title: String?, labels: (h: String, m: String, s: String) = (h: "h", m: "m", s: "s"), value: Int, isNegativeAllowed: Bool = false) {
        super.init()

        // Set parameters
        self.title = title
        self.labels = labels
        self.value = value
        self.isNegativeAllowed = isNegativeAllowed
    }

    // MARK: - Propery setter

//    /// Set displayStringFor closures
//    ///
//    /// - Parameter displayStringFor: Rules for converting choice values to display strings.
//    /// - Returns: Self
//    public func setDisplayStringFor(_ displayStringFor:DisplayStringForType?)->Self{
//        self.displayStringFor = displayStringFor
//        return self
//    }

    /// Set done button properties
    ///
    /// - Parameters:
    ///   - title: Title for the bar button item. Omissible.
    ///   - font: Button title font. Omissible.
    ///   - color: Button tint color. Omissible. If this is nil or not specified, then the button tintColor inherits appear()'s baseViewController.view.tintColor.
    ///   - action: Action to be performed before the popover disappeared.
    /// - Returns: Self
    public func setDoneButton(title: String? = nil, font: UIFont? = nil, color: UIColor? = nil, action: ActionHandlerType?) -> Self {
        return setButton(button: &doneButton, title: title, font: font, color: color, action: action)
    }

    /// Set cancel button properties.
    ///
    /// - Parameters:
    ///   - title: Title for the bar button item. Omissible.
    ///   - font: Button title font. Omissible.
    ///   - color: Button tint color. Omissible. If this is nil or not specified, then the button tintColor inherits appear()'s baseViewController.view.tintColor.
    ///   - action: Action to be performed before the popover disappeared.
    /// - Returns: Self
    public func setCancelButton(title: String? = nil, font: UIFont? = nil, color: UIColor? = nil, action: ActionHandlerType?) -> Self {
        return setButton(button: &cancelButton, title:title, font: font, color: color, action: action)
    }

    /// Set Clear button properties
    ///
    /// - Parameters:
    ///   - title: Title for the button. Omissible.
    ///   - font: Button title font. Omissible.
    ///   - color: Button tint color. Omissible. If this is nil or not specified, then the button tintColor inherits appear()'s baseViewController.view.tintColor.
    ///   - completion: Action to be performed before the popover disappeared.
    /// - Returns: Self
    public func setClearButton(title: String? = nil, font: UIFont? = nil, color: UIColor? = nil, action: ActionHandlerType?) -> Self{
        return setButton(button: &clearButton, title: title, font: font, color: color, action: action)
    }

    /// Set button arguments to the targeted button properties
    ///
    /// - Parameters:
    ///   - button: Target button properties
    ///   - title: Button title
    ///   - font: Button title font
    ///   - color: Button tintcolor
    ///   - action: Action to be performed before the popover disappeared.
    /// - Returns: Self
    func setButton(button: inout ButtonParameterType, title: String? = nil, font: UIFont? = nil, color: UIColor? = nil, action: ActionHandlerType?) -> Self {
        if let t = title{
            button.title = t
        }
        if let font = font {
            button.font = font
        }
        if let c = color{
            button.color = c
        }
        button.action = action
        return self
    }

    /// Set an action for each value change done by user
    ///
    /// - Parameters:
    ///   -action: Action to be performed each time the picker is moved to a new value.
    /// - Returns: Self
    public func setValueChange(action: ActionHandlerType?)->Self{
        valueChangeAction = action
        return self
    }

//    /// Set fonts
//    public func setFonts(_ fonts:[UIFont?]) ->Self {
//        self.fonts = fonts
//        return self
//    }
//
//    /// Set pickerFontColors
//    public func setFontColors(_ colors:[UIColor?]) ->Self {
//        self.fontColors = colors
//        return self
//    }
//
//    /// Set font sizes
//    public func setFontSizes(_ fontSizes:[CGFloat?])->Self{
//        self.fontSizes = fontSizes
//        return self
//    }
}
