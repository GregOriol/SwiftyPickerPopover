//
//  PointsPickerPopoverViewController.swift
//  SwiftyPickerPopover
//
//  Created by Ken Torimaru on 2016/09/29.
//  Copyright © 2016 Ken Torimaru.
//
//
/*  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 */

public class PointsPickerPopoverViewController: AbstractPickerPopoverViewController {

    // MARK: Types

    /// Popover type
    typealias PopoverType = PointsPickerPopover

    // MARK: Properties

    /// Popover
    private var popover: PopoverType! { return anyPopover as? PopoverType }

    @IBOutlet weak private var cancelButton: UIBarButtonItem!
    @IBOutlet weak private var doneButton: UIBarButtonItem!
    @IBOutlet weak private var clearButton: UIButton!

    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var signSegmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var signSegmentedControlContainerView: UIView!
    @IBOutlet fileprivate weak var pickerView: UIPickerView!
    @IBOutlet fileprivate weak var textField: UITextField!
    @IBOutlet fileprivate weak var decrementButton: UIButton!
    @IBOutlet fileprivate weak var incrementButton: UIButton!

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        textField.delegate = self
    }

    /// Make the popover properties reflect on this view controller
    override func reflectPopoverProperties(){
        super.reflectPopoverProperties()

        // Set up cancel button
        if #available(iOS 11.0, *) {}
        else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        }

        cancelButton.title = popover.cancelButton.title
        cancelButton.tintColor = popover.cancelButton.color ?? popover.tintColor
        navigationItem.setLeftBarButton(cancelButton, animated: false)

        doneButton.title = popover.doneButton.title
        doneButton.tintColor = popover.doneButton.color ?? popover.tintColor
        navigationItem.setRightBarButton(doneButton, animated: false)

        clearButton.setTitle(popover.clearButton.title, for: .normal)
        if let font = popover.clearButton.font {
            clearButton.titleLabel?.font = font
        }
        clearButton.tintColor = popover.clearButton.color ?? popover.tintColor
        clearButton.isHidden = popover.clearButton.action == nil

        // Selecting approriate tab
        let absValue = abs(popover.value)
        if absValue <= 99 {
            segmentedControl.selectedSegmentIndex = 0
        } else if absValue >= 10 && absValue <= 990 && absValue % 10 == 0 {
            segmentedControl.selectedSegmentIndex = 1
        } else if absValue >= 100 && absValue <= 9900 && absValue % 100 == 0 {
            segmentedControl.selectedSegmentIndex = 2
        } else if absValue >= 1000 && absValue <= 99000 && absValue % 1000 == 0 {
            segmentedControl.selectedSegmentIndex = 3
        } else {
            segmentedControl.selectedSegmentIndex = 4
        }

        // Considering that "+" is the most useful sign
        if popover.value == 0 {
            signSegmentedControl.selectedSegmentIndex = 1
        }

        updateDisplay()
    }

    // MARK: - Actions

    /// Action when tapping done button
    ///
    /// - Parameter sender: Done button
    @IBAction func tappedDone(_ sender: AnyObject? = nil) {
        tapped(button: popover.doneButton)
    }

    /// Action when tapping cancel button
    ///
    /// - Parameter sender: Cancel button
    @IBAction func tappedCancel(_ sender: AnyObject? = nil) {
        tapped(button: popover.cancelButton)
    }

    /// Action when tapping clear button
    ///
    /// - Parameter sender: Clear button
    @IBAction func tappedClear(_ sender: UIButton? = nil) {
        tapped(button: popover.clearButton)
    }

    private func tapped(button: PointsPickerPopover.ButtonParameterType?) {
        let value = valueFromRow(pickerView.selectedRow(inComponent: 0)) * ((signSegmentedControl.selectedSegmentIndex == 0) ? -1 : 1)

        button?.action?(popover, value)
        popover.removeDimmedView()
        dismiss(animated: false)
    }

    /// Action to be executed after the popover disappears
    ///
    /// - Parameter popoverPresentationController: UIPopoverPresentationController
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        tappedCancel()
    }

    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        updateDisplay()
    }

    @IBAction func signSegmentedControlValueChanged(sender: UISegmentedControl) {
        let newValue = valueFromRow(pickerView.selectedRow(inComponent: 0)) * ((signSegmentedControl.selectedSegmentIndex == 0) ? -1 : 1)

        popover.value = newValue
        popover.valueChangeAction?(popover, newValue)
        popover.redoDisappearAutomatically()
        updateDisplay()
    }

    @IBAction func decrementButtonPressed(sender: UIButton) {
        var newValue = 0

        if let text = textField.text, let value = Int(text) {
            newValue = value - 1
        }

        popover.value = newValue
        popover.valueChangeAction?(popover, newValue)
        popover.redoDisappearAutomatically()
        updateDisplay()
    }

    @IBAction func incrementButtonPressed(sender: UIButton) {
        var newValue = 0

        if let text = textField.text, let value = Int(text) {
            newValue = value + 1
        }

        popover.value = newValue
        popover.valueChangeAction?(popover, newValue)
        popover.redoDisappearAutomatically()
        updateDisplay()
    }

    // MARK: - Helpers

    fileprivate func updateDisplay() {
        if segmentedControl.selectedSegmentIndex == 4 {
            pickerView.isHidden = true
            textField.isHidden = false
            decrementButton.isHidden = false
            incrementButton.isHidden = false
            signSegmentedControlContainerView.isHidden = true
        } else {
            pickerView.isHidden = false
            textField.isHidden = true
            decrementButton.isHidden = true
            incrementButton.isHidden = true
            signSegmentedControlContainerView.isHidden = false
        }

        if popover.value < 0 {
            signSegmentedControl.selectedSegmentIndex = 0
        } else if popover.value > 0 {
            signSegmentedControl.selectedSegmentIndex = 1
        }// else == 0, leaving sign as it is

        pickerView.reloadAllComponents()

        let absValue = abs(popover.value)
        if segmentedControl.selectedSegmentIndex == 0 && absValue <= 99 {
            pickerView.selectRow(absValue, inComponent: 0, animated: false)
        } else if segmentedControl.selectedSegmentIndex == 1 && absValue >= 10 && absValue <= 990 && absValue % 10 == 0 {
            pickerView.selectRow(Int(absValue / 10), inComponent: 0, animated: false)
        } else if segmentedControl.selectedSegmentIndex == 2 && absValue >= 100 && absValue <= 9900 && absValue % 100 == 0 {
            pickerView.selectRow(Int(absValue / 100), inComponent: 0, animated: false)
        } else if segmentedControl.selectedSegmentIndex == 3 && absValue >= 1000 && absValue <= 99000 && absValue % 1000 == 0 {
            pickerView.selectRow(Int(absValue / 1000), inComponent: 0, animated: false)
        } else {
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }

        textField.text = "\(popover.value)"
    }

    fileprivate func valueFromRow(_ row: Int) -> Int {
        var value = row
        if segmentedControl.selectedSegmentIndex == 1 {
            value = row * 10
        } else if segmentedControl.selectedSegmentIndex == 2 {
            value = row * 100
        } else if segmentedControl.selectedSegmentIndex == 3 {
            value = row * 1000
        }

        return value
    }

