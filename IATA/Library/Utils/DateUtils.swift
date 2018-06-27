import Foundation


class DateUtils {
    
    static let dateFormatter = DateFormatter()
    
    internal static func formatDate(date: String?) -> String? {
        if let date = date {
        dateFormatter.dateFormat = "yyyy-MM-DD"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd.MM.yyyy"
            return  dateFormatter.string(from: date!)
        } else {
            return date
        }
    }
    
    static internal func formatDateFromFormat(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy"
        
        if let date = dateFormatterGet.date(from: dateString){
             return dateFormatterPrint.string(from: date)
        }
        return dateString
    }
    
    static internal func formatDateFromFormatWith7Mls(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy"
        
        if let date = dateFormatterGet.date(from: dateString){
            return dateFormatterPrint.string(from: date)
        }
        return dateString
    }
}
