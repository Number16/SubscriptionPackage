// The Swift Programming Language
// https://docs.swift.org/swift-book

//
//  ContentView.swift
//  Payment
//
//  Created by Alexey Primechaev on 15.06.2023.
//

import SwiftUI
import StoreKit

struct SubscriptionGrid: View {
        
    @State private var totalSize: CGSize = .zero
        
    var subscriptionPoints: [SubscriptionPoint]
        
    var body: some View {
        
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    SubscriptionCard(point: subscriptionPoints[0])
                    SubscriptionCard(point: subscriptionPoints[1])
                        .gridCellColumns(2)
                }
                
                GridRow {
                    SubscriptionCard(point: subscriptionPoints[2])
                        .gridCellColumns(2)
                    SubscriptionCard(point: subscriptionPoints[3])
                    
                }.frame(height: (totalSize.height - 30)/2 + 10)
                
                GridRow {
                    SubscriptionCard(point: subscriptionPoints[4])
                    SubscriptionCard(point: subscriptionPoints[5])
                        .gridCellColumns(2)
                   
                }
                
            }
            .getViewSize($totalSize, onChange: true)
            .padding(.horizontal, 20)
            .padding(.top, 9)
            .frame(maxWidth: 480)
        
            
        
    }
}

struct SubscriptionView: View {
    
    var points: [SubscriptionPoint]
    
    @EnvironmentObject var store: Store
    
    @State var selectedProduct: ProductWrapper = ProductWrapper()
    
    @State var isLoading: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var products: [ProductWrapper] {
        var array = [ProductWrapper]()
        
        for product in store.products {
            array.append(ProductWrapper(product: product))
        }
        return array
    }
    
    var body: some View {
        NavigationStack {
            SubscriptionGrid(subscriptionPoints: points)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                           
                                dismiss()
                            
                        } label: {
                            Label("Back", systemImage: "xmark")
                        }
                        .buttonStyle(.circular)
                            .padding(.leading, 4)
                            .animation(nil)
                    }
                    
                    
                        ToolbarItem(placement: .primaryAction) {
                            

                            
                            Menu {
                                HStack(spacing: 20) {
                                    
                                    Button {
                                        Task {
                                            await store.updateProducts
                                        }
                                    } label: {
                                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                                    }
                                    if let url = URL(string: "https://lekskeks.com/terms2.html") {
                                        Link(destination: url) {
                                            Label("Terms and Conditions", systemImage: "info")
                                            
                                        }
                                        Link(destination: url) {
                                            Label("Privacy Policy", systemImage: "hand.raised")
                                        }
                                    }
                                    
                                    
                                    
                                }
                                
                            } label: {
                                Image(systemName: "ellipsis")
                                
                            }
                            .menuStyle(.circular)
                            .animation(nil)
                            .padding(.trailing, 4)
                            
                            
                        }
                    
                }
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        
                        Menu {
                            Picker(selection: $selectedProduct) {
                                ForEach(products) { product in
                                    Text(product.product?.string ?? "")
                                        .tag(product)
                                }
                                
                            } label: {
                                
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedProduct.product?.string ?? "")
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundStyle(.secondary)
                                
                                
                            }
                            .font(.callout)
                            .fontWeight(.medium)
                            .imageScale(.small)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .animation(nil, value: selectedProduct)
                        }.tint(.primary)
                        
                        
                        
                        
                        
                        HStack(spacing: 10) {
                            Button {
                                isLoading.toggle()
                                if let product = selectedProduct.product {
                                    
                                    Task {
                                        do {
                                            if try await store.purchase(product) != nil {
                                                store.isSubscribed = true
                                                UIApplication.shared.setAlternateIconName("PomodoroIcon") { error in
                                                    if let error = error {
                                                        print("failed icon")
                                                        print(error.localizedDescription)
                                                    }
                                                }
                                                dismiss()
                                            }
                                        } catch Store.StoreError.failedVerification {
                                        } catch {
                                        }
                                        
                                        isLoading = false
                                    }
                                }
                                
                            } label: {
                                
                                Text("Continue")
                                
                                
                            }
                            .buttonStyle(.primary(prominence: .maximum, isLoading: isLoading))
                            .disabled(isLoading)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .frame(maxWidth: 480)
                }
        }
    }
}

