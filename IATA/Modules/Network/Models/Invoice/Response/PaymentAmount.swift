import ObjectMapper

class PaymentAmount: Mappable {
    
    private enum PropertyKey: String {
        case amountToPay    }
    
    internal var amountToPay: String?
    
    internal required init?() {
    }
    
    required init?(map: Map) {
        
    }
    
    internal func mapping(map: Map) {
        amountToPay <- map[PropertyKey.amountToPay.rawValue]
    }
}
