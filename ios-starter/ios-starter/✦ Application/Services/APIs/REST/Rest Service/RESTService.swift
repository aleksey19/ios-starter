//
//  RESTService.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation
import SystemConfiguration
import MobileCoreServices
import UIKit

class RESTService: NSObject {
    enum RestType: String {
        case post = "POST"
        case put = "PUT"
        case get = "GET"
        case delete = "DELETE"
        case head = "HEAD"
    }
    
    enum MimeType: String {
        case none = ""
        case json = "application/json"
        case xml = "application/xml"
        case jpeg = "image/jpeg"
        case png = "image/png"
        case gif = "image/gif"
        case html = "text/html"
        case text = "text/plain"
        case mov = "video/quicktime"

        static func typeForString(_ type: String) -> MimeType? {
            return MimeType.init(rawValue: type)
        }
    }
    
    enum ImageType {
        case jpeg
        case png
        case gif
    }
    
    enum CacheType {
        case none
        case onlyImages
        case all
    }
    
    fileprivate class TaskHandlersContainer {
        var url: String
        var id: String?
        var returnRedirectedUrl: Bool = false
        var clearHeaderWhenRedirect: Bool = true
        var retrieveCount: Int = 0
        var data: Data?
        var completion:((_ handlers: TaskHandlersContainer, _ data: Any?, _ response: URLResponse?, _ error: Error?) -> Void)?
        var sendProgress:((_ part: Int64?, _ total: Int64?) -> Void)?
        var receiveProgress:((_ part: Int64?, _ total: Int64?) -> Void)?

        init(url: String) {
            self.url = url
        }
    }
    
    static let shared = RESTService()
    
    var additionalPathParameters: (() -> ([String: String]?))?
    var additionalHeaderParameters: (() -> ([String: String]?))?
    var authoriationErrorHandler: ((URLResponse?) -> Void)?
    var authoriationRefreshHandler: ((@escaping (Bool) -> Void) -> Void)?
    var internetConnectionReachableHandler: ((_ connected: Bool) -> Void)?
    
    private let urlCacheType: CacheType
    private var session: URLSession?
    private var tasksHandlers: [URLSessionTask: TaskHandlersContainer] = Dictionary.init()
    private var previousInternetConnectionReachability: Bool = true

    var downloadUrlsCache: [String: String] = [:]
    var sessionThread: DispatchQueue = DispatchQueue.init(label: "RESTServiceSession")

    
    init(cacheType: CacheType = .none) {
        self.urlCacheType = cacheType
        
        super.init()
        
        prepare()
    }
    
    deinit {
        invalidate()
    }
}

extension RESTService {
    func clearCookies() {
        let cookieJar = HTTPCookieStorage.shared
        
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
}

extension RESTService {
    class var isConnectedToNetwork: Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, 
                                      sin_family: 0, 
                                      sin_port: 0, 
                                      sin_addr: in_addr(s_addr: 0), 
                                      sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    class var isReachableViaWiFi: Bool {
        var zeroAddress = sockaddr_in(sin_len: 0,
                                      sin_family: 0,
                                      sin_port: 0,
                                      sin_addr: in_addr(s_addr: 0),
                                      sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        guard let reachebility = defaultRouteReachability else { return false }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachebility, UnsafeMutablePointer(&flags))
        return !flags.contains(.isWWAN) && flags.contains(.reachable)
    }
    
    private func checkInternetConnectionReachable() {
        let isReachable = RESTService.isConnectedToNetwork
        
        if isReachable != previousInternetConnectionReachability {
            internetConnectionReachableHandler?(isReachable)
        }
    }
    
}

extension RESTService {
    private func prepare() {
        let config = URLSessionConfiguration.default
        
        #if os(tvOS)
        if #available(tvOS 11.0, *) {
            config.waitsForConnectivity = true
        }
        #endif
        
        #if os(iOS)
        if #available(iOS 11.0, *) {
            config.waitsForConnectivity = true
        }
        #endif
        
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 300
        config.allowsCellularAccess = true        
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        
        if urlCacheType != .none {
            let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let diskCacheUrl = cachesUrl.appendingPathComponent("DownloadCache")
            let cache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 100_000_000, directory: diskCacheUrl) // 10 MB for memory and 100 MB for disk cache

            config.urlCache = cache
        }

        session = URLSession.init(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    private func invalidate() {
        session?.invalidateAndCancel()
    }
}

extension RESTService {
    private var urlError: Error {
        return generateError(code: 0, description: "URL invalid")
        
    }
    
    func generateError(code: Int = 0, description: String) -> Error {
        let text = NSLocalizedString("Fail", value: description, comment: "")
        
        return NSError.init(domain: "RESTService",
                            code: code,
                            userInfo: [NSLocalizedDescriptionKey: text])
    }
    
    func generateError(from data: Data, basedOn responseError: Error? = nil) -> Error? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any],
            let errors = object["errors"] as? [String]
        else {
            return nil
        }
        
        let code = (responseError as NSError?)?.code ?? 0
        let text = errors.reduce(" ", +)
        
        return NSError.init(domain: "RESTService",
                            code: code,
                            userInfo: [NSLocalizedDescriptionKey: text])
    }
}

extension RESTService {
    func removeAllTasks() {
        session?.getAllTasks(completionHandler: { (tasks) in
            for item in tasks {
                item.cancel()
            }
        })
    }
    
    func removeAllRequestTasks() {
        session?.getTasksWithCompletionHandler({ (dataTasks, _, _) in
            for item in dataTasks {
                item.cancel()
            }
        })
    }
    
    func removeAllDownloadFileTasks() {
        session?.getTasksWithCompletionHandler({ (_, _, downloadTasks) in
            for item in downloadTasks {
                item.cancel()
            }
        })
    }
    
    func removeTasks(containingPath path: String, type: RestType? = nil) {
        session?.getAllTasks(completionHandler: { (tasks) in
            for item in tasks {
                if let url = item.originalRequest?.url {
                    if url.absoluteString.contains(path) == true {
                        if let type = type {
                            if let httpMethod = item.originalRequest?.httpMethod,
                               httpMethod == type.rawValue {
                                item.cancel()
                            }
                        } else {
                            item.cancel()
                        }
                    }
                }
            }
        })
    }