struct ProductWrapper: Identifiable, Hashable {
    var product: Product? = nil
    var id: String {
        return product?.id ?? "nil"
    }
}

struct SubscriptionPoint: Identifiable {
    
    enum PointType: Int {
        case singleSymbol, symbols, image, color, blobs
    }
    
    var id: String {
        return title
    }
    
     var title: String = ""
     var SFSymbols: [String] = []
     var SFSymbol: String = ""
     var image: String = ""
     var fullscreenImage: String = ""
    
     var view: some View = EmptyView()
    var type: PointType
    
    var color: Color
    var isGradient: Bool
    var gradient: AnyGradient {
        return color.gradient
    }
    
    /// SF Symbol
    init(_ title: String = "", SFSymbol: String, foregroundColor: Color = Color.accentColor, gradient: Bool = false) {
        self.title = title
        self.SFSymbol = SFSymbol
        self.type = .singleSymbol
        self.color = foregroundColor
        self.isGradient = gradient
        
    }
    
    /// Multiple SF Symbols
    init(_ title: String = "", SFSymbols: [String], foregroundColor: Color = Color.accentColor, gradient: Bool = false) {
        self.title = title
        self.SFSymbols = SFSymbols
        self.type = .symbols
        self.color = foregroundColor
        self.isGradient = gradient
    }
    
    /// Image
    init(_ title: String = "", image: String) {
        self.title = title
        self.image = image
        self.type = .image
        self.color = .primary
        self.isGradient = false
    }
    
    /// SimpleColor
    init(_ title: String = "", color: Color = Color.accentColor, gradient: Bool = false) {
        self.title = title
        self.type = .color
        self.color = color
        self.isGradient = gradient
    }
    
    /// BlobsBackground
    init(_ title: String = "", blobColor: Color) {
        self.title = title
        self.type = .blobs
        self.color = blobColor
        self.isGradient = false
    }
    
    
    
}

struct SubscriptionCard: View {
    
    var point: SubscriptionPoint
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            switch point.type {
            case .singleSymbol:
                VStack(spacing: 12) {
                    Image(systemName: point.SFSymbol)
                        .foregroundStyle(point.color)
                        .font(.largeTitle.bold())
                    if point.title != "" {
                        Text(point.title)
                            .font(.title2.bold())
                    }
                }
            case .symbols:
                VStack(spacing: 12) {
                    ViewThatFits {
                        HStack {
                            ForEach(point.SFSymbols, id: \.self) { symbol in
                                Image(systemName: symbol)
                                    .foregroundStyle(point.color)
                                    .font(.title3.bold())
                            }
                        }
                        VStack(spacing: 8) {
                            ForEach(point.SFSymbols, id: \.self) { symbol in
                                Image(systemName: symbol)
                                    .foregroundStyle(point.color)
                                    .font(.title3.bold())
                            }
                        }
                    }
                    if point.title != "" {
                        Text(point.title)
                            .font(.title2.bold())
                    }
                }
            case .image:
                Image(point.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        Text(point.title)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
            case .color:
                Text(point.title)
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.white)
                    .background(point.color)
            case .blobs:
                Text(point.title)
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.white)
                    .background {
                        BlobBackground(color: point.color, isLoading: false)
                            .controlSize(.large)
                            .overlay {
                                if colorScheme == .dark {
                                    VariableBlurView(gradientMask: UIImage.opaqueMask, maxBlurRadius: 28)
                                } else {
                                    VariableBlurView(gradientMask: UIImage.opaqueMask, maxBlurRadius: 28)
                                }
                            }
                    }
            }
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(point.color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1/UIScreen().scale)
            }
    }
    
    
}

struct GeometryHandlerViewModifier: ViewModifier {
    
    @Binding var size: CGSize
    
