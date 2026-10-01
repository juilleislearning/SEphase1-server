import SwiftUI

struct PlanItem: Identifiable {
    let id = UUID()
    let task: String
    let date: Date
    let startTime: Int
    let endTime: Int
    let priority: Int
}

var plans = [
    PlanItem(
        task: "운영체제 과제",
        date: Date(),
        startTime: 20 * 60,
        endTime: 22 * 60 + 10,
        priority: 3
    ),
    PlanItem(
        task: "소프트웨어공학 과제",
        date: Date(),
        startTime: 21 * 60,
        endTime: 22 * 60 + 30,
        priority: 2
    ),
    PlanItem(
        task: "컴퓨터네트워크 복습",
        date: Date(),
        startTime: 19 * 60,
        endTime: 21 * 60 + 55,
        priority: 1
    ),
    PlanItem(
        task: "알고리즘 분석",
        date: Date(),
        startTime: 22 * 60,
        endTime: 23 * 60,
        priority: 3
    ),
    PlanItem(
        task: "머신러닝 공부",
        date: Date(),
        startTime: 23 * 60,
        endTime: 23 * 60 + 50,
        priority: 2
    ),
    PlanItem(
        task: "운동",
        date: Date(),
        startTime: 16 * 60,
        endTime: 19 * 60,
        priority: 1
    )
]

//tbd, collect form db
//automatically sorted

struct ContentView: View {
    @State private var page = 0
    // 0 = main
    // 1 = planning

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                MainView()
                    .tag(0)

                PlanningView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            BottomPageBar(page: $page)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct MainView: View {
    @State private var scrollPosition = ScrollPosition()
    
    var day: String {
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let week = Calendar.current.component(.weekday, from: Date())
        
        let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        
        return "\(month). \(day) \(weekdays[week-1])"
    }
    
    var weekend: Color {
        let week = Calendar.current.component(.weekday, from: Date())
        if week == 1 {
            return Color.red
        }
        else if week == 7 {
            return Color.blue
        }
        return Color.black
    }

    var body: some View {
        VStack(spacing: 12) {

            Text(day)
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(weekend)

            Text("today's plan")
                .foregroundColor(.secondary)

            TimelineView(.periodic(from: .now, by: 60)) { context in
                
                let currentTime =
                    Calendar.current.component(.hour, from: context.date) * 60 +
                    Calendar.current.component(.minute, from: context.date)
                
                let currentList = plans
                    .filter {
                        Calendar.current.isDateInToday($0.date)
                    }
                    .filter {
                        $0.endTime > currentTime
                    }
                    .filter {
                        $0.startTime <= currentTime
                    }

                ScrollView(.vertical, showsIndicators: false) {

                    LazyVStack(spacing: 12) {

                        ForEach(
                            plans
                                .filter {
                                    Calendar.current.isDateInToday($0.date)
                                }
                                .filter {
                                    $0.endTime > currentTime
                                }
                                .sorted {

                                    let remaining1 = $0.endTime - currentTime
                                    let remaining2 = $1.endTime - currentTime

                                    let isUpcoming1 = currentTime < $0.startTime
                                    let isUpcoming2 = currentTime < $1.startTime

                                    // 진행 중인 일정 먼저
                                    if isUpcoming1 != isUpcoming2 {
                                        return !isUpcoming1
                                    }

                                    // 둘 다 예정이면 시작 시간 순
                                    if isUpcoming1 && isUpcoming2 {
                                        return $0.startTime < $1.startTime
                                    }

                                    // 둘 다 진행 중이면 남은 시간 순
                                    if remaining1 != remaining2 {
                                        return remaining1 < remaining2
                                    }

                                    // 남은 시간이 같으면 priority 순
                                    if $0.priority != $1.priority {
                                        return $0.priority > $1.priority
                                    }

                                    return $0.startTime < $1.startTime
                                }
                        ) { plan in

                            TaskCard(
                                Item: plan,
                                currentTime: currentTime
                            )
                            .scrollTransition(.interactive, axis: .vertical) {
                                content, phase in

                                content
                                    .opacity(
                                        phase.isIdentity ? 1.0 : 0.25
                                    )
                                    .scaleEffect(
                                        phase.isIdentity ? 1.0 : 0.82
                                    )
                            }
                            .id(plan.id)
                        }

                        .padding(.horizontal, 24)
                    }
                }
                .frame(height: 258)
                .scrollPosition($scrollPosition)
                // 시계
                AnalogClock(
                    date: context.date,
                    currentList: currentList
                )
            }
            

            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct ClockSector: Shape {
    let startAngle: Double
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(
            x: rect.midX,
            y: rect.midY
        )

        let radius = min(rect.width, rect.height) / 2

        var path = Path()

        path.move(to: center)

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle - 90),
            endAngle: .degrees(endAngle - 90),
            clockwise: false
        )

        path.closeSubpath()

        return path
    }
}

struct AnalogClock: View {

