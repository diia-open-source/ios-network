import Foundation

func localizedStringFor(_ key: String, comment: String) -> String {
    
    let name = "CoreLayer"
    let bundle = Bundle.main
    
    return NSLocalizedString(key, tableName: name, bundle: bundle, comment: comment)
}
