//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, coinData: CoinData)
    func didFailWithError(_ error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "96651CA1-D1AE-427E-8219-664BF9C37D5E"
    
    let currencyArray = ["INR","AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        print("get coin price with currency \(currency)")
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, urlResponse, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let coinData = self.parseJSON(data: safeData) {
                        print("got data from web")
                        self.delegate?.didUpdatePrice(self, coinData: coinData)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(data: Data) -> CoinData? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let coinData = CoinData(rate: decodedData.rate)
            return coinData
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
