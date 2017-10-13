//
//  ViewController.swift
//  Calculator
//
//  Created by Jason Schisler on 7/17/17.
//  Copyright © 2017 Jason Schisler. All rights reserved.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext();
        color.setFill()
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(image, for: state);
    }
}

extension String {
    func replace(pattern: String, with replacement: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSMakeRange(0, self.characters.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
}

extension String {
    static let DecimalDigits = 12
    
    func beautifyNumbers() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = String.DecimalDigits
        
        var text = self as NSString
        var numbers = [String]()
        let regex = try! NSRegularExpression(pattern: "[.0-9]+", options: .caseInsensitive)
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, text.length))
        numbers = matches.map { text.substring(with: $0.range) }
        
        for number in numbers {
            text = text.replacingOccurrences(
                of: number,
                with: formatter.string(from: NSNumber(value: Double(number)!))!
                ) as NSString
        }
        return text as String;
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    @IBOutlet weak var decimalSeparatorButton: UIButton!
    
    private let decimalSeparator = NumberFormatter().decimalSeparator!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func reset(_ sender: UIButton) {
        brain = CalculatorBrain()
        displayValue = 0
        descriptionDisplay.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping, var text = display.text {
            text.remove(at: text.index(before: text.endIndex))
            if text.isEmpty || text == "0" {
                text = "0"
                userIsInTheMiddleOfTyping = false
            }
            display.text = text
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            // If the text in the display contains a decimal or if the digit pressed is not a period
            // Then add the digit to the text in the display
            if !textCurrentlyInDisplay.contains(decimalSeparator) || digit != decimalSeparator {
                display.text = textCurrentlyInDisplay + digit
            }
        }else {
            switch digit {
            case decimalSeparator:
                display.text = "0."
            case "0":
                if "0" == display.text {
                    return
                }
                fallthrough
            default:
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            //return Double(display.text!)!
            return (NumberFormatter().number(from: display.text!)?.doubleValue)!
        }
        set {
            display.text = String(newValue).beautifyNumbers()
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let description = brain.description {
            descriptionDisplay.text = description.beautifyNumbers() + (brain.resultIsPending ? "…" : "=")
        } else {
            descriptionDisplay.text = " "
        }
        
        if let result = brain.result {
            displayValue = result
        }
    }
    
    // function to adjust the button layout
    // a tag of 1 means hidden in portrait mode
    // a tag of 2 means hidden in landscape mode
    // a default tag of 0 means not hidden
    private func adjustButtonLayout(for view: UIView, isPortrait: Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.isHidden = isPortrait
            } else if subview.tag == 2 {
                subview.isHidden = !isPortrait
            }
            if let button = subview as? UIButton {
                button.setBackgroundColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forState: .highlighted)
                button.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .highlighted)
            }
            else if let stack = subview as? UIStackView {
                adjustButtonLayout(for: stack, isPortrait: isPortrait);
            }
        }
    }
    
    // adjusts the button layout when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustButtonLayout(for: view, isPortrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular)
        
        decimalSeparatorButton.setTitle(decimalSeparator, for: .normal);
    }
    
    // adjusts the button layout when the view transitions between portrait and landscape
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        adjustButtonLayout(for: view, isPortrait: newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .regular)
    }
    
}