    func removeTasks(containingPaths paths: [String]) {

        session?.getAllTasks(completionHandler: { (tasks) in
            for item in tasks {
                if let url = item.originalRequest?.url {
                    if paths.contains(where: { (path) -> Bool in
                        path.contains(url.path)
                    }) {
                        item.cancel()
                    }
                }
            }
        })
    }

    func removeFirstTask(containingPath path: String, type: RestType? = nil) {
        session?.getAllTasks(completionHandler: { (tasks) in
            for item in tasks {
                if let url = item.originalRequest?.url {
                    if url.absoluteString.contains(path) == true {
                        if let type = type {
                            if let httpMethod = item.originalRequest?.httpMethod,
                               httpMethod == type.rawValue {
                                item.cancel()
                                return
                            }
                        } else {
                            item.cancel()
                            return
                        }
                    }
                }
            }
        })
    }

    func removeTasks(withId id: String) {
        tasksHandlers.forEach { (key, value) in
            guard value.id == id else {
                return
            }

            key.cancel()
        }
    }

    func inProgressTask(containingPath path: String, completion: @escaping (_ inProgress: Bool, _ countOfLoaders: Int) -> Void) {
        var inProgress: Bool = false
        var countOfLoaders: Int = 0

        session?.getAllTasks(completionHandler: { (tasks) in
            for item in tasks {
                if let url = item.originalRequest?.url {
                    if url.absoluteString.contains(path) == true {
                        inProgress = true
                        countOfLoaders += 1
                    }
                }
            }
        })

        completion(inProgress, countOfLoaders)
    }
}

extension RESTService {
    var mimeTypes: [String: String] {
        [
            "html": "text/html",
            "htm": "text/html",
            "shtml": "text/html",
            "css": "text/css",
            "xml": "text/xml",
            "gif": "image/gif",
            "jpeg": "image/jpeg",
            "jpg": "image/jpeg",
            "js": "application/javascript",
            "atom": "application/atom+xml",
            "rss": "application/rss+xml",
            "mml": "text/mathml",
            "txt": "text/plain",
            "jad": "text/vnd.sun.j2me.app-descriptor",
            "wml": "text/vnd.wap.wml",
            "htc": "text/x-component",
            "png": "image/png",
            "tif": "image/tiff",
            "tiff": "image/tiff",
            "wbmp": "image/vnd.wap.wbmp",
            "ico": "image/x-icon",
            "jng": "image/x-jng",
            "bmp": "image/x-ms-bmp",
            "svg": "image/svg+xml",
            "svgz": "image/svg+xml",
            "webp": "image/webp",
            "woff": "application/font-woff",
            "jar": "application/java-archive",
            "war": "application/java-archive",
            "ear": "application/java-archive",
            "json": "application/json",
            "hqx": "application/mac-binhex40",
            "doc": "application/msword",
            "pdf": "application/pdf",
            "ps": "application/postscript",
            "eps": "application/postscript",
            "ai": "application/postscript",
            "rtf": "application/rtf",
            "m3u8": "application/vnd.apple.mpegurl",
            "xls": "application/vnd.ms-excel",
            "eot": "application/vnd.ms-fontobject",
            "ppt": "application/vnd.ms-powerpoint",
            "wmlc": "application/vnd.wap.wmlc",
            "kml": "application/vnd.google-earth.kml+xml",
            "kmz": "application/vnd.google-earth.kmz",
            "7z": "application/x-7z-compressed",
            "cco": "application/x-cocoa",
            "jardiff": "application/x-java-archive-diff",
            "jnlp": "application/x-java-jnlp-file",
            "run": "application/x-makeself",
            "pl": "application/x-perl",
            "pm": "application/x-perl",
            "prc": "application/x-pilot",
            "pdb": "application/x-pilot",
            "rar": "application/x-rar-compressed",
            "rpm": "application/x-redhat-package-manager",
            "sea": "application/x-sea",
            "swf": "application/x-shockwave-flash",
            "sit": "application/x-stuffit",
            "tcl": "application/x-tcl",
            "tk": "application/x-tcl",
            "der": "application/x-x509-ca-cert",
            "pem": "application/x-x509-ca-cert",
            "crt": "application/x-x509-ca-cert",
            "xpi": "application/x-xpinstall",
            "xhtml": "application/xhtml+xml",
            "xspf": "application/xspf+xml",
            "zip": "application/zip",
            "bin": "application/octet-stream",
            "exe": "application/octet-stream",
            "dll": "application/octet-stream",
            "deb": "application/octet-stream",
            "dmg": "application/octet-stream",
            "iso": "application/octet-stream",
            "img": "application/octet-stream",
            "msi": "application/octet-stream",
            "msp": "application/octet-stream",
            "msm": "application/octet-stream",
            "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            "mid": "audio/midi",
            "midi": "audio/midi",
            "kar": "audio/midi",
            "mp3": "audio/mpeg",
            "ogg": "audio/ogg",
            "m4a": "audio/x-m4a",
            "ra": "audio/x-realaudio",
            "3gpp": "video/3gpp",
            "3gp": "video/3gpp",
            "ts": "video/mp2t",
            "mp4": "video/mp4",
            "mpeg": "video/mpeg",
            "mpg": "video/mpeg",
            "mov": "video/quicktime",
            "webm": "video/webm",
            "flv": "video/x-flv",
            "m4v": "video/x-m4v",
            "mng": "video/x-mng",
            "asx": "video/x-ms-asf",
            "asf": "video/x-ms-asf",
            "wmv": "video/x-ms-wmv",
            "avi": "video/x-msvideo"
        ]
    }
    
    func fileExtension(forMimeType mimeType: String) -> String? {
        for (key, value) in mimeTypes where value == mimeType {
            return key
        }
        
        return nil
    }
    
    func mimeTypeForPath(path: String) -> String? {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, 
                                                           pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        
        return nil
    }
}

extension RESTService {
    func sizeForLocal(url: String) -> UInt64? {
        var fileSize: UInt64
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url)
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
            
