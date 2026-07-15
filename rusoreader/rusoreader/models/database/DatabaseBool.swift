import GRDB

/// Boolean data in the database may appear empty, or odd forms, this will convert that for to an actual Swift Bool
struct DatabaseBool : DatabaseValueConvertible, Codable {
    let value: Bool

    var databaseValue: DatabaseValue {
        value.databaseValue
    }
    
    static func fromDatabaseValue(_ dbValue: GRDB.DatabaseValue) -> DatabaseBool? {
        if dbValue.isNull {
            return DatabaseBool(value: false)
        }
        
        // Try to get as Bool first (most common case)
        if let boolValue = Bool.fromDatabaseValue(dbValue) {
            return DatabaseBool(value: boolValue)
        }
        
        // Try as integer
        if let intValue = Int64.fromDatabaseValue(dbValue) {
            return DatabaseBool(value: intValue == 1)
        }
        
        // Try as double
        if let doubleValue = Double.fromDatabaseValue(dbValue) {
            return DatabaseBool(value: doubleValue == 1.0)
        }
        
        // Try as string
        if let stringValue = String.fromDatabaseValue(dbValue) {
            let lower = stringValue.lowercased()
            return DatabaseBool(value: lower == "1" || lower == "true")
        }
        
        // Default to false for any other type
        return DatabaseBool(value: false)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Bool.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    // Convenience so you can still write `LenientBool(value: true)` directly
    init(value: Bool) {
        self.value = value
    }
}
