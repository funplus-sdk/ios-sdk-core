//
//  JSONSchema.swift
//  FunPlusSDK
//
//  Created by Yuankun Zhang on 22/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

enum Type: Swift.String {
    case Object = "object"
    case Array = "array"
    case String = "string"
    case Integer = "integer"
    case Number = "number"
    case Boolean = "boolean"
    case Null = "null"
}

struct Schema {
    let title:String?
    let description:String?
    
    fileprivate let type:[Type]?
    
    /// validation formats, currently private. If anyone wants to add custom please make a PR to make this public ;)
    fileprivate let formats:[String: Validator]
    
    fileprivate let schema:[String: Any]
    
    init(_ schema:[String: Any]) {
        title = schema["title"] as? String
        description = schema["description"] as? String
        
        if let type = schema["type"] as? String {
            if let type = Type(rawValue: type) {
                self.type = [type]
            } else {
                self.type = []
            }
        } else if let types = schema["type"] as? [String] {
            self.type = types.map { Type(rawValue: $0) }.filter { $0 != nil }.map { $0! }
        } else {
            self.type = []
        }
        
        self.schema = schema
        
        formats = [
            "ipv4": validateIPv4,
        ]
    }
    
    func validate(data: Any) -> ValidationResult {
        let validator = allOf(validators: createValiadators(root: self)(schema))
        let result = validator(data)
        return result
    }
}