            return fileSize
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func sizeOfRemoteFile(url: String,
                          inPathParameters pathParameters: [String: String]? = nil,
                          inBodyParameters bodyParameters: [String: Any]? = nil,
                          completion: ((_ lenght: Int64?, _ error: Error?) -> Void)? = nil) {
        var jsonData: Data?
        
        if let bodyParameters = bodyParameters {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch {
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
                return
            }
        }
        
        sizeOfRemoteFile(url: url,
                         inPathParameters: pathParameters,
                         body: jsonData,
                         mimeType: .json,
                         completion: completion)
    }
    
    func sizeOfRemoteFile(url: String,
                          inPathParameters pathParameters: [String: String]? = nil,
                          body: Data? = nil,
                          mimeType: MimeType = .json,
                          completion: ((_ lenght: Int64?, _ error: Error?) -> Void)? = nil) {
        checkInternetConnectionReachable()
        
        guard let url = URL(string: add(toPath: url, parameters: pathParameters)) else {
            DispatchQueue.main.async {
                completion?(nil, self.urlError)
            }
            return
        }
        
        var request = URLRequest.init(url: url)
        request.setValue(mimeType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpMethod = RestType.head.rawValue
        
        addHeaderToRequest(&request)
        
        if let body = body {
            request.httpBody = body
        }
        
        session?.dataTask(with: request) { (_, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion?(nil,
                                self.generateError(code: 0,
                                                   description: "HTTP request error"))
                }
                return
            }

            let statusCode = httpResponse.statusCode

            if !(200...299).contains(statusCode) {
                DispatchQueue.main.async {                    
                    completion?(nil, self.generateError(code: statusCode, description: "Server error"))
                }
                return
            } else {
                let contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown

                DispatchQueue.main.async {
                    completion?(contentLength, nil)
                }
                return
            }
        }.resume()
    }
}

extension RESTService {
    func image(url: String,
               inPathParameters pathParameters: [String : String]? = nil,
               id: String? = nil,
               completion: @escaping (Error?, UIImage?, String?) -> Void,
               progress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) {
        file(url: url,
             inPathParameters: pathParameters,
             id: id,
             saveToCache: true,
             checkRemoteIsChanged: false,
             completion: {(error, url, _) in
                DispatchQueue.main.async {
                    if error != nil {
                        completion(error, nil, id)
                    }
                    
                    guard error == nil,
                          let path = url?.path,
                          FileManager.default.fileExists(atPath: path) else {
                        completion(error, nil, id)
                        return
                    }
                    
                    completion(error, UIImage.init(contentsOfFile: path), id)
                }
             },
             progress: progress)
    }
    
    func file(url: String,
              inPathParameters pathParameters: [String: String]? = nil,
              inBodyParameters bodyParameters: [String: Any]? = nil,
              id: String? = nil,
              saveToCache: Bool = false,
              saveToDisk: Bool = false,
              checkRemoteIsChanged: Bool = false,
              completion: ((_ error: Error?, _ fileUrl: URL?, _ mimeType: MimeType?) -> Void)? = nil,
              progress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) {
        var jsonData: Data?
        
        if let bodyParameters = bodyParameters {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch {
                DispatchQueue.main.async {
                    completion?(error, nil, .none)
                }
                return
            }
        }
        
        file(url: url,
             inPathParameters: pathParameters,
             body: jsonData,
             mimeType: .json,
             id: id,
             saveToCache: saveToCache,
             saveToDisk: saveToDisk,
             checkRemoteIsChanged: checkRemoteIsChanged,
             completion: completion,
             progress: progress)
    }
    
    func file(url: String,
              inPathParameters pathParameters: [String: String]? = nil,
              body: Data? = nil,
              mimeType: MimeType = .json,
              id: String? = nil,
              saveToCache: Bool = false,
              saveToDisk: Bool = false,
              checkRemoteIsChanged: Bool = false,
              completion: ((_ error: Error?, _ fileUrl: URL?, _ mimeType: MimeType?) -> Void)? = nil,
              progress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) {
        let modifiedUrl = add(toPath: url, parameters: pathParameters)

        let downloadFromRemote = {
            self.downloadFile(url: modifiedUrl,
                              inPathParameters: pathParameters,
                              body: body,
                              mimeType: mimeType,
                              id: id,
                              saveToCache: saveToCache,
                              saveToDisk: saveToDisk,
                              completion: completion,
                              progress: progress)
        }

        let downloadFromLocal: () -> Bool = {
            guard let cachedUrl = self.downloadUrlsCache[modifiedUrl] else {
                return false
            }

            let url = URL.init(fileURLWithPath: cachedUrl as String)
            let mimeType: MimeType

            if let type = self.mimeTypeForPath(path: cachedUrl as String) {
                mimeType = MimeType.typeForString(type) ?? .none
            } else {
                mimeType = .none
            }

            completion?(nil, url, mimeType)

            return true
        }

        let checkIfLocalEqualRemote: (_ completion: @escaping (Bool) -> Void) -> Void = { completion in
            self.sizeOfRemoteFile(url: modifiedUrl,
                                  inPathParameters: pathParameters,
                                  body: body,
                                  mimeType: mimeType) { (lenght, error) in
                guard error == nil,
                      let lenght = lenght,
                      let cachedUrl = self.downloadUrlsCache[modifiedUrl],
                      let cacheSize = self.sizeForLocal(url: cachedUrl as String),
                      lenght == cacheSize else {
                    completion(false)
                    return
                }

                completion(true)
            }
        }

        if checkRemoteIsChanged {
            checkIfLocalEqualRemote { equal in
                if equal,
                   downloadFromLocal() {
                    return
                } else {
                    downloadFromRemote()
                    return
                }
            }
        } else {
            if !downloadFromLocal() {
                downloadFromRemote()
            }
        }
    }
    
