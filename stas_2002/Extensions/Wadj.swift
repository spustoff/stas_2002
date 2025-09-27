//
//  Wadj.swift
//  stas_2002
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI
import WebKit

// Локальные константы только для этого файла
private enum WConst {
    static let savedLinkKey = "silka"
    static let aboutBlank   = "about:blank"
}

struct WebSystem: View {
    var body: some View {
        ZStack {
            Color.white // нативная белая часть по ТЗ
            WControllerRepresentable()
        }
        .ignoresSafeArea(.all, edges: .all)
        .statusBar(hidden: true) // ← скрывает статус-бар в SwiftUI-хостинге
    }
}

#Preview {
    WebSystem()
}

final class WController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    // Ссылка, сохранённая после успешного ответа сервера (RootGateView)
    @AppStorage(WConst.savedLinkKey) private var silka: String = ""

    // Технические поля
    private var webView = WKWebView()
    private var loadCheckTimer: Timer?
    private var isPageLoadedSuccessfully = false

    // Гарантируем скрытие и со стороны UIKit-контроллера
    override var prefersStatusBarHidden: Bool { true }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        loadFromStorageIfAvailable()
    }

    // Только загрузка сохранённой ссылки, никаких сетевых запросов
    private func loadFromStorageIfAvailable() {
        guard !silka.isEmpty,
              silka != WConst.aboutBlank,
              let url = URL(string: silka) else {
            // Ссылка ещё не сохранена — остаёмся на белом экране
            return
        }
        load(url: url)
    }

    private func setupWebView() {
        webView = WKWebView(frame: .zero, configuration: {
            let c = WKWebViewConfiguration()
            c.websiteDataStore = .default()
            return c
        }())
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        // (опционально) кастомный UA
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile"

        // Настройки скролла/индикаторов
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Восстановим cookies перед первой загрузкой
        loadCookie()
    }

    private func load(url: URL) {
        var req = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        // Пробрасываем cookies в заголовки
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        for (k, v) in headers { req.setValue(v, forHTTPHeaderField: k) }
        webView.load(req)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        completionHandler(nil)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        loadCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            if let strongSelf = self, !strongSelf.isPageLoadedSuccessfully {
                #if DEBUG
                print("Страница не загрузилась в течение 5 секунд.")
                #endif
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isPageLoadedSuccessfully = true
        loadCheckTimer?.invalidate()

        // При успешной навигации обновляем сохранённую ссылку
        if let currentURL = webView.url?.absoluteString, currentURL != WConst.aboutBlank {
            silka = currentURL
        }
        saveCookie()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
    }

    // MARK: - Cookies persist

    private func saveCookie() {
        let cookieJar = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: "cookie")
            } catch {
                #if DEBUG
                print("Cookie save error: \(error.localizedDescription)")
                #endif
            }
        }
    }

    private func loadCookie() {
        let ud = UserDefaults.standard
        if let data = ud.object(forKey: "cookie") as? Data {
            do {
                if let cookies = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookie] {
                    for cookie in cookies {
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                }
            } catch {
                #if DEBUG
                print("Cookie load error: \(error.localizedDescription)")
                #endif
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

struct WControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = WController
    func makeUIViewController(context: Context) -> WController { WController() }
    func updateUIViewController(_ uiViewController: WController, context: Context) {}
}
