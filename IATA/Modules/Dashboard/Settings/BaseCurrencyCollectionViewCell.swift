
import UIKit

class BaseCurrencyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var baseCurrencyFlagImage: UIImageView!

    @IBOutlet weak var baseCurrencyNameLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                applySelectedCellTheme()
            } else {
                applyUnselectedCellTheme()
            }

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyUnselectedCellTheme()
    }

    private func applySelectedCellTheme() {
        generateCellTheme(borderWidth: 1, cornerRadius: 4, borderColor: Theme.shared.selectedBaseCurrencyBorderCell.cgColor)
    }

    private func applyUnselectedCellTheme() {
        generateCellTheme(borderWidth: 1, cornerRadius: 4, borderColor: Theme.shared.unselectedBaseCurrencyBorderCell.cgColor)
    }

    private func generateCellTheme(borderWidth: CGFloat, cornerRadius: CGFloat, borderColor: CGColor ){
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor
    }
}