    private func downloadFile(url: String,
                              inPathParameters pathParameters: [String: String]? = nil,
                              body: Data? = nil,
                              mimeType: MimeType = .json,
                              id: String? = nil,
                              saveToCache: Bool = false,
                              saveToDisk: Bool = false,
                              completion: ((_ error: Error?, _ fileUrl: URL?, _ mimeType: MimeType?) -> Void)? = nil,
                              progress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) {
        self.checkInternetConnectionReachable()

        guard let url = URL(string: url) else {
            DispatchQueue.main.async {
                completion?(self.urlError, nil, RESTService.MimeType.none)
            }
            return
        }
        
        var request = URLRequest.init(url: url)
        request.setValue(mimeType.rawValue, forHTTPHeaderField: "Content-Type")
        
        self.addHeaderToRequest(&request)
        
        if let body = body {
            request.httpBody = body
        }

        guard let task = session?.downloadTask(with: request) else {
            return
        }

        let completion: ((TaskHandlersContainer, Any?, URLResponse?, Error?) -> Void) = { handlers, data, response, error in
            self.process(downloadTask: task,
                         handlers: handlers,
                         data: data as? URL,
                         response: response,
                         error: error,
                         saveToCache: saveToCache,
                         saveToDisk: saveToDisk,
                         completion: completion)
        }

        sessionThread.sync {
            let handler = TaskHandlersContainer.init(url: url.absoluteString)
            handler.id = id
            handler.receiveProgress = progress
            handler.completion = completion

            let taskExist = tasksHandlers.contains { (_, value) -> Bool in
                value.url == url.absoluteString
            }

            self.tasksHandlers[task] = handler

            if !taskExist {
                task.resume()
            }
        }
    }
    
    func downloadImage(url: String,
                       inPathParameters pathParameters: [String: String]? = nil,
                       body: Data? = nil,
                       mimeType: MimeType = .json,
                       id: String? = nil,
                       saveToCache: Bool = false,
                       saveToDisk: Bool = false,
                       completion: ((_ error: Error?, _ data: Data?, _ mimeType: MimeType?) -> Void)? = nil,
                       progress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) {
        self.checkInternetConnectionReachable()

        guard let url = URL(string: url) else {
            DispatchQueue.main.async {
                completion?(self.urlError, nil, RESTService.MimeType.none)
            }
            return
        }
        
        let cachePolicy: URLRequest.CachePolicy = urlCacheType == .onlyImages ? .returnCacheDataElseLoad : .useProtocolCachePolicy

        var request = URLRequest.init(url: url, cachePolicy: cachePolicy)
        request.setValue(mimeType.rawValue, forHTTPHeaderField: "Content-Type")
        
        self.addHeaderToRequest(&request)
        
        if let body = body {
            request.httpBody = body
        }
        
        if mimeType == .png || mimeType == .jpeg,
           let data = session?.configuration.urlCache?.cachedResponse(for: request)?.data {
            completion?(nil, data, mimeType)
            return
        }
        
        let task = session?.downloadTask(with: request,
                                         completionHandler: { [weak self] (url, response, error) in

                                            if let url = url,
                                               let response = response,
                                               let data = try? Data(contentsOf: url),
                                               self?.session?.configuration.urlCache?.cachedResponse(for: request) == nil {
                                                
                                                self?.session?.configuration.urlCache?.storeCachedResponse(.init(response: response, data: data),
                                                                                                           for: request)
                                                
                                                completion?(nil, data, mimeType)
                                            } else if let error = error {
                                                completion?(error, nil, mimeType)
                                            }
                                         })

        guard let _ = task else {
            return
        }

        sessionThread.sync {
            let handler = TaskHandlersContainer.init(url: url.absoluteString)
            handler.id = id
            handler.receiveProgress = progress
//            handler.completion = completion

            let taskExist = tasksHandlers.contains { (_, value) -> Bool in
                value.url == url.absoluteString
            }

            self.tasksHandlers[task!] = handler

            if !taskExist {
                task?.resume()
            }
        }
    }

