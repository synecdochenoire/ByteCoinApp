import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice (price: String, currency: String )
    func didFailWithError(error: Error)
}

struct CoinManager  {
    
    var delegate  : CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "9B8D9EBB-D977-43F9-AD70-2C8939547364"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","UAH","USD"]
    
    func getCoinPrice(for currency: String) {
            
            let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"

            if let url = URL(string: urlString) {
                
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    
                    if let safeData = data {
                        
                        if let bitcoinPrice = self.parseJSON(safeData) {
                            let priceString = String(format:"%.2f", bitcoinPrice)
                            self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                        }
                    }
                    
                }
                task.resume()
            }
        }
        
        func parseJSON(_ data: Data) -> Double? {
            
            //Create a JSONDecoder
            let decoder = JSONDecoder()
            do {
                
                //try to decode the data using the CoinData structure
                let decodedData = try decoder.decode(CoinData.self, from: data)
            
                let lastPrice = decodedData.rate
                print(lastPrice)
                return lastPrice
                
            } catch {
                
                //Catch and print any errors.
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
        
    }