    var onChange: Bool
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { geo in
                if onChange {
                    Color.clear
                        .onAppear {
                            size = geo.size
                        }
                        .onChange(of: geo.size) { newGeo in
                            size = newGeo
                        }
                } else {
                    Color.clear
                        .onAppear {
                            size = geo.size
                        }
                }
            }
        }
    }
    
}



extension View {
    func getViewSize(_ size: Binding<CGSize>, onChange: Bool = true) -> some View {
        modifier(GeometryHandlerViewModifier(size: size, onChange: onChange))
    }
}


struct SubscriptionViewModifier: ViewModifier {
    
    @Binding var isSubscribed: Bool
    
    @StateObject private var store: Store = Store.shared
    
    @State private var showingSheet: Bool = false
    
    private var subscriptionPoints: [SubscriptionPoint] = []
    
    init(isSubscribed: Binding<Bool>, products: Set<String>, subscriptionPoints: [SubscriptionPoint]) {
        self._isSubscribed = isSubscribed
        _store = StateObject(wrappedValue: Store(identifiers: products))
        self.subscriptionPoints = subscriptionPoints
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: store.isSubscribed) { newValue in
                isSubscribed = isSubscribed
            }
            .fullScreenCover(isPresented: $showingSheet) {
                SubscriptionView(points: subscriptionPoints)
                    .environmentObject(store)
            }
            .onAppear {
                if !isSubscribed {
                    showingSheet = true
                }
            }
    }
}

extension View {
    
    func subscription(
        isSubscribed: Binding<Bool>,
        products: Set<String>,
        subscriptionPoint0: SubscriptionPoint,
        subscriptionPoint1: SubscriptionPoint,
        subscriptionPoint2: SubscriptionPoint,
        subscriptionPoint3: SubscriptionPoint,
        subscriptionPoint4: SubscriptionPoint,
        subscriptionPoint5: SubscriptionPoint
    ) -> some View {
        modifier(SubscriptionViewModifier(isSubscribed: isSubscribed, products: products, subscriptionPoints: [subscriptionPoint0, subscriptionPoint1, subscriptionPoint2, subscriptionPoint3, subscriptionPoint4, subscriptionPoint5]))
    }
}

class Store: ObservableObject {
    
    static var shared = Store(identifiers: [""])

    @Published var products: [Product] = [Product]()
    @Published var purchasedProducts: [Product] = [Product]()
    
    @Published var isSubscribed: Bool = false
    
    var productsSet: Set<String>

    @MainActor
    func requestProducts() async {
        do {

        
            products = try await Product.products(for: productsSet).sorted { $0.price > $1.price }


        } catch {
        }
    }
    
    

    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        //Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()


        switch result {
            case .success(let verification):
                //Check whether the transaction is verified. If it isn't,
                //this function rethrows the verification error.
                let transaction = try checkVerified(verification)

                let priceDouble = NSDecimalNumber(decimal: product.price).doubleValue
                let currencyCode = product.priceFormatStyle.currencyCode

                

                print("purchased", priceDouble, currencyCode)

                


                await transaction.finish()

                return transaction
            case .userCancelled, .pending:
                return nil
            default:
                return nil
        }
    }
    
   
    
    func isPurchased(_ product: Product) async throws -> Bool {
        //Determine whether the user purchases a given product.
        
        return purchasedProducts.contains(product)
        
    }
    
    @MainActor
    func updateProducts() async {
        var purchasedProducts: [Product] = []
        
        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                //Check the `productType` of the transaction and get the corresponding product from the store.
                if let product = products.first(where: { $0.id == transaction.productID }) {
                    purchasedProducts.append(product)
                }
            } catch {
            }
        }
        
        //Update the store information with the purchased products.
        self.purchasedProducts = purchasedProducts
        
        
        
        
        if !self.purchasedProducts.isEmpty {
            
            
            
            
            var nonExpiredSubscriptionExists = false
            
            for product in self.purchasedProducts {
                
                
                
                guard let statuses = try? await product.subscription?.status else {
                    return
                }
                //                let status = try? await product.subscription?.status.first?.state
                
                
                for status in statuses {
                    if status.state != .expired && status.state != .revoked {
                        nonExpiredSubscriptionExists = true
                    }
                }
                
                //                print("status ")
                //                print(status == .subscribed)
                
                //                if status == .expired || status == .revoked {
                //                    nonExpiredSubscriptionExists = false
                //                }
            }
            
            
            isSubscribed = nonExpiredSubscriptionExists
            
            if isSubscribed {
                if UIApplication.shared.alternateIconName != "PomodoroIcon" {
                    UIApplication.shared.setAlternateIconName("PomodoroIcon") { error in
                        if let error = error {
                            print("failed icon")
                            //print(error.localizedDescription)
                        }
                    }
                }
            }
            
            
            
        } else {
            isSubscribed = false
        }
        
        
      
        
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
            case .unverified:
                //StoreKit parses the JWS, but it fails verification.
                throw StoreError.failedVerification
            case .verified(let safe):
                //The result is verified. Return the unwrapped value.
                return safe
        }
    }

    public enum StoreError: Error {
        case failedVerification
    }
    
    init(identifiers: Set<String>) {
        self.productsSet = identifiers
        Task {
            await requestProducts()
        }
    }

    
    
   
    

}