    func save(directory: FileManager.SearchPathDirectory,
              image: UIImage,
              remoteUrl: URL,
              completion: ((_ error: Error?, _ fileUrl: URL?) -> Void)? = nil) {
        guard let data = image.pngData() else {
            DispatchQueue.main.async {
                completion?(nil, nil)
            }

            return
        }

        do {
            let documentsURL = try FileManager.default.url(for: directory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true)
            let savedURL: URL

            if let mimeType = mimeTypes["png"],
               let fileExtension = fileExtension(forMimeType: mimeType) {
                savedURL = documentsURL.appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExtension)
            } else {
                savedURL = documentsURL.appendingPathComponent(UUID().uuidString).appendingPathExtension(remoteUrl.pathExtension)
            }

            try data.write(to: savedURL)

            self.downloadUrlsCache[remoteUrl.absoluteString] = savedURL.path

            DispatchQueue.main.async {
                completion?(nil, savedURL)
            }

            return
        } catch {
            DispatchQueue.main.async {
                completion?(error, nil)
            }

            return
        }
    }

    func save(directory: FileManager.SearchPathDirectory,
              fileUrl: URL,
              remoteUrl: URL,
              mimeType: String?,
              completion: ((_ error: Error?, _ fileUrl: URL?) -> Void)? = nil) {
        do {
            if self.downloadUrlsCache.keys.contains(remoteUrl.absoluteString),
               let path = self.downloadUrlsCache[remoteUrl.absoluteString],
               let url = URL(string: path) {
                DispatchQueue.main.async {
                    completion?(nil, url)
                }

                return
            }

            let documentsURL = try FileManager.default.url(for: directory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true)
            
            let savedURL: URL

            if let mimeType = mimeType, 
               let fileExtension = fileExtension(forMimeType: mimeType) {
                savedURL = documentsURL.appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExtension)
            } else {
                savedURL = documentsURL.appendingPathComponent(UUID().uuidString).appendingPathExtension(remoteUrl.pathExtension)
            }

            if FileManager.default.fileExists(atPath: savedURL.absoluteString) {
                try FileManager.default.removeItem(atPath: savedURL.absoluteString)
            }
            
            try FileManager.default.moveItem(at: fileUrl, to: savedURL)

            self.downloadUrlsCache[remoteUrl.absoluteString] = savedURL.path

            DispatchQueue.main.async {
                completion?(nil, savedURL)
            }
            
            return
        } catch {
            DispatchQueue.main.async {
                completion?(error, nil)
            }
            
            return
        }
    }

    func redirect(type: RestType,
                  url: String,
                  inPathParameters pathParameters: [String: String]? = nil,
                  inBodyParameters bodyParameters: [String: Any]? = nil,
                  completion: ((_ error: Error?, _ url: URL?) -> Void)?) -> URLSessionTask? {
        var jsonData: Data?

        if let bodyParameters = bodyParameters {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch {
                DispatchQueue.main.async {
                    completion?(error, nil)
                }
                return nil
            }
        }

        return redirect(type: type,
                        url: url,
                        inPathParameters: pathParameters,
                        body: jsonData,
                        mimeType: .json,
                        completion: completion)
    }

    func redirect(type: RestType,
                  url: String,
                  inPathParameters pathParameters: [String: String]? = nil,
                  body: Data? = nil,
                  mimeType: MimeType = .json,
                  completion: ((_ error: Error?, _ url: URL?) -> Void)?) -> URLSessionTask? {
        guard let url = URL(string: add(toPath: url, parameters: pathParameters)) else {
            DispatchQueue.main.async {
                completion?(self.urlError, nil)
            }
            return nil
        }

        var request = URLRequest.init(url: url)
        request.httpMethod = type.rawValue
        request.setValue(mimeType.rawValue, forHTTPHeaderField: "Content-Type")

        addHeaderToRequest(&request)

        if let body = body {
            request.httpBody = body
        }

        guard let task = session?.dataTask(with: request) else {
            return nil
        }

        let completion: ((TaskHandlersContainer, Any?, URLResponse?, Error?) -> Void) = { handlers, data, response, error in
            guard let data = data as? URL else {
                completion?(error, nil)
                return
            }

            completion?(nil, data)
        }

        let handler = TaskHandlersContainer.init(url: url.absoluteString)
        handler.returnRedirectedUrl = true
        handler.completion = completion
        tasksHandlers[task] = handler

        task.resume()

        return task
    }

    func connect(type: RestType,
                 url: String,
                 inPathParameters pathParameters: [String: String]? = nil,
                 inBodyParameters bodyParameters: [String: Any]? = nil,
                 completion: ((_ error: Error?, _ data: Data?, _ mimeType: MimeType?) -> Void)?,
                 sendProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil,
                 receiveProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) -> URLSessionTask? {
        var jsonData: Data?
        
        if let bodyParameters = bodyParameters {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch {
                DispatchQueue.main.async {
                    completion?(error, nil, RESTService.MimeType.none)
                }
                return nil
            }
        }
        
        return connect(type: type,
                       url: url,
                       inPathParameters: pathParameters,
                       body: jsonData,
                       mimeType: .json,
                       completion: completion,
                       sendProgress: sendProgress,
                       receiveProgress: receiveProgress)
    }
    
    func connect(type: RestType,
                 url: String,
                 inPathParameters pathParameters: [String: String]? = nil,
                 body: Data? = nil,
                 mimeType: MimeType = .json,
                 completion: ((_ error: Error?, _ data: Data?, _ mimeType: MimeType?) -> Void)?,
                 sendProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil,
                 receiveProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) -> URLSessionTask? {
        guard let url = URL(string: add(toPath: url, parameters: pathParameters)) else {
            DispatchQueue.main.async {
                completion?(self.urlError, nil, RESTService.MimeType.none)
            }
            return nil
        }
        
        let cachePolicy: URLRequest.CachePolicy = urlCacheType == .all ? .returnCacheDataElseLoad : .useProtocolCachePolicy
        
        var request = URLRequest.init(url: url, cachePolicy: cachePolicy)
        request.httpMethod = type.rawValue
        request.setValue(mimeType.rawValue, forHTTPHeaderField: "Content-Type")
        
        addHeaderToRequest(&request)
        
        if let body = body {
            request.httpBody = body
        }

        if let data = session?.configuration.urlCache?.cachedResponse(for: request)?.data {
            completion?(nil, data, nil)
            return nil
        }
        
        guard let task = session?.dataTask(with: request) else {
            return nil
        }

        let completion: ((TaskHandlersContainer, Any?, URLResponse?, Error?) -> Void) = { handlers, data, response, error in
            self.process(task: task, handlers: handlers, data: data as? Data, response: response, error: error, completion: completion)
        }

        let handler = TaskHandlersContainer.init(url: url.absoluteString)
        handler.sendProgress = sendProgress
        handler.receiveProgress = receiveProgress
        handler.completion = completion
        tasksHandlers[task] = handler

        task.resume()

        return task
    }
    
    func connect(url: String,
                 image: UIImage,
                 imageParameterName: String,
                 inPathParameters pathParameters: [String: String]? = nil,
                 inBodyParameters bodyParameters: [String: String]? = nil,
                 completion: ((_ error: Error?, _ data: Data?, _ mimeType: MimeType?) -> Void)?,
                 sendProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil,
                 receiveProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, description: "Image is empty"), nil, RESTService.MimeType.none)
            }
            return
        }
        
        let fileParameters = FileParameters(fileName: "\(UUID().uuidString).jpg", 
                                            fileParameterName: imageParameterName, 
                                            fileMimeType: .jpeg)
        
        let requestParameters = RequestParameters()
        requestParameters.url = url
        requestParameters.pathParameters = pathParameters
        requestParameters.bodyParameters = bodyParameters
        
        let progresses = ProcessProgresses()
        progresses.receiveProgress = receiveProgress
        progresses.sendProgress = sendProgress
        
        connect(requestParameters: requestParameters,
                fileData: imageData,
                fileParameters: fileParameters,
                progresses: progresses,
                completion: completion)
    }
    
    func connect(url: String,
                 jsonObject: Any,
                 jsonPropertyName: String,
                 inPathParameters pathParameters: [String: String]? = nil,
                 inBodyParameters bodyParameters: [String: String]? = nil,
                 completion: ((_ error: Error?, _ data: Data?, _ mimeType: MimeType?) -> Void)?,
                 sendProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil,
                 receiveProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) {
        var jsonData: Data?
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, 
                                                  options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, 
                                               description: "Create json file fail"), 
                            nil, 
                            RESTService.MimeType.none)
            }
            return
        }
        
        guard let data = jsonData else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, 
                                               description: "Create json file fail"), 
                            nil, 
                            RESTService.MimeType.none)
            }
            return
        }
        
        let fileParameters = FileParameters(fileName: "file.json", 
                                            fileParameterName: jsonPropertyName, 
                                            fileMimeType: .json)
        
        let requestParameters = RequestParameters()
        requestParameters.url = url
        requestParameters.pathParameters = pathParameters
        requestParameters.bodyParameters = bodyParameters
        
        let progresses = ProcessProgresses()
        progresses.receiveProgress = receiveProgress
        progresses.sendProgress = sendProgress
        
        connect(requestParameters: requestParameters,
                fileData: data,
                fileParameters: fileParameters,
                progresses: progresses,
                completion: completion)
    }
    
    class ProcessProgresses {
        var sendProgress: ((_ part: Int64?, _ total: Int64?) -> Void)?
        var receiveProgress: ((_ part: Int64?, _ total: Int64?) -> Void)?
    }
    
    class RequestParameters {
        var url: String?
        var pathParameters: [String: String]?
        var bodyParameters: [String: Any]?
    }
    
    class FileParameters {
        var fileName: String
        var fileParameterName: String
        var fileMimeType: MimeType
        
        init(fileName: String, fileParameterName: String, fileMimeType: MimeType) {
            self.fileName = fileName
            self.fileParameterName = fileParameterName
            self.fileMimeType = fileMimeType
        }
    }
    
    func connect(requestParameters: RequestParameters,
                 fileData: Data,
                 fileParameters: FileParameters,
                 progresses: ProcessProgresses,
                 completion: ((_ error: Error?, _ data: Data?, _ mimeType: MimeType?) -> Void)?) {
        guard let path = requestParameters.url, 
              let url = URL(string: add(toPath: path, parameters: requestParameters.pathParameters)) else {
            DispatchQueue.main.async {
                completion?(self.urlError, nil, RESTService.MimeType.none)
            }
            return
        }
        
        var request = createMultipartRequest(url: url,
                                             inBodyParameters: requestParameters.bodyParameters,
                                             fileData: fileData,
                                             fileName: fileParameters.fileName,
                                             fileParameterName: fileParameters.fileParameterName,
                                             fileMimeType: fileParameters.fileMimeType)

        addHeaderToRequest(&request)

        guard let task = session?.dataTask(with: request) else {
            return
        }
        
        let completion: ((TaskHandlersContainer, Any?, URLResponse?, Error?) -> Void) = { handlers, data, response, error in
            self.process(task: task, handlers: handlers, data: data as? Data, response: response, error: error, completion: completion)
        }
        
        let handler = TaskHandlersContainer.init(url: url.absoluteString)
        handler.sendProgress = progresses.sendProgress
        handler.receiveProgress = progresses.receiveProgress
        handler.completion = completion
        tasksHandlers[task] = handler
        
        task.resume()
    }
    
    func connect(url: String,
                 fileLocalUrl: URL,
                 fileParameterName: String,
                 inPathParameters pathParameters: [String: String]? = nil,
                 inBodyParameters bodyParameters: [String: String]? = nil,
                 completion: ((_ error: Error?, _ data: Data?, _ mimeType: MimeType?) -> Void)?,
                 sendProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil,
                 receiveProgress: ((_ part: Int64?, _ total: Int64?) -> Void)? = nil) {
        guard let fileData = try? Data(contentsOf: fileLocalUrl) else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, description: "Retreived file is empty"), nil, RESTService.MimeType.none)
            }
            return
        }
        
        guard let mimeTypeString = self.mimeTypeForPath(path: fileLocalUrl.absoluteString) else { return }
        guard let paramName = self.fileExtension(forMimeType: mimeTypeString) else { return }
        guard let mimeType = MimeType.typeForString(mimeTypeString) else { return }
        
        let fileParameters = FileParameters(fileName: "\(UUID().uuidString).\(paramName)",
                                            fileParameterName: fileParameterName,
                                            fileMimeType: mimeType)
        
        let requestParameters = RequestParameters()
        requestParameters.url = url
        requestParameters.pathParameters = pathParameters
        requestParameters.bodyParameters = bodyParameters
        
        let progresses = ProcessProgresses()
        progresses.receiveProgress = receiveProgress
        progresses.sendProgress = sendProgress
        
        connect(requestParameters: requestParameters,
                fileData: fileData,
                fileParameters: fileParameters,
                progresses: progresses,
                completion: completion)
    }
}

