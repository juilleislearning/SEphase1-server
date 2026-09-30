import SwiftUI

let colors: [Color] = [
    Color.gray.opacity(0.15),
    Color.white
]

func bool_to_int(_ value : Bool) -> Int {
    if value {
        return 0
    }
    return 1
}

struct ContentView: View {
    @State private var isMainScreen = true

    var body: some View {
        VStack(spacing: 0) {
            if isMainScreen {
                Text("main")
                    .font(.largeTitle)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
            } else {
                Text("add plan")
                    .font(.largeTitle)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
            }

            HStack(spacing: 0) {
                Button("main") {
                    isMainScreen = true
                }
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(colors[bool_to_int(isMainScreen)])
                Divider()

                Button("add plan") {
                    isMainScreen = false
                }
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(colors[bool_to_int(!isMainScreen)])
                
            }
            .background(Color.white)
        }
    }
}

#Preview {
    ContentView()
}