public extension Animation {
    internal static var returnAnimation: Animation = .interpolatingSpring(mass: 0.45, stiffness: 185, damping: 15, initialVelocity: 15)
    internal static var AIAnimation: Animation = .interpolatingSpring(mass: 0.55, stiffness: 195, damping: 15, initialVelocity: 0)
    internal static var textAnimation: Animation = .interpolatingSpring(mass: 0.25, stiffness: 225, damping: 20, initialVelocity: 10)
}

struct PrimaryButtonStyle: ButtonStyle {
    @State var isHovering = false
    
    enum Prominence {
        case normal, increased, maximum
    }
    var prominence: Prominence = .normal
    
    var isLoading = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if !isLoading {
                configuration.label
                    .transition(.opacity)
            } else {
                ProgressView()
                    .tint(.white)
                    .transition(.opacity)
            }
        }
            .frame(maxWidth: .infinity)
            .labelStyle(.titleAndIcon)
            .imageScale(.medium)
            .font(.headline)
            .symbolVariant(.fill)
            .foregroundStyle(configuration.role == .destructive ? .red : prominence == .maximum ? .white : .accentColor)
            .blendMode(prominence == .maximum ? .normal : .normal)
            .padding(8)
            .padding(.vertical, 6)
            .frame(height: 56)
            
            .background {
                switch prominence {
                case .normal:
                    Color.secondaryBackground.brightness(isHovering ? -0.05 : 0)
                case .increased:
                    Rectangle().fill(.background).brightness(isHovering ? -0.05 : 0)
                case .maximum:
                    Rectangle().fill(.tint).opacity(isHovering ? 0.85 : 1)
                }
                
                
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .onHover { hovering in
                isHovering = hovering
            }
            .onChange(of: configuration.isPressed) { newValue in
                if newValue {
                    softHaptic()
                } else {
                    regularHaptic()
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isHovering)
    }
}


extension Product {
    
    var introString: String {
       
            if let string = subscription?.introductoryOffer?.period.debugDescription {
                return string + " Free"
            } else {
                return ""
            }
        
    }
    
    var priceString: String {
        let periodString: String = {
            if subscription?.subscriptionPeriod.unit == .year {
                return "/year".lowercased()
            } else if subscription?.subscriptionPeriod.unit == .month {
                return "/month".lowercased()
            } else {
                return ""
            }
        }()
        return displayPrice + periodString
    }
    
    var string: String {
        
        let introString: String = {
            if let string = subscription?.introductoryOffer?.period.debugDescription {
                return string + " Free, then "
            } else {
                return ""
            }
        }()
        
        let periodString: String = {
            if subscription?.subscriptionPeriod.unit == .year {
                return "/year".lowercased()
            } else if subscription?.subscriptionPeriod.unit == .month {
                return "/month".lowercased()
            } else {
                return ""
            }
        }()
        return introString + displayPrice + periodString
    }
}


#if os(iOS)
public func regularHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .rigid)
    generator.impactOccurred()
}

public func mediumHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}