extension RESTService {
    private func addHeaderToRequest(_ request: inout URLRequest) {
        if let additionalFields = additionalHeaderParameters?() {
            for field in additionalFields {
                request.setValue(field.value, forHTTPHeaderField: field.key)
            }
        }
    }
    
    func add(toPath path: String, parameters: [String: String]?) -> String {
        var newPath = path
        
        var editedParameters = parameters ?? [:]
        
        editedParameters = editedParameters.merging(additionalPathParameters?() ?? [:]) { (first, _) in
            first
        }

        for (index, key) in editedParameters.keys.sorted().enumerated() {
            newPath +=  index == 0 ? "?" : "&"
            newPath += key
            newPath += "="
            newPath += editedParameters[key]!
        }

        return newPath
    }

    private func process(task: URLSessionTask,
                         handlers: TaskHandlersContainer,
                         data: Data?,
                         response: URLResponse?,
                         error: Error?,
                         completion: ((Error?, Data?, MimeType?) -> Void)?) {
        checkInternetConnectionReachable()
        
        if let error = error {
            DispatchQueue.main.async {
                completion?(error, data, RESTService.MimeType.none)
            }
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0, 
                                               description: "HTTP request error"), 
                            data, 
                            RESTService.MimeType.none)
            }
            return
        }
        
        let mimeType = MimeType.init(rawValue: httpResponse.mimeType ?? "")
        let statusCode = httpResponse.statusCode
        
        if !(200...299).contains(statusCode) {
            let processError = {
                DispatchQueue.main.async {
                    let url = httpResponse.url?.absoluteString ?? ""
                    let description: String

                    if statusCode == 503 {
                        description = "Server is busy. Please, try again later."
                    } else {
                        description = "Server error \(url)"
                    }

                    let error = self.generateError(code: statusCode, description: description)
                    completion?(error, data, mimeType)
                }
            }

            switch statusCode {
            case 401:
                processAuthorizationError(response: response,
                                          processError: processError,
                                          handlers: handlers,
                                          task: task)
            case 503:
                processServerLoadError(response: response,
                                       processError: processError,
                                       handlers: handlers,
                                       task: task)
            default:
                processError()
            }

            return
        } else {
            if urlCacheType == .all,
               let request = task.currentRequest,
               let response = response,
               let data = data {
                let cachedData = CachedURLResponse(response: response, data: data)
                session?.configuration.urlCache?.storeCachedResponse(cachedData, for: request)
            }
            
            DispatchQueue.main.async {
                completion?(nil, data, mimeType)
            }
            return
        }
    }

    private func process(downloadTask: URLSessionDownloadTask,
                         handlers: TaskHandlersContainer,
                         data: URL?,
                         response: URLResponse?,
                         error: Error?,
                         saveToCache: Bool = false,
                         saveToDisk: Bool = false,
                         completion: ((Error?, URL?, MimeType?) -> Void)?) {
        if let error = error {
            DispatchQueue.main.async {
                completion?(error,
                            nil,
                            RESTService.MimeType.none)
            }
            return
        }

        guard let fileUrl = data else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0,
                                               description: "Saved file path wrong"),
                            nil,
                            RESTService.MimeType.none)
            }
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0,
                                               description: "HTTP request error"),
                            fileUrl,
                            RESTService.MimeType.none)
            }
            return
        }

        guard let url = downloadTask.originalRequest?.url else {
            DispatchQueue.main.async {
                completion?(self.generateError(code: 0,
                                               description: "HTTP URL empty"),
                            fileUrl,
                            RESTService.MimeType.none)
            }
            return
        }

        let mimeType: RESTService.MimeType

        if let byExtensionMimeType = self.mimeTypeForPath(path: url.path) {
            mimeType = RESTService.MimeType.typeForString(byExtensionMimeType) ?? .none
        } else {
            mimeType = RESTService.MimeType.typeForString(httpResponse.mimeType ?? "") ?? .none
        }

        let statusCode = httpResponse.statusCode

        if !(200...299).contains(statusCode) {
            let processError = {
                DispatchQueue.main.async {
                    let url = httpResponse.url?.absoluteString ?? ""
                    let description: String

                    if statusCode == 503 {
                        description = "Server is busy. Please, try again later."
                    } else {
                        description = "Server error \(url)"
                    }

                    let error = self.generateError(code: statusCode, description: description)
                    completion?(error, data, mimeType)
                }
            }

            switch statusCode {
            case 401:
                processAuthorizationError(response: response,
                                          processError: processError,
                                          handlers: handlers,
                                          task: downloadTask)
            case 503:
                processServerLoadError(response: response,
                                       processError: processError,
                                       handlers: handlers,
                                       task: downloadTask)
            default:
                processError()
            }

            return
        } else {
            if saveToDisk {
                self.save(directory: .documentDirectory,
                          fileUrl: fileUrl,
                          remoteUrl: url,
                          mimeType: mimeType.rawValue) { (error, url) in
                    DispatchQueue.main.async {
                        completion?(error, url, mimeType)
                    }
                }
            } else if saveToCache {
                self.save(directory: .cachesDirectory,
                          fileUrl: fileUrl,
                          remoteUrl: url,
                          mimeType: mimeType.rawValue) { (error, url) in
                    DispatchQueue.main.async {
                        completion?(error, url, mimeType)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion?(error, url, mimeType)
                }
            }

            return
        }
    }

    private func processAuthorizationError(response: URLResponse?,
                                           processError: @escaping () -> Void,
                                           handlers: TaskHandlersContainer,
                                           task: URLSessionTask) {
        guard let authoriationRefreshHandler = self.authoriationRefreshHandler else {
            self.authoriationErrorHandler?(response)
            processError()
            return
        }

        authoriationRefreshHandler { success in
            guard success else {
                self.authoriationErrorHandler?(response)
                processError()
                return
            }

            handlers.data = nil

            guard var request = task.originalRequest else {
                processError()
                return
            }

            self.addHeaderToRequest(&request)

            guard let newTask = task is URLSessionDownloadTask ? self.session?.downloadTask(with: request) : self.session?.dataTask(with: request) else {
                processError()
                return
            }

            self.tasksHandlers[newTask] = handlers

            newTask.resume()
        }
    }

    private func processServerLoadError(response: URLResponse?,
                                        processError: @escaping () -> Void,
                                        handlers: TaskHandlersContainer,
                                        task: URLSessionTask) {
        guard handlers.retrieveCount < 5 else {
            processError()
            return
        }

        handlers.data = nil

        handlers.retrieveCount += 1

        guard var request = task.originalRequest else {
            processError()
            return
        }

        self.addHeaderToRequest(&request)

        guard let newTask = task is URLSessionDownloadTask ? self.session?.downloadTask(with: request) : self.session?.dataTask(with: request) else {
            processError()
            return
        }

        self.tasksHandlers[newTask] = handlers

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(handlers.retrieveCount)) { [weak self] in
            guard let self = self,
                  self.tasksHandlers[newTask] != nil else {
                return
            }
            
            newTask.resume()
        }
    }

    private func createMultipartRequest(url: URL,
                                        inBodyParameters bodyParameters: [String: Any]? = nil,
                                        fileData: Data,
                                        fileName: String,
                                        fileParameterName: String,
                                        fileMimeType: MimeType) -> URLRequest {
        let boundary = "Boundary-\(UUID().uuidString)"
        
        let body = constructMultipartBody(boundary: boundary, 
                                          bodyParameters: bodyParameters, 
                                          fileData: fileData, 
                                          fileName: fileName, 
                                          fileParameterName: fileParameterName, 
                                          fileMimeType: fileMimeType)
        
        var request = URLRequest.init(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = RestType.post.rawValue
        request.setValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        return request
    }
    
    private func constructMultipartBody(boundary: String, 
                                        bodyParameters: [String: Any]? = nil,
                                        fileData: Data,
                                        fileName: String,
                                        fileParameterName: String,
                                        fileMimeType: MimeType) -> Data {
        let appendString:(_ data: inout Data, _ string: String) -> Void = { data, string in
            if let stringData = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                data.append(stringData)
            }
        }
        
        var body = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        if let bodyParameters = bodyParameters {
            for (key, value) in bodyParameters {
                
                var parse: ((String, Any) -> ([[String: Any]])) = {key, value in return Array.init()}
                
                parse = { key, value in
                    
                    var items: [[String: Any]] = Array.init()
                    
                    if let dictionary = value as? [String: Any] {
                        for (key2, value2) in dictionary {
                            items += parse(key+"[\(key2)]", value2)
                        }
                    } else if let array = value as? [Any] {
                        for index in 0..<array.count {
                            items += parse(key+"[\(index)]", array[index])
                        }
                    } else {
                        var keyValue: [String: Any] = Dictionary.init()
                        keyValue[key] = value
                        items.append(keyValue)
                    }
                    
                    return items
                    
                }
                
                for item in parse(key, value) {
                    for (key, value) in item {
                        appendString(&body, boundaryPrefix)
                        appendString(&body, "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                        appendString(&body, "\(value)\r\n")
                    }
                }
            }
        }
        
        appendString(&body, boundaryPrefix)
        let contentDisposition = "Content-Disposition: form-data; name=\"\(fileParameterName)\"; filename=\"\(fileName)\"\r\n"
        appendString(&body, contentDisposition)
        appendString(&body, "Content-Type: \(fileMimeType.rawValue)\r\n\r\n")
        body.append(fileData)
        appendString(&body, "\r\n")
        appendString(&body, "--".appending(boundary.appending("--")))
        
        return body
    }
}

