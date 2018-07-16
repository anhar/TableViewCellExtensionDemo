//
//  CachableImageApiRequest.swift
//  MostViewify
//
//  Created by Andreas Hård on 2017-11-05.
//  Copyright © 2017 Andreas Hård. All rights reserved.
//

import UIKit
import Result

final class CachableImageApiRequest: NSObject {

    public enum ImageError: Error {
        case generic(Error)
        case cachedDataConversion(Error)
        case downloadDataConversion(Error)
    }
    
    static let sharedInstance = CachableImageApiRequest()
    public typealias CompletionHandler = (Result<UIImage, ImageError>) -> Swift.Void
    let cacheMemoryCapacity = 10 * 1024 * 1024
    let cacheDiskCapacity = 40 * 1024 * 1024
    let cacheDiskPath = "imagesDownloadCache"
    var config: URLSessionConfiguration
    let urlCache: URLCache
    let session: URLSession
    
    override private init() {
        urlCache = URLCache(memoryCapacity: cacheMemoryCapacity, diskCapacity: cacheDiskCapacity, diskPath: cacheDiskPath)
        config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = urlCache
        session = URLSession(configuration: config)
        
        super.init()
    }
    
    func fetchImage(url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask? {
        var request = URLRequest(url: url)
        request.timeoutInterval = 60
        if let cachedResponse = urlCache.cachedResponse(for: request) {
            if let cachedImage = UIImage(data: cachedResponse.data){
                DispatchQueue.main.async {
                    completionHandler(Result.success(cachedImage))
                }
            } else {
                urlCache.removeCachedResponse(for: request)
                let error = self.imageConversionError(url: url, cachedData: true)
                
                DispatchQueue.main.async {
                    completionHandler(Result.failure(ImageError.cachedDataConversion(error)))
                }
            }
            return nil
        } else {
            let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if let apiError = error {
                    DispatchQueue.main.async {
                        completionHandler(Result.failure(ImageError.generic(apiError)))
                    }
                }
                else if let responseData = data {
                    if let image : UIImage = UIImage(data: responseData){
                        DispatchQueue.main.async {
                            completionHandler(Result.success(image))
                        }
                    } else {
                        let error = self.imageConversionError(url: url, cachedData: false)
                        DispatchQueue.main.async {
                            completionHandler(Result.failure(ImageError.downloadDataConversion(error)))
                        }
                    }
                }
            })
            return dataTask
        }
    }
    
    func imageConversionError(url: URL, cachedData: Bool) -> Error {
        let errorStr = cachedData ? "Failed to convert cached responseData to UIImage class" : "Failed to convert responseData to UIImage class"
        return NSError(domain: url.absoluteString, code: 0, userInfo: [NSLocalizedDescriptionKey : errorStr])
    }
}
