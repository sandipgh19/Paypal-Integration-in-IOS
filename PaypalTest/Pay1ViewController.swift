//
//  ViewController.swift
//  PaypalTest
//
//  Created by Sandip Ghosh on 16/02/17.
//  Copyright © 2017 Sandip Ghosh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PayPalPaymentDelegate, PGTransactionDelegate {
    public func didCancelTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        print("Transaction has been Cancelled")
        self.removeController(controller: controller)
        

    }

    public func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        print(response)
        if response.count == 0 {
            print(response.description)
        }
        else if error != nil {
            print(error.localizedDescription)
        }
        self.removeController(controller: controller)
    }

    public func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
        print(response)
        print("Deducted amount :Rs. \(response["TXNAMOUNT"]!)")
        self.removeController(controller: controller)

    }

    
    @IBOutlet weak var btn_testPayment: UIButton!
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    var payPalConfig = PayPalConfiguration()
    let merchantConfig = PGMerchantConfiguration.default();
    
    let function = CommonFunctions()
    var txnID: String!
    var order_id: String!
    var Refund: String!
    
    class func generateOrderIDWithPrefix(prefix: String) -> String {
        
        srandom(UInt32(time(nil)))
        
        let randomNo: Int = 0;        //just randomizing the number
        let orderID: String = "\(prefix)\(randomNo)"
        return orderID
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Awesome Shirts, Inc."
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        
         btn_testPayment.addTarget(self, action: Selector(("Pay_btn_Action:")), for: UIControlEvents.touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func paypalPay(_ sender: Any) {
        
        let item1 = PayPalItem(name: "Old jeans with holes", withQuantity: 2, withPrice: NSDecimalNumber(string: "84.99"), withCurrency: "USD", withSku: "Hip-0037")
        let item2 = PayPalItem(name: "Free rainbow patch", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "USD", withSku: "Hip-00066")
        let item3 = PayPalItem(name: "Long-sleeve plaid shirt (mustache not included)", withQuantity: 1, withPrice: NSDecimalNumber(string: "37.99"), withCurrency: "USD", withSku: "Hip-00291")
        
        let items = [item1, item2, item3]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "5.99")
        let tax = NSDecimalNumber(string: "2.50")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Hipster Clothing", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self as PayPalPaymentDelegate)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            print("Payment not processalbe: \(payment)")
        }
        
    }
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
        })
    }

    
    func showController(controller: PGTransactionViewController) {
        
        if self.navigationController != nil {
            self.navigationController!.pushViewController(controller, animated: true)
        }
        else {
            self.present(controller, animated: true, completion: {() -> Void in
            })
        }
    }
    
    func removeController(controller: PGTransactionViewController) {
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
        else {
            controller.dismiss(animated: true, completion: {() -> Void in
            })
        }
    }
    
    func Pay_btn_Action(sender:UIButton!) {
        
        //Step 1: Create a default merchant config object
        let mc: PGMerchantConfiguration = PGMerchantConfiguration.default()
        
        //Step 2: If you have your own checksum generation and validation url set this here. Otherwise use the default Paytm urls
        
        mc.checksumGenerationURL = "https://pguat.paytm.com/paytmchecksum/paytmCheckSumGenerator.jsp"
        mc.checksumValidationURL = "https://pguat.paytm.com/paytmchecksum/paytmCheckSumVerify.jsp"
        
        //Step 3: Create the order with whatever params you want to add. But make sure that you include the merchant mandatory params
       // var odrDict: [NSObject : AnyObject] = (NSDictionary?() as? [NSObject : AnyObject])!
        var odrDict = NSDictionary?.self as? [AnyHashable: Any] ?? [:]
        
        odrDict["MID"] = "MID"
        odrDict["CHANNEL_ID"] = "WAP"
        odrDict["INDUSTRY_TYPE_ID"] = "Retail"
        odrDict["WEBSITE"] = "Website"
        odrDict["TXN_AMOUNT"] = "100"
        odrDict["ORDER_ID"] = "Random_Number"
        odrDict["REQUEST_TYPE"] = "DEFAULT"
        odrDict["CUST_ID"] = "1234567890"
        //let order: PGOrder = PGOrder(params: odrDict)
        
        let order: PGOrder = PGOrder(params: odrDict)
        
        //Step 4: Choose the PG server. In your production build dont call selectServerDialog. Just create a instance of the
        //PGTransactionViewController and set the serverType to eServerTypeProduction
        let transactionController = PGTransactionViewController.init(transactionFor: order)
        transactionController? .serverType = eServerTypeStaging
        transactionController? .merchant = merchantConfig
        transactionController? .delegate = self
        self.showController(controller: transactionController!)
        
        
    }
    
   /* // MARK: Delegate methods of Payment SDK.
    func didSucceedTransaction(controller: PGTransactionViewController, response: [NSObject : AnyObject]) {
        
        // After Successful Payment
        
        print("ViewController::didSucceedTransactionresponse= %@", response)
        let msg: String = "Your order was completed successfully.\n Rs. \(response)"
        
        
        self.function.alert_for(title: "Thank You for Payment", message: msg)
        self.removeController(controller: controller)
        
        
    }
    
    func didFailTransaction(controller: PGTransactionViewController, error: Error, response: [NSObject : AnyObject]) {
        // Called when Transation is Failed
        print("ViewController::didFailTransaction error = %@ response= %@", error, response)
        
        if response.count == 0 {
            
            self.function.alert_for(title: error.localizedDescription, message: response.description)
            
        }
        else if error != nil {
            
            self.function.alert_for(title: "Error", message: error.localizedDescription)
            
            
        }
        
        self.removeController(controller: controller)
        
    }
    
    func didCancelTransaction(controller: PGTransactionViewController, error: Error, response: [NSObject : AnyObject]) {
        
        //Cal when Process is Canceled
        var msg: String? = nil
        
        if (error != nil ){
            
            msg = String(format: "Successful")
        }
        else {
            msg = String(format: "UnSuccessful")
        }
        
        
        self.function.alert_for(title: "Transaction Cancel", message: msg!)
        
        self.removeController(controller: controller)
        
    }*/
    
    private func didFinishCASTransaction(controller: PGTransactionViewController, response: [NSObject : AnyObject]) {
        
        print("ViewController::didFinishCASTransaction:response = %@", response);
        
    }

}