extension RESTService: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, 
                    task: URLSessionTask, 
                    didSendBodyData bytesSent: Int64, 
                    totalBytesSent: Int64, 
                    totalBytesExpectedToSend: Int64) {
        sessionThread.sync {
            guard let handlers = tasksHandlers[task] else {
                return
            }

            handlers.sendProgress?(task.countOfBytesSent, task.countOfBytesExpectedToSend)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        sessionThread.sync {
            guard let handlers = tasksHandlers.removeValue(forKey: task) else {
                return
            }

            if task is URLSessionDownloadTask {
                handlers.completion?(handlers, nil, task.response, error)

                tasksHandlers.forEach { (key, value) in
                    guard let originalUrl = task.originalRequest?.url?.absoluteString,
                          value.url == originalUrl else {
                        return
                    }

                    if let handlers = tasksHandlers.removeValue(forKey: key) {
                        handlers.completion?(handlers, nil, task.response, error)
                    }
                }
            } else {
                handlers.completion?(handlers, handlers.data, task.response, error)
            }
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        sessionThread.sync {
            if let handlers = tasksHandlers[task],
               handlers.returnRedirectedUrl {
                _ = tasksHandlers.removeValue(forKey: task)
                handlers.completion?(handlers, request.url, response, nil)
                task.cancel()
            }
        }

        var newRequest: URLRequest = request

        sessionThread.sync {
            if task is URLSessionDownloadTask {
                guard let handlers = tasksHandlers[task] else {
                    return
                }

                if handlers.clearHeaderWhenRedirect {
                    request.allHTTPHeaderFields?.forEach({ item in
                        newRequest.setValue(nil, forHTTPHeaderField: item.key)
                    })
                }
            }
        }

        completionHandler(newRequest)
    }
}

extension RESTService: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, 
                    dataTask: URLSessionDataTask, 
                    didReceive response: URLResponse, 
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        sessionThread.sync {
            guard let handlers = tasksHandlers[dataTask] else {
                return
            }

            if handlers.data == nil {
                handlers.data = Data.init()
            }

            handlers.data?.append(data)

            if let response = dataTask.response {
                handlers.receiveProgress?(Int64(handlers.data?.count ?? 0),
                                          (response.expectedContentLength == -1 ? 0 : response.expectedContentLength))
            }
        }
    }
}