/// Returns a set of validators for a schema and document
func createValiadators(root: Schema) -> (_ schema: [String: Any]) -> [Validator] {
    return { schema in
        var validators = [Validator]()
        
        if let type: Any = schema["type"] {
            // Rewrite this and most of the validator to use the `type` property, see https://github.com/kylef/JSONSchema.swift/issues/12
            validators.append(validateType(type: type))
        }
        
        if let allOf = schema["allOf"] as? [[String: Any]] {
            validators += allOf.map(createValiadators(root: root)).reduce([], +)
        }
        
        if let anyOfSchemas = schema["anyOf"] as? [[String: Any]] {
            let anyOfValidators = anyOfSchemas.map(createValiadators(root: root)).map(allOf) as [Validator]
            validators.append(anyOf(validators: anyOfValidators))
        }
        
        if let oneOfSchemas = schema["oneOf"] as? [[String: Any]] {
            let oneOfValidators = oneOfSchemas.map(createValiadators(root: root)).map(allOf) as [Validator]
            validators.append(oneOf(validators: oneOfValidators))
        }
        
        if let notSchema = schema["not"] as? [String: Any] {
            let notValidator = allOf(validators: createValiadators(root: root)(notSchema))
            validators.append(not(validator: notValidator))
        }
        
        if let enumValues = schema["enum"] as? [Any] {
            validators.append(validateEnum(values: enumValues))
        }
        
        // String
        
        if let maxLength = schema["maxLength"] as? Int {
            validators.append(validateLength(comparitor: <=, length: maxLength, error: "Length of string is larger than max length \(maxLength)"))
        }
        
        if let minLength = schema["minLength"] as? Int {
            validators.append(validateLength(comparitor: >=, length: minLength, error: "Length of string is smaller than minimum length \(minLength)"))
        }
        
        if let pattern = schema["pattern"] as? String {
            validators.append(validatePattern(pattern: pattern))
        }
        
        // Numerical
        
        if let multipleOf = schema["multipleOf"] as? Double {
            validators.append(validateMultipleOf(number: multipleOf))
        }
        
        if let minimum = schema["minimum"] as? Double {
            validators.append(validateNumericLength(length: minimum, comparitor: >=, exclusiveComparitor: >, exclusive: schema["exclusiveMinimum"] as? Bool, error: "Value is lower than minimum value of \(minimum)"))
        }
        
        if let maximum = schema["maximum"] as? Double {
            validators.append(validateNumericLength(length: maximum, comparitor: <=, exclusiveComparitor: <, exclusive: schema["exclusiveMaximum"] as? Bool, error: "Value exceeds maximum value of \(maximum)"))
        }
        
        // Array
        
        if let minItems = schema["minItems"] as? Int {
            validators.append(validateArrayLength(rhs: minItems, comparitor: >=, error: "Length of array is smaller than the minimum \(minItems)"))
        }
        
        if let maxItems = schema["maxItems"] as? Int {
            validators.append(validateArrayLength(rhs: maxItems, comparitor: <=, error: "Length of array is greater than maximum \(maxItems)"))
        }
        
        if let uniqueItems = schema["uniqueItems"] as? Bool {
            if uniqueItems {
                validators.append(validateUniqueItems)
            }
        }
        
        if let items = schema["items"] as? [String: Any] {
            let itemsValidators = allOf(validators: createValiadators(root: root)(items))
            
            func validateItems(document: Any) -> ValidationResult {
                if let document = document as? [Any] {
                    return flatten(results: document.map(itemsValidators))
                }
                
                return .Valid
            }
            
            validators.append(validateItems)
        } else if let items = schema["items"] as? [[String: Any]] {
            func createAdditionalItemsValidator(additionalItems: Any?) -> Validator {
                if let additionalItems = additionalItems as? [String: Any] {
                    return allOf(validators: createValiadators(root: root)(additionalItems))
                }
                
                let additionalItems = additionalItems as? Bool ?? true
                if additionalItems {
                    return validValidation
                }
                
                return invalidValidation(error: "Additional results are not permitted in this array.")
            }
            
            let additionalItemsValidator = createAdditionalItemsValidator(additionalItems: schema["additionalItems"])
            let itemValidators = items.map(createValiadators(root: root))
            
            func validateItems(value: Any) -> ValidationResult {
                if let value = value as? [Any] {
                    var results = [ValidationResult]()
                    
                    for (index, element) in value.enumerated() {
                        if index >= itemValidators.count {
                            results.append(additionalItemsValidator(element))
                        } else {
                            let validators = allOf(validators: itemValidators[index])
                            results.append(validators(element))
                        }
                    }
                    
                    return flatten(results: results)
                }
                
                return .Valid
            }
            
            validators.append(validateItems)
        }
        
        if let maxProperties = schema["maxProperties"] as? Int {
            validators.append(validatePropertiesLength(length: maxProperties, comparitor: >=, error: "Amount of properties is greater than maximum permitted"))
        }
        
        if let minProperties = schema["minProperties"] as? Int {
            validators.append(validatePropertiesLength(length: minProperties, comparitor: <=, error: "Amount of properties is less than the required amount"))
        }
        
        if let required = schema["required"] as? [String] {
            validators.append(validateRequired(required: required))
        }
        
        if (schema["properties"] != nil) || (schema["patternProperties"] != nil) || (schema["additionalProperties"] != nil) {
            func createAdditionalPropertiesValidator(additionalProperties: Any?) -> Validator {
                if let additionalProperties = additionalProperties as? [String: Any] {
                    return allOf(validators: createValiadators(root: root)(additionalProperties))
                }
                
                let additionalProperties = additionalProperties as? Bool ?? true
                if additionalProperties {
                    return validValidation
                }
                
                return invalidValidation(error: "Additional properties are not permitted in this object.")
            }
            
            func createPropertiesValidators(properties:[String:[String: Any]]?) -> [String:Validator]? {
                if let properties = properties {
                    return Dictionary(properties.keys.map {
                        key in (key, allOf(validators: createValiadators(root: root)(properties[key]!)))
                    })
                }
                
                return nil
            }
            
            let additionalPropertyValidator = createAdditionalPropertiesValidator(additionalProperties: schema["additionalProperties"])
            let properties = createPropertiesValidators(properties: schema["properties"] as? [String: [String: Any]])
            let patternProperties = createPropertiesValidators(properties: schema["patternProperties"] as? [String: [String: Any]])
            validators.append(validateProperties(properties: properties, patternProperties: patternProperties, additionalProperties: additionalPropertyValidator))
        }
        
        func validateDependency(key: String, validator: @escaping Validator) -> (_ value: Any) -> ValidationResult {
            return { value in
                if let value = value as? [String: Any] {
                    if (value[key] != nil) {
                        return validator(value as Any)
                    }
                }
                
                return .Valid
            }
        }
        
        func validateDependencies(key: String, dependencies: [String]) -> (_ value: Any) -> ValidationResult {
            return { value in
                if let value = value as? [String: Any] {
                    if (value[key] != nil) {
                        return flatten(results: dependencies.map { dependency in
                            if value[dependency] == nil {
                                return .Invalid(["'\(key)' is missing it's dependency of '\(dependency)'"])
                            }
                            return .Valid
                        })
                    }
                }
                
                return .Valid
            }
        }
        
        if let dependencies = schema["dependencies"] as? [String: Any] {
            for (key, dependencies) in dependencies {
                if let dependencies = dependencies as? [String: Any] {
                    let schema = allOf(validators: createValiadators(root: root)(dependencies))
                    validators.append(validateDependency(key: key, validator: schema))
                } else if let dependencies = dependencies as? [String] {
                    validators.append(validateDependencies(key: key, dependencies: dependencies))
                }
            }
        }
        
        if let format = schema["format"] as? String {
            if let validator = root.formats[format] {
                validators.append(validator)
            } else {
                validators.append(invalidValidation(error: "'format' validation of '\(format)' is not yet supported."))
            }
        }
        
        return validators
    }
}

func validate(value: Any, schema: [String: Any]) -> ValidationResult {
    let root = Schema(schema)
    let validator = allOf(validators: createValiadators(root: root)(schema))
    let result = validator(value)
    return result
}

/// Extension for dictionary providing initialization from array of elements
extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        
        for (key, value) in pairs {
            self[key] = value
        }
    }
}