//    fileprivate func valueToComponents(_ value: Int) -> (h: Int, m: Int, s: Int) {
//        return (h: value / 3600, m: (value % 3600) / 60, s: (value % 3600) % 60)
//    }
//
//    fileprivate func valueFromComponents(_ components: (h: Int, m: Int, s: Int)) -> Int {
//        return components.s + components.m * 60 + components.h * 60 * 60
//    }
}

// MARK: - UIPickerViewDataSource
extension PointsPickerPopoverViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }

//    public func pickerView(_ pickerView: UIPickerView,
//                           widthForComponent component: Int) -> CGFloat {
//        return pickerView.frame.size.width * CGFloat(popover.columnPercents[component])
//    }
}

extension PointsPickerPopoverViewController: UIPickerViewDelegate {

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let value = valueFromRow(row)

        let adjustedValue: String = "\(value)"
        let label: UILabel = view as? UILabel ?? UILabel()
        label.text = adjustedValue
//        label.attributedText = getAttributedText(adjustedValue, component: component)
        label.textAlignment = .center
        return label
    }

//    private func getAttributedText(_ text: String?, component: Int) -> NSAttributedString? {
//        guard let text = text else {
//            return nil
//        }
//        let font: UIFont = {
//            if let f = popover.fonts?[component] {
//                if let size = popover.fontSizes?[component] {
//                    return UIFont(name: f.fontName, size: size)!
//                }
//                return UIFont(name: f.fontName, size: f.pointSize)!
//            }
//            let size = popover.fontSizes?[component] ?? popover.kDefaultFontSize
//            return UIFont.systemFont(ofSize: size)
//        }()
//        let color: UIColor = popover.fontColors?[component] ?? popover.kDefaultFontColor
//        return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
//    }

    public func pickerView(_ pickerView: UIPickerView,
                           didSelectRow row: Int,
                           inComponent component: Int){
        let value = valueFromRow(row) * ((signSegmentedControl.selectedSegmentIndex == 0) ? -1 : 1)

        popover.value = value
        popover.valueChangeAction?(popover, value)
        popover.redoDisappearAutomatically()
        updateDisplay()
    }
}

// MARK: - UITextFieldDelegate

extension PointsPickerPopoverViewController: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {

    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        var newValue = 0

        if let text = textField.text, let value = Int(text) {
            newValue = value
        }

        popover.value = newValue
        popover.valueChangeAction?(popover, newValue)
        popover.redoDisappearAutomatically()
        updateDisplay()
    }
}