public func hardHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()
}

public func lightHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}

public func softHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .soft)
    generator.impactOccurred()
}

public func successHaptic() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}
#else
public func regularHaptic() {
   
}

public func mediumHaptic() {
    
}

public func hardHaptic() {
   
}

public func lightHaptic() {
   
}

public func softHaptic() {
    
}
#endif

extension View where Self == Color {
#if os(macOS)
    internal static var secondaryBackground: Color {
        return Color(NSColor.systemPurple)
    }
    internal static var tertiaryBackground: Color {
        return Color(NSColor.controlColor)
    }
#else
    internal static var secondaryBackground: Color {
        return Color(.secondarySystemBackground)
    }
    internal static var tertiaryBackground: Color {
        return Color(.tertiarySystemBackground)
    }
#endif
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    internal static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
    
    internal static func primary(prominence: PrimaryButtonStyle.Prominence, isLoading: Bool) -> PrimaryButtonStyle {
        PrimaryButtonStyle(prominence: prominence, isLoading: isLoading)
    }
}

struct CircularButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .foregroundStyle(.secondary)
            .foregroundStyle(.tint)
            .frame(width: 28, height: 28)
            .imageScale(.small)
            .background(Color.secondaryBackground, in: Circle())
            .contentShape(.hoverEffect, Circle())
            .hoverEffect(.highlight)
    }
}

extension ButtonStyle where Self == CircularButtonStyle {
    internal static var circular: CircularButtonStyle {
        CircularButtonStyle()
    }
}

struct CircularMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .labelStyle(.iconOnly)
            .foregroundStyle(.secondary)
            .foregroundStyle(.tint)
            .frame(width: 28, height: 28)
            .imageScale(.small)
            .background(Color.secondaryBackground, in: Circle())
            .contentShape(.hoverEffect, Circle())
            .hoverEffect(.highlight)
    }
}

extension MenuStyle where Self == CircularMenuStyle {
    internal static var circular: CircularMenuStyle {
        CircularMenuStyle()
    }
}

//
//  VariableBlurView.swift
//  VariableBlurView
//
//  Created by A. Zheng (github.com/aheze) on 5/29/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//
//  ---
//
//  This work is based off VariableBlurView by Janum Trivedi.
//  Original repository: https://github.com/jtrivedi/VariableBlurView
//  Original license:
//
//  Copyright (c) 2012-2023 Scott Chacon and others
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI

/// A variable blur view.
public class VariableBlurUIView: UIVisualEffectView {
    public init(
        gradientMask: UIImage,
        maxBlurRadius: CGFloat = 20,
        filterType: String = "variableBlur"
    ) {
        super.init(effect: UIBlurEffect(style: .regular))

        /// This is a private QuartzCore class, encoded in base64.
        ///
        ///             CAFilter
        let filterClassStringEncoded = "Q0FGaWx0ZXI="

        let filterClassString: String = {
            if
                let data = Data(base64Encoded: filterClassStringEncoded),
                let string = String(data: data, encoding: .utf8)
            {
                return string
            }

            print("[VariableBlurView] couldn't decode the filter class string.")
            return ""
        }()

        /// This is the magic class method that we want to invoke, encoded in base64.
        ///
        ///       filterWithType:"
        let filterWithTypeStringEncoded = "ZmlsdGVyV2l0aFR5cGU6"

        /// Decode the base64.
        let filterWithTypeString: String = {
            if
                let data = Data(base64Encoded: filterWithTypeStringEncoded),
                let string = String(data: data, encoding: .utf8)
            {
                return string
            }

            print("[VariableBlurView] couldn't decode the filter method string.")
            return ""
        }()

        /// Create the selector.
        let filterWithTypeSelector = Selector(filterWithTypeString)

        /// Create the class object.
        guard let filterClass = NSClassFromString(filterClassString) as AnyObject as? NSObjectProtocol else {
            print("[VariableBlurView] couldn't create CAFilter class.")
            return
        }

        /// Make sure the filter class responds to the selector.
        guard filterClass.responds(to: filterWithTypeSelector) else {
            print("[VariableBlurView] Doesn't respond to selector \(filterWithTypeSelector)")
            return
        }

        /// Create the blur effect.
        let variableBlur = filterClass
            .perform(filterWithTypeSelector, with: filterType)
            .takeUnretainedValue()

        guard let variableBlur = variableBlur as? NSObject else {
            print("[VariableBlurView] Couldn't cast the blur filter.")
            return
        }

        /// The blur radius at each pixel depends on the alpha value of the corresponding pixel in the gradient mask.
        /// An alpha of 1 results in the max blur radius, while an alpha of 0 is completely unblurred.
        guard let gradientImageRef = gradientMask.cgImage else {
            fatalError("Could not decode gradient image")
        }

        variableBlur.setValue(maxBlurRadius, forKey: "inputRadius")
        variableBlur.setValue(gradientImageRef, forKey: "inputMaskImage")
        variableBlur.setValue(true, forKey: "inputNormalizeEdges")

        /// Get rid of the visual effect view's dimming/tint view, so we don't see a hard line.
        ///
        if subviews.indices.contains(1) {
            let tintOverlayView = subviews[1]
            tintOverlayView.alpha = 0
        }

        /// We use a `UIVisualEffectView` here purely to get access to its `CABackdropLayer`,
        /// which is able to apply various, real-time CAFilters onto the views underneath.
        let backdropLayer = subviews.first?.layer

        /// Replace the standard filters (i.e. `gaussianBlur`, `colorSaturate`, etc.) with only the variableBlur.
        backdropLayer?.filters = [variableBlur]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImage {
    func flipVertically() -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            
            // Flip the context vertically
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            
            // Draw the image
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            context.draw(self.cgImage!, in: rect)
            
            let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return flippedImage
        }
}

/// A variable blur view.
public struct VariableBlurView: UIViewRepresentable {
    public var gradientMask: UIImage
    public var maxBlurRadius: CGFloat
    public var filterType: String

    /// A variable blur view.
    public init(
        gradientMask: UIImage = VariableBlurViewConstants.defaultGradientMask,
        maxBlurRadius: CGFloat = 20,
        filterType: String = "variableBlur"
    ) {
        self.gradientMask = gradientMask
        self.maxBlurRadius = maxBlurRadius
        self.filterType = filterType
    }

    public func makeUIView(context: Context) -> VariableBlurUIView {
        let view = VariableBlurUIView(
            gradientMask: gradientMask,
            maxBlurRadius: maxBlurRadius,
            filterType: filterType
        )
        return view
    }

    public func updateUIView(_ uiView: VariableBlurUIView, context: Context) {}
}

public enum VariableBlurViewConstants {

    /// A gradient mask image (top is opaque, bottom is clear). The gradient includes easing.
    public static var defaultGradientMask: UIImage = {
        if
            let data = Data(base64Encoded: defaultMaskImageString, options: .ignoreUnknownCharacters),
            let image = UIImage(data: data)
        {
            return image
        } else {
            print("[VariableBlurView] Couldn't create the gradient mask image.")
            return UIImage(systemName: "xmark")!
        }
    }()

    /// The image encoded in base64 (from PNG data).
    public static let defaultMaskImageString = """
    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
    """
}


//
//  BlobBackground.swift
//  TimePiece
//
//  Created by Alexey Primechaev on 29.05.2023.
//

import SwiftUI

func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

extension Color {
    func secondaryColor() -> Color {
        switch self {
        case .red:
            return .orange
        case .orange:
            return .yellow
        case .yellow:
            return .orange.opacity(0.6)
        case .green:
            return .cyan
        case .blue:
            return .mint
        case .purple:
            return .indigo
        case .brown:
            return .brown.opacity(0.8)
        case .gray:
            return .black
        default:
            return .black
        }
    }
    func tertiaryColor() -> Color {
        switch self {
        case .red:
            return .yellow
        case .orange:
            return .red
        case .yellow:
            return .red
        case .green:
            return .blue
        case .blue:
            return .mint
        case .purple:
            return .pink
        case .brown:
            return .orange.opacity(0.6)
        case .gray:
            return .black.opacity(0.6)
        default:
            return .black
        }
    }
    func quaternaryColor() -> Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .brown:
            return .brown
        case .gray:
            return .gray
        default:
            return .black
        }
    }
}

