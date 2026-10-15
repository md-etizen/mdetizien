import SwiftUI

@main
struct BillBubblesApp: App {
    @StateObject private var store = BillStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