    let date: Date
    let currentList: [PlanItem]

    var body: some View {

        let calendar = Calendar.current

        let hour =
            Double(calendar.component(.hour, from: date) % 12)

        let minute =
            Double(calendar.component(.minute, from: date))

        let hourAngle =
            (hour + minute / 60) * 30

        let minuteAngle =
            minute * 6

        let currentTime =
            calendar.component(.hour, from: date) * 60 +
            calendar.component(.minute, from: date)




        ZStack {

            // 시계판
            Circle()
                .fill(Color(white: 0.98))
            
            ForEach(currentList) { plan in
                let remaining = plan.endTime - currentTime

                if remaining >= 60 {
                    Circle()
                        .fill(Color.black.opacity(0.15))
                } else if remaining > 0 {
                    ClockSector(
                        startAngle: minuteAngle,
                        endAngle: minuteAngle + Double(remaining) * 6
                    )
                    .fill(Color.black.opacity(0.05))
                }
            }

            // 시침
            Rectangle()
                .fill(Color.black)
                .frame(width: 5, height: 80)
                .offset(y: -40)
                .rotationEffect(.degrees(hourAngle))

            // 분침
            Rectangle()
                .fill(Color.black)
                .frame(width: 3, height: 150)
                .offset(y: -75)
                .rotationEffect(.degrees(minuteAngle))


        }
        .frame(width: 300, height: 300)
    }
}

struct PlanningView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("PLANNING")
                .font(.system(size: 42, weight: .bold))

            Text("planning screen is running")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct BottomPageBar: View {
    @Binding var page: Int

    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    page = 0
                }
            } label: {
                VStack(spacing: 8) {
                    
                    Rectangle()
                        .fill(page == 0 ? Color.black : Color.clear)
                        .frame(height: 3)
                    
                    Text("MAIN")
                        .font(.system(size: 16,
                                      weight: page == 0 ? .semibold : .regular))
                        .foregroundColor(page == 0 ? .black : .gray)


                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                withAnimation {
                    page = 1
                }
            } label: {
                VStack(spacing: 8) {
                    Rectangle()
                        .fill(page == 1 ? Color.black : Color.clear)
                        .frame(height: 3)
                    
                    Text("PLANNING")
                        .font(.system(size: 16,
                                      weight: page == 1 ? .semibold : .regular))
                        .foregroundColor(page == 1 ? .black : .gray)


                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(height: 64)
        .background(Color.white)
    }
}
    
    
struct TaskCard: View {
    let Item: PlanItem
    let currentTime: Int
    
    var remainingTime: String {
        if currentTime < Item.startTime {
            let ready = Item.startTime - currentTime
            if ready < 60 {
                return "\(ready % 60)m"
            }
            
            return "\(ready / 60)h \(ready % 60)m"
        }

        let remaining = Item.endTime - currentTime
        
        if remaining < 60 {
            return "\(remaining % 60)m"
        }
        
        return "\(remaining / 60)h \(remaining % 60)m"
    }
    
    var progress_c: Color {
        if currentTime < Item.startTime {
            return Color(white: 0.95)
        }
        else {
            return Color(white: 0.85)
        }
    }

    var body: some View {
        HStack {
            Text(Item.task)
                .font(.system(size: 20))
            Spacer()

            Text(remainingTime)
                .font(.system(size: 20))
            
        }
        .padding(.horizontal, 18)
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(progress_c)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
