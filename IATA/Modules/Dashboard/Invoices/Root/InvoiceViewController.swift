import UIKit
import ObjectMapper

class InvoiceViewController: BaseViewController<InvoiceModel, DefaultInvoiceState>, OnChangeStateSelected, SwipeTableViewCellDelegate {
   
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var sumTextField: CurrencyUiTextField!
    @IBOutlet weak var selectedItemTextField: UILabel!
    @IBOutlet weak var downViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        state = DefaultInvoiceState()
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        self.downView.isHidden = true
        self.sumTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    @IBAction func makePay(_ sender: Any) {
        guard let amount = self.state?.amount else {
            return
        }
        
        guard let symbol = UserPreference.shared.getCurrentCurrency()?.symbol else {
            return
        }
        let message = R.string.localizable.invoiceScreenPaymentMessage(symbol + String(amount))
        let uiAlert = UIAlertController(title: R.string.localizable.invoiceScreenPleaseConfirmPayment(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.commonNavBarCancel(), style: .default, handler: nil))
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.invoiceScreenPay(), style: .default, handler: makePayment))
        
    }
    
    @IBAction func sumChanged(_ sender: Any) {
        if let text = self.sumTextField.text, let isEmpty = self.sumTextField.text?.isEmpty, isEmpty || (Int(text) == 0) {
            self.sumTextField.text = "0"
            setEnabledPay(isEnabled: false)
        } else {
            setEnabledPay(isEnabled: true)
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.bottomConstrain.constant = -keyboardSize.size.height/2 - 70
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstrain.constant = 0
    }
    
    override func getLeftButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: R.image.ic_filter(), style: .plain, target: self, action: #selector(self.clickFilter(sender:)))
    }
    
    override func getRightButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: R.image.ic_dispute(), style: .plain, target: self, action: #selector(self.clickDispute(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideMenu()
        self.loadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InvoiceTableViewCell.identifier, for: indexPath) as! InvoiceTableViewCell
        cell.checkBox.tag = indexPath.row
        cell.delegateChanged = self
        cell.delegate = self
        guard let dict = self.state?.getItems()[indexPath.row] else {
            return UITableViewCell()
        }
        guard let isChecked = self.state?.isChecked(model: dict) else {
            return UITableViewCell()
        }
        
        cell.initModel(model: dict, isChecked: isChecked)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        guard let state = self.state else {
            return nil
        }
        
        let stateCanBeOpenDispute = state.isCanBeOpenDispute(index: indexPath.row)
        let stateCanBeClosedDispute = state.isCanBeClosedDispute(index: indexPath.row)
        
        if (stateCanBeOpenDispute) {
            let disputeAction = SwipeAction(style: .destructive, title: R.string.localizable.invoiceScreenItemsDispute()) { action, indexPath in
                let disputInvoiceVC = DisputInvoiceViewController()
                disputInvoiceVC.invoiceId = state.getItems()[indexPath.row].id
                NavPushingUtil.shared.push(navigationController: self.navigationController, controller: disputInvoiceVC)
            }
            return getTableAction(Theme.shared.pinkDisputeColor,  swipeAction: disputeAction)
            
        } else if (stateCanBeClosedDispute) {
            
            return getTableAction(Theme.shared.grayDisputeColor, R.string.localizable.invoiceScreenItemsCancelDispute(), width: 140)
            
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.tabBarInvoicesItemTitle()
    }
    
    override func getTableView() -> UITableView {
        return tabView
    }
    
    override func registerCells() {
        self.tabView.register(InvoiceTableViewCell.nib, forCellReuseIdentifier: InvoiceTableViewCell.identifier)
    }
    
    @objc func clickFilter(sender: Any?) {
        let viewController = InvoiceSettingsViewController()
        viewController.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.present(viewController, animated: true, completion: nil)
        self.hideMenu()
    }
    
    @objc func clickDispute(sender: Any?) {
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.present(DisputeViewController(), animated: true, completion: nil)
        self.hideMenu()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == self.sumTextField) {
            
            if let text = self.sumTextField.getOldText(), let textNsString = text as? NSString {
            
                let newString = textNsString.replacingCharacters(in: range, with: string)
                
                if !(TextFieldUtil.validateMinValue(newString: newString, minValue:  0, range: range, replacementString: string, true)) {
                    return false
                }
                if !(TextFieldUtil.validateMaxValue(newString: newString, maxValue: self.state!.amount, range: range, replacementString: string)){
                    ViewUtils.shared.showToast(message: R.string.localizable.invoiceScreenErrorChangingAmount(), view: self.view)
                    return false
                
                }
            }
            
        }
        return true
    }
    
    func onItemSelected(isSelected: Bool, index: Int) {
        self.state?.newItem(isSelected: isSelected, index: index)
        self.selectedItemTextField.text = self.state?.getSelectedString()
        self.loadView(isShowLoading: false, isHiddenSelected: true)
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        self.state?.getAmount()
            .then(execute: { [weak self] (result: PaymentAmount) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.saveAmount(amount: result.amountToPay)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(error: error)
            })
        if (isSelected && self.downView.isHidden) {
            animate(isShow: true)
        } else if (!isSelected && !self.downView.isHidden && self.state?.getCountSelected() == 0) {
            self.sumTextField.text = ""
            animate(isShow: false)
        }
    }
    
    func makePayment(alert: UIAlertAction!) {
        let viewController = PinViewController()
        viewController.isValidationTransaction = true
        let items = self.state?.getItemsId()
        viewController.completion = {
            self.state?.makePayment(items: items)
                .then(execute: {[weak self] (result: BaseMappable) -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.paymentSuccess()
                }).catch(execute: { [weak self] error -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.handleError(error: error)
                })
        }
        self.navigationController?.present(viewController, animated: true, completion: nil)

    }
    
    func paymentSuccess() {
        ViewUtils.shared.showToast(message: R.string.localizable.commonSuccessMessage(), view: self.view)
        self.loadData()
        self.hideMenu()
    }
    
    private func setEnabledPay(isEnabled: Bool) {
        self.btnPay.isEnabled = isEnabled
        self.btnPay.alpha = isEnabled ? 1 : 0.2
        self.sumTextField.alpha = isEnabled ? 1 : 0.2
    }
    
    private func getTableAction(_ backgroundColor: UIColor, _ title: String, width: Int) -> [SwipeAction] {
        let disputeAction = SwipeAction(style: .destructive, title: title) { action, indexPath in
            
        }
        disputeAction.width = width
        disputeAction.image = UIView.from(color: backgroundColor)
        disputeAction.backgroundColor = UIColor.white
        disputeAction.font = Theme.shared.boldFontOfSize(14)
        
        return [swipeAction]
    }
    
    private func handleError(error : Error) {
        self.showErrorAlert(error: error)
        self.animate(isShow: false)
        self.tabView.reloadData()
    }

    
    private func saveAmount(amount: Double?) {
        if let amountValue = amount, !downView.isHidden {
            self.state?.amount = Double(amountValue)
            self.sumTextField.text = String(amountValue)
        }
        self.sumChanged(self.sumTextField)
        self.loadView(isShowLoading: true, isHiddenSelected: false)
    }
    
    private func loadView(isShowLoading: Bool, isHiddenSelected: Bool) {
        self.loading.isHidden = isShowLoading
        self.sumTextField.isHidden = isHiddenSelected
        self.selectedItemTextField.isHidden = isHiddenSelected
        isHiddenSelected ? self.loading.startAnimating() : self.loading.stopAnimating()
    }
    
    private func animate(isShow: Bool) {
        UIView.animate(withDuration: 0.0) {
            self.downView.alpha = isShow ? 1 : 0
        }
        view.endEditing(!isShow)
        if !isShow {
            self.state?.clearSelectedItems()
        }

        self.downView.isHidden = isShow ? false : true
        self.downViewHeightConstraint.constant = isShow ? 110 : 0
        self.loadView(isShowLoading: false, isHiddenSelected: true)
    }
    
    override func getNavBar() -> UINavigationBar? {
        return self.navigationController?.navigationBar
    }
 
    override func getNavItem() -> UINavigationItem? {
        return self.navigationItem
    }
    
    override func getTitleView() -> UIView {
        guard let state = self.state, let index = self.state?.getIndex() else {
            return Theme.shared.getTitle(title: getTitle(), color: UIColor.white)
        }
        self.state?.initSelected()
        let menuView = BTNavigationDropdownMenu(index: index, items: state.getMenuItems())
        menuView.backgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellBackgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellTextLabelColor = UIColor.white
        menuView.cellSeparatorColor = UIColor.clear
        menuView.menuTitleColor = UIColor.white
        menuView.cellSelectionColor = Theme.shared.tabBarBackgroundColor
        menuView.selectedCellTextLabelColor = Theme.shared.tabBarItemSelectedColor
        menuView.didSelectItemAtIndexHandler = {[weak self] (menu: Menu) -> () in
            FilterPreference.shared.saveIndexOfStatus(menu.type)
            self?.state?.selectedStatus(type: menu.type)
            self?.hideMenu()
            menuView.title = menu.title
            self?.loadData()
        }
        return menuView
    }
    
    private func loadData() {
        self.state?.getInvoiceStringJson()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            })
    }
    
    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        self.tabView.reloadData()
    }
    
    private func hideMenu() {
        self.view.endEditing(true)
        self.tabView.reloadData()
        self.animate(isShow: false)
        if (self.navigationItem.titleView is BTNavigationDropdownMenu) {
            let menu = self.navigationItem.titleView as! BTNavigationDropdownMenu
            menu.hideMenu()
            if let items = self.state?.getMenuItems() {
                menu.updateItems(items)
            }
        }
    }

    
}
