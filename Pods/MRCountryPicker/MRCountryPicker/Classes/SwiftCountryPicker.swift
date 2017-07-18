import UIKit
import CoreTelephony

@objc public protocol MRCountryPickerDelegate {
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage)
}

struct Country {
    var code: String?
    var name: String?
    var phoneCode: String?
    var flag: UIImage? {
        guard let code = self.code else { return nil }
        return UIImage(named: "SwiftCountryPicker.bundle/Images/\(code.uppercased())", in: Bundle(for: MRCountryPicker.self), compatibleWith: nil)
    }

    init(code: String?, name: String?, phoneCode: String?) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
    }
}

open class MRCountryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var countries: [Country]!
    open weak var countryPickerDelegate: MRCountryPickerDelegate?
    open var showPhoneNumbers: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        countries = countryNamesByCode()

        super.dataSource = self
        super.delegate = self
    }
    
    // MARK: - Country Methods
    
    open func setCountry(_ code: String) {
        var row = 0
        for index in 0..<countries.count {
            if countries[index].code == code {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
        let country = countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!, flag: country.flag!)
        }
    }
    open func setCountryByName(_ name: String) {
        var row = 0
        for index in 0..<countries.count {
            if countries[index].name == name {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
        let country = countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!, flag: country.flag!)
        }
    }
    open func setCountryByPhoneCode(_ phoneCode: String) {
        var row = 0
        for index in 0..<countries.count {
            if countries[index].phoneCode == phoneCode {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
        let country = countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!, flag: country.flag!)
        }
    }
    
    // Populates the metadata from the included json file resource
    
    func countryNamesByCode() -> [Country] {
        var countries = [Country]()
        let frameworkBundle = Bundle(for: type(of: self))
        guard let jsonPath = frameworkBundle.path(forResource: "SwiftCountryPicker.bundle/Data/countryCodes", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            return countries
        }
        
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {

                    for jsonObject in jsonObjects {
                        
                        guard let countryObj = jsonObject as? NSDictionary else {
                            return countries
                        }
                        
                        guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String else {
                            return countries
                        }

                        let country = Country(code: code, name: name, phoneCode: phoneCode)
                        countries.append(country)
                    }

                }
        } catch {
            return countries
        }
        return countries
    }
    
    // MARK: - Picker Methods
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var resultView: SwiftCountryView
        
        if view == nil {
            resultView = SwiftCountryView()
        } else {
            resultView = view as! SwiftCountryView
        }
        
        resultView.setup(countries[row])
        if !showPhoneNumbers {
            resultView.countryCodeLabel.isHidden = true
        }
        return resultView
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!, flag: country.flag!)
        }
    }
}
