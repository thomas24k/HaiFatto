// Hai fatto? — Widget Bundle
import WidgetKit
import SwiftUI

@main
struct HaiFattoWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallWidget()
        MediumWidget()
        LargeWidget()
    }
}