extension RESTService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        sessionThread.sync {
            let finishHandlers: (TaskHandlersContainer) -> Void = { handlers in
                handlers.completion?(handlers, location, downloadTask.response, downloadTask.error)
            }

            if let handlers = tasksHandlers.removeValue(forKey: downloadTask) {
                finishHandlers(handlers)
            }

            tasksHandlers.forEach { (key, value) in
                guard let originalUrl = downloadTask.originalRequest?.url?.absoluteString,
                      value.url == originalUrl else {
                    return
                }

                if let handlers = tasksHandlers.removeValue(forKey: key) {
                    finishHandlers(handlers)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, 
                    downloadTask: URLSessionDownloadTask, 
                    didWriteData bytesWritten: Int64, 
                    totalBytesWritten: Int64, 
                    totalBytesExpectedToWrite: Int64) {
        sessionThread.sync {
            guard let handlers = tasksHandlers[downloadTask] else {
                return
            }

            handlers.receiveProgress?(totalBytesWritten, totalBytesExpectedToWrite)
        }
    }
}

extension RESTService {
    private static var savedUserAgent: String?
    
    var userAgent: String {
        guard RESTService.savedUserAgent == nil else {
            return RESTService.savedUserAgent!
        }
        
        let appName = Bundle.main.bundleIdentifier
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let platform = UIDevice.current.systemName
        let modelName = UIDevice.current.name
        let operationSystemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let networkBundle = Bundle(identifier: "com.apple.CFNetwork")
        let cfNetworkVersion = networkBundle?.infoDictionary?[kCFBundleVersionKey as String] as? String
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.release)
        let darvinVersionString = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8,
                  value != 0 else {
                return identifier
            }
            
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        let userAgent = """
        \(appName ?? "")/
        \(version ?? "").
        \(build!) 
        (\(platform); 
        \(modelName); 
        \(operationSystemVersion)) 
        CFNetwork/\(cfNetworkVersion ?? "") 
        Darvin/\(darvinVersionString)
        """
        
        RESTService.savedUserAgent = userAgent
        
        return userAgent
    }
}

extension URLRequest {    
    mutating func setBasicAuthorizationHeader(username: String, password: String) -> URLRequest {
        let data = "\(username):\(password)".data(using: String.Encoding.utf8)
        
        if let base64 = data?.base64EncodedString(options: []) {
            addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            //            setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        }
        
        return self
    }
}