class CircleBlobsManager: ObservableObject {
    var circleBlobs: [CircleBlob]

    @Published var color: Color {
        didSet {
            self.reinitializeBlobs()
        }
    }

    init(color: Color) {
        self.color = color
        self.circleBlobs = []
        self.reinitializeBlobs()
    }

    func reinitializeBlobs() {
        var blobs: [CircleBlob] = []
        let dominantColorCount = 7
        let secondaryColorCount = 4
        let tertiaryColorCount = 3

        let quaternaryColorCount = 1
        for _ in 0..<dominantColorCount {
            blobs.append(CircleBlob(initialPosition: CircleBlob.randomInitialPosition(), direction: CircleBlob.randomDirection(), style: color, sizeRatio: Double.random(in: 0.9...1.2)))
        }
        for _ in 0..<secondaryColorCount {
            blobs.append(CircleBlob(initialPosition: CircleBlob.randomInitialPosition(), direction: CircleBlob.randomDirection(), style: color.secondaryColor(), sizeRatio: Double.random(in: 0.4...0.8)))
        }
        blobs.shuffle()
        for _ in 0..<tertiaryColorCount {
            blobs.append(CircleBlob(initialPosition: CircleBlob.randomInitialPosition(), direction: CircleBlob.randomDirection(), style: color.tertiaryColor(), sizeRatio: Double.random(in: 0.25...0.4)))
        }
        for _ in 0..<quaternaryColorCount {
            blobs.append(CircleBlob(initialPosition: CircleBlob.randomInitialPosition(), direction: CircleBlob.randomDirection(), style: color.quaternaryColor(), sizeRatio: Double.random(in: 0.05...0.15)))
        }
        self.circleBlobs = blobs
    }

    static var shared = CircleBlobsManager(color: .purple)
}


struct CircleBlob: Identifiable {
    let id = UUID()
    var position: CGPoint = .zero
    var initialPosition: CGPoint
    var direction: CGPoint
    var style: (any ShapeStyle)?
    var opacity: CGFloat = 1.0
    var sizeRatio: CGFloat  // This is now a ratio of the canvas size
    var size: CGSize = CGSize.zero // This will store the actual size, which is calculated in the canvas
    var elapsedTime: TimeInterval = 0.0

      
    static func randomInitialPosition() -> CGPoint {
        let x = CGFloat.random(in: 0.0..<1.0)
        let y = CGFloat.random(in: 0.0..<1.0)
        return CGPoint(x: x, y: y)
    }
        
        static func randomDirection() -> CGPoint {
            let angle = CGFloat.random(in: 0..<2 * .pi)
            let dx = cos(angle)
            let dy = sin(angle)
            return CGPoint(x: dx, y: dy)
        }
    }


extension UIImage {
    static var opaqueMask: UIImage = {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(CGColor(gray: 1, alpha: 1))
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img {
            return img
        } else {
            return UIImage(systemName: "xmark")!
        }
    }()
}


struct BlobBackground: View {
    
    @State private var initialDate = Date()
    
    @StateObject var blobsManager: CircleBlobsManager
    
