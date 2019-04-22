//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
    
    let productId = "com.HumbeekWave.InspoQuotesBPH.Premium"
    var premiumQuotesPurchased : Bool? = nil
    
    
    var quotes = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    var quotesToShow : [String] = []

    //----------------------------------------------------------------------------------------------------------
    //MARK: - Loading Navigationcontroller
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
         premiumQuotesPurchased = checkIfPremiumIsPurchased()
        loadQuotes()
     }

    //----------------------------------------------------------------------------------------------------------
    //MARK: - Tableview Datasource Methods
    //
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let purchased = premiumQuotesPurchased {
            return premiumQuotesPurchased! ? quotesToShow.count : quotesToShow.count + 1
        } else {
            return quotesToShow.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell" , for: indexPath)
        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.textColor = .black
            cell.textLabel?.numberOfLines = 0
            cell.accessoryType = .none
    } else {
            cell.textLabel?.text = "Buy extra quotes"
            cell.textLabel?.textColor = #colorLiteral(red: 0.3647058824, green: 0.568627451, blue: 1, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }
         return cell
    }
    
    //----------------------------------------------------------------------------------------------------------
    //MARK: - TableView Delegate methods
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == quotesToShow.count{
            buyPremiumQuotes()
         }
    }
   
    //----------------------------------------------------------------------------------------------------------
    //MARK: - In-App Purchase Methods
    //
    func buyPremiumQuotes(){
        if SKPaymentQueue.canMakePayments() {
            let payementRequest = SKMutablePayment()
            payementRequest.productIdentifier = productId
            SKPaymentQueue.default().add(payementRequest)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        var errorDescription : String
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing :
                print("BPH: transaction has state 'Purchasing'")
            case .purchased, .restored :
                SKPaymentQueue.default().finishTransaction(transaction)
                premiumQuotesPurchased = true
                UserDefaults.standard.set(true, forKey: productId)
                loadQuotes()
            case .failed :
                if let error = transaction.error {
                    errorDescription = error.localizedDescription
                } else {
                    errorDescription = "no error description received"
                }
                print("BPH: transaction has state .failed with following desciprion : \(errorDescription)")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred :
                print("BPH: transaction has state 'deferred'")
            default:
                print("BPH: unknown app store transaction state \(transaction.transactionState) encountered...")
            }
        }
    }
    
    func loadQuotes() {
        quotesToShow = quotes
        if let purchased = premiumQuotesPurchased {
            if purchased {
                quotesToShow.append(contentsOf: premiumQuotes)
                navigationItem.setRightBarButton(nil, animated: true)
            }
        }
    }
    
    func checkIfPremiumIsPurchased() -> Bool? {
        if UserDefaults.standard.object(forKey: productId) == nil {
            return nil
      } else {
            return(UserDefaults.standard.bool(forKey: productId))
        }
    }
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
      SKPaymentQueue.default().restoreCompletedTransactions()
    }

}
