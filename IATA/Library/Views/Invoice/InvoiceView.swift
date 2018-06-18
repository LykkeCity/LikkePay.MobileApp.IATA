import Foundation
import UIKit

open class InvoiceView: UIView {
    
    @IBOutlet weak var icBodyDispute: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var status: UiStatusView!
    @IBOutlet weak var billingCategory: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var invoiceNumber: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var info: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaults()
    }
    
    private func setupDefaults() {
        Bundle.main.loadNibNamed("InvoiceView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    internal func initView(model: InvoiceModel) {
        self.name.text = model.clientName
        if let amount = model.amount, let symbol = model.symbol {
            self.price.text = String(amount) + symbol
        }
        self.billingCategory.text = model.billingCategory
        self.invoiceNumber.text = model.number
        if (model.status ==  InvoiceStatuses.Unpaid && !model.dispute!) {
            self.status.isHidden = true
            self.icBodyDispute.isHidden = true
        } else if (model.dispute!){
            self.initStatus(color: Theme.shared.greyStatusColor, status: "Invoice.Status.Items.Dispute".localize())
            self.icBodyDispute.isHidden = false
            self.status.isHidden = false
        } else {
            self.icBodyDispute.isHidden = true
            self.status.isHidden = false
        }
        //TODO add after api will be ready info =
    }
    
    internal func initStatus(color: UIColor, status: String) {
        self.status.textColor = color
        self.status.text = status.uppercased()
        self.status.color = color
        self.status.sizeToFit()
        self.status.insets = UIEdgeInsetsMake(2, 3, 2, 3)
        self.icBodyDispute.isHidden = true
    }
    
}