    var isLoading: Bool
    
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controlSize) var controlSize
    
    var padding: CGFloat = 0
    var color: Color
        
    init(color: Color, padding: CGFloat = 0, isLoading: Bool = false) {
        _blobsManager = StateObject(wrappedValue: CircleBlobsManager(color: color))
        self.padding = padding
        self.isLoading = isLoading
        self.color = color
    }
        
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas(opaque: true, rendersAsynchronously: true) { context, contextSize in
                
                let size = CGSize(width: contextSize.width - padding*2, height: contextSize.height - padding*2)
                let origin = CGPoint(x: padding, y: padding)
                let elapsedTime = timeline.date.timeIntervalSince(initialDate)
                context.fill(Path(CGRect(origin: .zero, size: contextSize)), with: .color(color))
                blobsManager.circleBlobs = moveCircleBlobs(elapsedTime: elapsedTime, canvasSize: size, circleBlobs: blobsManager.circleBlobs)
                
                                
                
                
//                    context.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: size.height)), with: .color(.purple.opacity(0.2)))

                if colorScheme == .light {
                    context.addFilter(.brightness(0.15))
                }
               
                let smallestSide = min(contextSize.width, contextSize.height)
                
                
              
                    
                    context.drawLayer { bluredContext in
                       
                        if controlSize == .large {
                            bluredContext.addFilter(.blur(radius: 24))
                        } else if controlSize == .regular {
                            bluredContext.addFilter(.blur(radius: 18))
                        } else {
                            bluredContext.addFilter(.blur(radius: 10))
                        }
                        
                        for circleBlob in blobsManager.circleBlobs {
                            let path = Path { path in
                                path.addEllipse(in: CGRect(origin: CGPoint(x: padding + circleBlob.position.x * size.width, y: padding + circleBlob.position.y * size.height), size: isLoading ? circleBlob.size * 1.2 : circleBlob.size))
                            }
                            if let style = circleBlob.style {
                                bluredContext.drawLayer { blobContext in
                                    blobContext.opacity = circleBlob.opacity
                                    blobContext.stroke(path, with: .style(style))
                                    blobContext.fill(path, with: .style(style))
                                }
                               
                            }
                        }
                        
                        
                        
                    }
                
                    
                }
            
            }
        .onChange(of: color) { newValue in
            blobsManager.color = newValue
        }
        
        }
        
        
        
    
    //let actualSize = CGSize(width: canvasSize.width * circleBlob.sizeRatio, height: canvasSize.width * circleBlob.sizeRatio)

        
    private func moveCircleBlobs(elapsedTime: TimeInterval, canvasSize: CGSize, circleBlobs: [CircleBlob]) -> [CircleBlob] {
        let movementFactor: CGFloat
        
        if controlSize == .large {
            movementFactor = isLoading ? 0.01 : 0.002
        } else if controlSize == .regular {
            movementFactor = isLoading ? 0.01 : 0.002
        } else {
            movementFactor = isLoading ? 0.10  : 0.01
        }

        var updatedCircleBlobs: [CircleBlob] = []

        for var circleBlob in circleBlobs {
            let deltaTime = elapsedTime - circleBlob.elapsedTime
            let dx = circleBlob.direction.x * CGFloat(deltaTime) * movementFactor
            let dy = circleBlob.direction.y * CGFloat(deltaTime) * movementFactor
            var newPosition = CGPoint(x: circleBlob.position.x + dx, y: circleBlob.position.y + dy)
            
            let addedFactor: CGFloat = controlSize == .large ? 1 : 1.2
            // Calculate the actual size of each blob based on the canvas size
            let biggestSide: CGFloat = canvasSize.height > canvasSize.width ? canvasSize.height : canvasSize.width
            let actualSize = CGSize(width: biggestSide * circleBlob.sizeRatio, height: biggestSide * circleBlob.sizeRatio)

            // Extend the bounds by 15 percent
            let boundsExtension = padding == 0 ? CGFloat(0.5) : CGFloat(0.1)

            if newPosition.x < -boundsExtension || newPosition.x + circleBlob.sizeRatio > 1 + boundsExtension {
                newPosition.x = max(min(newPosition.x, 1 + boundsExtension - circleBlob.sizeRatio), -boundsExtension)
                circleBlob.direction.x *= -1
                circleBlob.elapsedTime = elapsedTime
            }

            if newPosition.y < -boundsExtension || newPosition.y + circleBlob.sizeRatio > 1 + boundsExtension {
                newPosition.y = max(min(newPosition.y, 1 + boundsExtension - circleBlob.sizeRatio), -boundsExtension)
                circleBlob.direction.y *= -1
                circleBlob.elapsedTime = elapsedTime
            }

            circleBlob.position = newPosition
            circleBlob.size = actualSize
            
           
            updatedCircleBlobs.append(circleBlob)
        }
        return updatedCircleBlobs
    }






    
    

}

