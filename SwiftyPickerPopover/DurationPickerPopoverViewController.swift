//
//  DurationPickerPopoverViewController.swift
//  SwiftyPickerPopover
//
//  Created by Ken Torimaru on 2016/09/29.
//  Copyright © 2016 Ken Torimaru.
//
//
/*  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 */

public class DurationPickerPopoverViewController: AbstractPickerPopoverViewController {

    // MARK: Types

    /// Popover type
    typealias PopoverType = DurationPickerPopover

    // MARK: Properties

    /// Popover
    private var popover: PopoverType! { return anyPopover as? PopoverType }

    @IBOutlet weak private var cancelButton: UIBarButtonItem!
    @IBOutlet weak private var doneButton: UIBarButtonItem!
    @IBOutlet weak private var clearButton: UIButton!

    @IBOutlet fileprivate weak var signSegmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var signSegmentedControlContainerView: UIView!
    @IBOutlet fileprivate weak var hoursPickerView: UIPickerView!
    @IBOutlet fileprivate weak var hoursLabel: UILabel!
    @IBOutlet fileprivate weak var minutesPickerView: UIPickerView!
    @IBOutlet fileprivate weak var minutesLabel: UILabel!
    @IBOutlet fileprivate weak var secondsPickerView: UIPickerView!
    @IBOutlet fileprivate weak var secondsLabel: UILabel!

    override public func viewDidLoad() {
        super.viewDidLoad()

        hoursPickerView.delegate = self
        hoursPickerView.dataSource = self
        minutesPickerView.delegate = self
        minutesPickerView.dataSource = self
        secondsPickerView.delegate = self
        secondsPickerView.dataSource = self
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

        hoursLabel.text = popover.labels.h
        minutesLabel.text = popover.labels.m
        secondsLabel.text = popover.labels.s

        // Considering that "+" is the most useful sign
        if popover.value < 0 {
            signSegmentedControl.selectedSegmentIndex = 0
        } else {
            signSegmentedControl.selectedSegmentIndex = 1
        }

        hoursPickerView.reloadAllComponents()
        minutesPickerView.reloadAllComponents()
        secondsPickerView.reloadAllComponents()

        let components = valueToComponents(popover.value)
        hoursPickerView.selectRow(components.h, inComponent: 0, animated: false)
        minutesPickerView.selectRow(components.m, inComponent: 0, animated: false)
        secondsPickerView.selectRow(components.s, inComponent: 0, animated: false)
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

    private func tapped(button: DurationPickerPopover.ButtonParameterType?) {
        let h = hoursPickerView.selectedRow(inComponent: 0)
        let m = minutesPickerView.selectedRow(inComponent: 0)
        let s = secondsPickerView.selectedRow(inComponent: 0)
        let value = valueFromComponents((h: h, m: m, s: s)) * ((signSegmentedControl.selectedSegmentIndex == 0) ? -1 : 1)

        button?.action?(popover, (h: h, m: m, s: s), value)
        popover.removeDimmedView()
        dismiss(animated: false)
    }

    /// Action to be executed after the popover disappears
    ///
    /// - Parameter popoverPresentationController: UIPopoverPresentationController
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        tappedCancel()
    }

    @IBAction func signSegmentedControlValueChanged(sender: UISegmentedControl) {
        let h = hoursPickerView.selectedRow(inComponent: 0)
        let m = minutesPickerView.selectedRow(inComponent: 0)
        let s = secondsPickerView.selectedRow(inComponent: 0)
        let value = valueFromComponents((h: h, m: m, s: s)) * ((signSegmentedControl.selectedSegmentIndex == 0) ? -1 : 1)

        popover.value = value
        popover.valueChangeAction?(popover, (h: h, m: m, s: s), value)
        popover.redoDisappearAutomatically()
    }

    // MARK: - Helpers

    fileprivate func valueToComponents(_ value: Int) -> (h: Int, m: Int, s: Int) {
        let value = abs(value)
        return (h: value / 3600, m: (value % 3600) / 60, s: (value % 3600) % 60)
    }

    fileprivate func valueFromComponents(_ components: (h: Int, m: Int, s: Int)) -> Int {
        return components.s + components.m * 60 + components.h * 60 * 60
    }
}

// MARK: - UIPickerViewDataSource
extension DurationPickerPopoverViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == hoursPickerView {
            return 12
        } else if pickerView == minutesPickerView {
            return 60
        } else if pickerView == secondsPickerView {
            return 60
        }

        return 0
    }

//    public func pickerView(_ pickerView: UIPickerView,
//                           widthForComponent component: Int) -> CGFloat {
//        return pickerView.frame.size.width * CGFloat(popover.columnPercents[component])
//    }

//    private func selectedValue(component: Int, row: Int) -> DurationPickerPopover.ItemType? {
//        guard let items = popover.choices[safe: component],
//            let selectedValue = items[safe: row] else {
//                return nil
//        }
//        return popover.displayStringFor?(selectedValue) ?? selectedValue
//    }

//    private func selectedValues() -> [DurationPickerPopover.ItemType] {
//        var result = [DurationPickerPopover.ItemType]()
//        popover.selectedRows.enumerated().forEach {
//            if let value = selectedValue(component: $0.offset, row: $0.element){
//                result.append(value)
//            }
//        }
//        return result
//    }
}

extension DurationPickerPopoverViewController: UIPickerViewDelegate {

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let value: String = "\(row)"
        let adjustedValue: String = "\(row)"
        let label: UILabel = view as? UILabel ?? UILabel()
        label.text = adjustedValue
//        label.attributedText = getAttributedText(adjustedValue, component: component)
        label.textAlignment = .right
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
        let h = hoursPickerView.selectedRow(inComponent: 0)
        let m = minutesPickerView.selectedRow(inComponent: 0)
        let s = secondsPickerView.selectedRow(inComponent: 0)
        let value = valueFromComponents((h: h, m: m, s: s)) * ((signSegmentedControl.selectedSegmentIndex == 0) ? -1 : 1)

        popover.value = value
        popover.valueChangeAction?(popover, (h: h, m: m, s: s), value)
        popover.redoDisappearAutomatically()
    }
}