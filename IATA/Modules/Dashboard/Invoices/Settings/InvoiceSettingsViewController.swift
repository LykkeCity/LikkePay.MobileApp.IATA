import UIKit

class InvoiceSettingsViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func clickCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private let viewModel = InvoiceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.dataSource = viewModel
        self.tableView?.delegate = viewModel
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 55
        
        self.tableView.register(InvoiceHeaderView.nib, forHeaderFooterViewReuseIdentifier: InvoiceHeaderView.identifier)
        
        self.tableView?.register(PaymentRangeTableViewCell.nib, forCellReuseIdentifier: PaymentRangeTableViewCell.identifier)
        self.tableView?.register(InvoiceSettingsTableViewCell.nib, forCellReuseIdentifier: InvoiceSettingsTableViewCell.identifier)
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.bottomConstraint.constant = keyboardSize.size.height/2 + 20
                self.viewModel.scrollToLastPosition(tableView: self.tableView)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initNavBar()
    }
    
    private func initNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = Theme.shared.navBarTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Theme.shared.navBarTitle]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.initBackButton()
        self.initRightButton()
        self.initTitle()
    }
    
    private func initBackButton() {
        let backButton = Theme.shared.getCancel(title: "Common.NavBar.Cancel".localize(), color: Theme.shared.navBarTitle)
        backButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    private func initRightButton() {
        let rightButton = Theme.shared.getRightButton(title: "Common.NavBar.Done".localize(), color: Theme.shared.textFieldColor)
        rightButton.addTarget(self, action: #selector(clickDone), for: .touchUpInside)
        
        let rightItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    private func initTitle() {
        let titleLabel = Theme.shared.getTitle(title: "Invoice.Settings.Filter.Title".localize(), color: Theme.shared.navBarTitle)
        self.navigationItem.titleView = titleLabel
    }
    
    @objc func clickDone() {
        self.viewModel.state.clickDone()
        self.navigationController?.popViewController(animated: true)
    }
}
