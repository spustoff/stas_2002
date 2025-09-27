//
//  Dasg.swift
//  stas_2002
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

enum AppConstLocal {
    static let endpointBase   = "https://wallen-eatery.space/ios-dfm-1/server.php"
    static let accessCodeP    = "Bs2675kDjkb5Ga"
    
    
    
    static let expectedToken  = "GJDFHDFHFDJGSDAGKGHK"
    static let savedLinkKey   = "silka"
    static let aboutBlank     = "about:blank"
}

// Аппаратный идентификатор модели (например, "iPhone15,2")
func hardwareModelIdentifier() -> String {
    var sysinfo = utsname()
    uname(&sysinfo)
    let mirror = Mirror(reflecting: sysinfo.machine)
    let id = mirror.children.reduce(into: "") { s, e in
        guard let v = e.value as? Int8, v != 0 else { return }
        s.append(String(UnicodeScalar(UInt8(v))))
    }
    return id.isEmpty ? UIDevice.current.model : id
}

// Формирование URL запроса к серверу по ТЗ
func buildServerURL() -> URL? {
    let osVersion = UIDevice.current.systemVersion
    let osString = "\(UIDevice.current.systemName) \(osVersion)"
    let lang = Locale.preferredLanguages.first ?? "en"
    let model = hardwareModelIdentifier()
    let country = Locale.current.regionCode ?? ""

    var components = URLComponents(string: AppConstLocal.endpointBase)
    var items: [URLQueryItem] = []
    items.append(URLQueryItem(name: "p", value: AppConstLocal.accessCodeP))
    items.append(URLQueryItem(name: "os", value: osString))
    items.append(URLQueryItem(name: "lng", value: lang))
    items.append(URLQueryItem(name: "devicemodel", value: model))
    if !country.isEmpty {
        items.append(URLQueryItem(name: "country", value: country))
    }
//    items.append(URLQueryItem(name: "test", value: "Y"))
    components?.queryItems = items
    return components?.url
}

// Разбор "TOKEN#URL"
func parseTokenLink(_ text: String) -> (token: String, link: String)? {
    guard let r = text.range(of: "#") else { return nil }
    let token = String(text[..<r.lowerBound])
    let link  = String(text[r.upperBound...])
    guard !token.isEmpty, !link.isEmpty else { return nil }
    return (token, link)
}
