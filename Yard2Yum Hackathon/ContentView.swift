// ContentView.swift
// Yard2Yum Hackathon

import SwiftUI
import PhotosUI

extension Color {
    static let y2yBackground = Color(red: 0/255,  green: 77/255, blue: 61/255)
    static let y2yCard       = Color(red: 4/255,  green: 46/255, blue: 37/255)
    static let y2yAccent     = Color(red: 0.48,   green: 0.88,   blue: 0.62)
    static let y2yTan        = Color(red: 0.97,   green: 0.95,   blue: 0.90)
    static let y2ySubtext    = Color(red: 0.72,   green: 0.88,   blue: 0.80)
}


enum UserType: String, CaseIterable {
    case restaurant        = "Restaurant"
    case farm              = "Farm"
    case compostingFacility = "Composting Facility"

    var icon: String {
        switch self {
        case .restaurant:         return "fork.knife"
        case .farm:               return "leaf.fill"
        case .compostingFacility: return "arrow.3.trianglepath"
        }
    }

    var accentColor: Color {
        switch self {
        case .restaurant:         return Color(red: 0.95, green: 0.58, blue: 0.35)
        case .farm:               return Color.y2yAccent
        case .compostingFacility: return Color(red: 0.78, green: 0.65, blue: 0.38)
        }
    }
}

struct PickupRequest: Identifiable {
    let id = UUID()
    var restaurantName: String
    var date: Date
    var pounds: Double
    var location: String
}

struct CompostListing: Identifiable {
    let id = UUID()
    var facilityName: String
    var pricePerPound: Double
    var availablePounds: Double
}

class AppState: ObservableObject {
    @Published var isLoggedIn      = false
    @Published var showOnboarding  = false
    @Published var username        = ""
    @Published var email           = ""
    @Published var selectedUserType: UserType? = nil

    @Published var restaurantName  = ""
    @Published var restaurantType  = ""
    @Published var restaurantImage: UIImage? = nil
    @Published var pickupDate      = Date()
    @Published var pickupPounds: Double = 0

    @Published var farmName        = ""
    @Published var farmLocation    = ""
    @Published var farmImage: UIImage? = nil

    @Published var facilityName    = ""
    @Published var marketplaceListings: [CompostListing] = [
        CompostListing(facilityName: "Green Earth Compost", pricePerPound: 0.45, availablePounds: 500),
        CompostListing(facilityName: "Urban Cycle",         pricePerPound: 0.38, availablePounds: 300)
    ]
    @Published var pickupRequests: [PickupRequest] = [
        PickupRequest(restaurantName: "The Green Table",  date: Date(),                           pounds: 50, location: "123 Main St"),
        PickupRequest(restaurantName: "Harvest Kitchen",  date: Date().addingTimeInterval(86400), pounds: 75, location: "456 Oak Ave")
    ]
}

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        ZStack {
            if appState.isLoggedIn {
                if appState.showOnboarding {
                    OnboardingView { withAnimation(.easeInOut(duration: 0.4)) { appState.showOnboarding = false } }
                        .transition(.opacity)
                } else {
                    mainFlow.transition(.opacity)
                }
            } else {
                LoginView().environmentObject(appState).transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.isLoggedIn)
        .animation(.easeInOut(duration: 0.4), value: appState.showOnboarding)
    }

    @ViewBuilder var mainFlow: some View {
        switch appState.selectedUserType {
        case .restaurant:         RestaurantFlowView().environmentObject(appState)
        case .farm:               FarmFlowView().environmentObject(appState)
        case .compostingFacility: CompostFacilityFlowView().environmentObject(appState)
        case .none:               LoginView().environmentObject(appState)
        }
    }
}

struct OnboardingSlide {
    let icon: String
    let title: String
    let caption: String
}

private let slides: [OnboardingSlide] = [
    OnboardingSlide(
        icon: "leaf",
        title: "Welcome to Yard2Yum",
        caption: "Your sustainability journey starts here.\nLet's turn food waste into something truly beautiful."
    ),
    OnboardingSlide(
        icon: "arrow.3.trianglepath",
        title: "How It Works",
        caption: "Restaurants send food waste to composting facilities.\nFacilities process it and sell rich compost to farms — at a fraction of retail cost."
    ),
    OnboardingSlide(
        icon: "star",
        title: "Everyone Wins",
        caption: "A Win-Win-Win for all.\nRestaurants reduce waste. Facilities earn revenue.\nFarms grow more with less."
    )
]

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var currentSlide = 0

    var body: some View {
        ZStack {
            Color.y2yBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Yard2YumHeader()
                    .padding(.top, 26)
                    .padding(.bottom, 14)

                TabView(selection: $currentSlide) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { idx, slide in
                        OnboardingSlideView(slide: slide).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Dot indicators
                HStack(spacing: 10) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentSlide ? Color.y2yAccent : Color.y2ySubtext.opacity(0.35))
                            .frame(width: i == currentSlide ? 26 : 8, height: 8)
                            .animation(.spring(response: 0.4), value: currentSlide)
                    }
                }
                .padding(.bottom, 30)

                Button {
                    if currentSlide < slides.count - 1 {
                        withAnimation(.spring(response: 0.45)) { currentSlide += 1 }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(currentSlide < slides.count - 1 ? "Next" : "Get Started →")
                        .font(Font.custom("Georgia-Bold", size: 18))
                        .foregroundColor(Color.y2yCard)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.y2yAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .shadow(color: Color.y2yAccent.opacity(0.35), radius: 14, x: 0, y: 6)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 52)
            }
        }
    }
}

struct OnboardingSlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 38) {
            ZStack {
                Circle()
                    .fill(Color.y2yCard)
                    .frame(width: 148, height: 148)
                    .shadow(color: Color.black.opacity(0.28), radius: 24, x: 0, y: 10)
                Image(systemName: slide.icon)
                    .font(.system(size: 60, weight: .thin))
                    .foregroundColor(.white)
            }

            VStack(spacing: 16) {
                Text(slide.title)
                    .font(Font.custom("Georgia-Bold", size: 26))
                    .foregroundColor(Color.y2yTan)
                    .multilineTextAlignment(.center)

                Text(slide.caption)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.y2ySubtext)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 28)
            }
        }
        .padding(.horizontal, 24)
    }
}

// logij

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username    = ""
    @State private var email       = ""
    @State private var selectedType: UserType? = nil
    @State private var errorMessage: String? = nil
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    var body: some View {
        ZStack {
            Color.y2yBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 26) {
                    Yard2YumHeader().padding(.top, 16)

                    // Logo mark
                    ZStack {
                        Circle().fill(Color.y2yCard).frame(width: 90, height: 90)
                            .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 6)
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 52)).foregroundColor(Color.y2yAccent)
                    }

                    Text("Connecting food, farms & future")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.y2ySubtext)

                    VStack(spacing: 14) {
                        Y2YTextField(placeholder: "Username", text: $username, icon: "person.fill")
                        Y2YTextField(placeholder: "Email", text: $email, icon: "envelope.fill")
                            .keyboardType(.emailAddress).textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("I AM A...")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Color.y2ySubtext.opacity(0.65))
                            .padding(.horizontal, 24)

                        ForEach(UserType.allCases, id: \.self) { type in
                            UserTypeCard(type: type, isSelected: selectedType == type) {
                                withAnimation(.spring(response: 0.3)) { selectedType = type }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(Color(red: 1, green: 0.5, blue: 0.45))
                            .padding(.horizontal, 24)
                    }

                    Button {
                        if username.isEmpty || email.isEmpty || selectedType == nil {
                            errorMessage = "Please fill in all fields and select a role."
                        } else if !isValidEmail(email) {
                            errorMessage = "Please enter a valid email address."
                        } else {
                            errorMessage = nil
                            appState.username = username
                            appState.email = email
                            appState.selectedUserType = selectedType
                            appState.showOnboarding = true
                            appState.isLoggedIn = true
                        }
                    } label: {
                        Text("Continue")
                            .font(Font.custom("Georgia-Bold", size: 18))
                            .foregroundColor(Color.y2yCard)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.y2yAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 26))
                            .shadow(color: Color.y2yAccent.opacity(0.3), radius: 12, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 52)
                }
            }
        }
    }
}

struct UserTypeCard: View {
    let type: UserType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? type.accentColor : Color.white.opacity(0.07))
                        .frame(width: 46, height: 46)
                    Image(systemName: type.icon)
                        .foregroundColor(isSelected ? Color.y2yCard : Color.y2ySubtext)
                        .font(.system(size: 18, weight: .medium))
                }
                Text(type.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.y2yTan)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(type.accentColor).font(.system(size: 22))
                }
            }
            .padding(16)
            .background(Color.y2yCard)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(isSelected ? type.accentColor : Color.white.opacity(0.06), lineWidth: 1.5))
            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
    }
}

struct Y2YTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(Color.y2ySubtext.opacity(0.65)).frame(width: 20)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.y2ySubtext.opacity(0.45)))
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(Color.y2yTan)
                .tint(Color.y2yAccent)
        }
        .padding(16)
        .background(Color.y2yCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }
}

// restaurants

struct RestaurantFlowView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 1
    var body: some View {
        NavigationStack {
            if currentPage == 1 { RestaurantPage1(onNext: { currentPage = 2 }).environmentObject(appState) }
            else { RestaurantPage2(onBack: { currentPage = 1 }).environmentObject(appState) }
        }
    }
}

struct RestaurantPage1: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void
    @State private var selectedPhoto: PhotosPickerItem? = nil
    let types = ["Fine Dining", "Casual", "Fast Casual", "Café", "Bakery", "Food Truck", "Other"]

    var body: some View {
        Y2YPage(title: "Your Restaurant", subtitle: "Tell us about your establishment") {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(Color.y2yCard).frame(height: 180)
                    if let img = appState.restaurantImage {
                        Image(uiImage: img).resizable().scaledToFill().frame(height: 180).clipShape(RoundedRectangle(cornerRadius: 24))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.plus").font(.system(size: 34)).foregroundColor(Color.y2yAccent)
                            Text("Add Restaurant Photo").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Color.y2ySubtext)
                        }
                    }
                }
            }
            .onChange(of: selectedPhoto) { item in Task { if let d = try? await item?.loadTransferable(type: Data.self), let img = UIImage(data: d) { appState.restaurantImage = img } } }

            Y2YInputField(label: "Restaurant Name", placeholder: "e.g. The Green Table", text: $appState.restaurantName)

            VStack(alignment: .leading, spacing: 8) {
                Text("Type of Restaurant").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(Color.y2ySubtext)
                Menu {
                    ForEach(types, id: \.self) { t in Button(t) { appState.restaurantType = t } }
                } label: {
                    HStack {
                        Text(appState.restaurantType.isEmpty ? "Select type..." : appState.restaurantType)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(appState.restaurantType.isEmpty ? Color.y2ySubtext.opacity(0.45) : Color.y2yTan)
                        Spacer()
                        Image(systemName: "chevron.down").foregroundColor(Color.y2yAccent).font(.system(size: 13))
                    }
                    .padding(16).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
                }
            }

            Y2YButton(title: "Next: Schedule Pickup", icon: "arrow.right", action: onNext)
                .disabled(appState.restaurantName.isEmpty).padding(.top, 4)
        }
        .toolbar { LogoutToolbarItem() }
    }
}

struct RestaurantPage2: View {
    @EnvironmentObject var appState: AppState
    let onBack: () -> Void
    @State private var submitted = false

    var body: some View {
        Y2YPage(title: "Schedule Pickup", subtitle: "When do you need compost collected?") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Pickup Date & Time").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(Color.y2ySubtext)
                DatePicker("", selection: $appState.pickupDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical).tint(Color.y2yAccent).colorScheme(.dark)
                    .padding(12).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 22))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount (lbs)").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(Color.y2ySubtext)
                HStack {
                    Slider(value: $appState.pickupPounds, in: 0...500, step: 5).tint(Color.y2yAccent)
                    Text("\(Int(appState.pickupPounds)) lbs")
                        .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(Color.y2yAccent).frame(width: 74, alignment: .trailing)
                }
                .padding(16).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 20))
            }
            if submitted {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill").foregroundColor(Color.y2yAccent)
                    Text("Pickup request submitted!").font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundColor(Color.y2yTan)
                }
                .padding(14).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 18))
            }
            Y2YButton(title: "Submit Pickup Request", icon: "paperplane.fill") {
                withAnimation {
                    let newRequest = PickupRequest(
                        restaurantName: appState.restaurantName,
                        date: appState.pickupDate,
                        pounds: appState.pickupPounds,
                        location: appState.restaurantName
                    )

                    appState.pickupRequests.append(newRequest)

                    submitted = true
                    appState.pickupPounds = 0
                }
            }
            .disabled(appState.pickupPounds == 0)
            BackButton(action: onBack)
        }
        .toolbar { LogoutToolbarItem() }
    }
}

// for farms

struct FarmFlowView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 1
    var body: some View {
        NavigationStack {
            if currentPage == 1 { FarmPage1(onNext: { currentPage = 2 }).environmentObject(appState) }
            else { FarmPage2(onBack: { currentPage = 1 }).environmentObject(appState) }
        }
    }
}

struct FarmPage1: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void
    @State private var selectedPhoto: PhotosPickerItem? = nil

    var body: some View {
        Y2YPage(title: "Your Farm", subtitle: "Share your farm's details") {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(Color.y2yCard).frame(height: 180)
                    if let img = appState.farmImage {
                        Image(uiImage: img).resizable().scaledToFill().frame(height: 180).clipShape(RoundedRectangle(cornerRadius: 24))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.plus").font(.system(size: 34)).foregroundColor(Color.y2yAccent)
                            Text("Add Farm Photo").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Color.y2ySubtext)
                        }
                    }
                }
            }
            .onChange(of: selectedPhoto) { item in Task { if let d = try? await item?.loadTransferable(type: Data.self), let img = UIImage(data: d) { appState.farmImage = img } } }

            Y2YInputField(label: "Farm Name", placeholder: "e.g. Sunflower Acres", text: $appState.farmName)
            Y2YInputField(label: "Farm Location", placeholder: "e.g. 789 County Rd, Springfield", text: $appState.farmLocation)
            Y2YButton(title: "Next: Browse Compost", icon: "arrow.right", action: onNext)
                .disabled(appState.farmName.isEmpty || appState.farmLocation.isEmpty).padding(.top, 4)
        }
        .toolbar { LogoutToolbarItem() }
    }
}

struct FarmPage2: View {
    @EnvironmentObject var appState: AppState
    let onBack: () -> Void
    @State private var purchasedID: UUID? = nil

    var body: some View {
        Y2YPage(title: "Compost Marketplace", subtitle: "Buy from local composting facilities") {
            ForEach(appState.marketplaceListings) { listing in
                CompostListingCard(listing: listing, isPurchased: purchasedID == listing.id) { withAnimation { purchasedID = listing.id } }
            }
            BackButton(action: onBack)
        }
        .toolbar { LogoutToolbarItem() }
    }
}

struct CompostListingCard: View {
    let listing: CompostListing
    let isPurchased: Bool
    let onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.facilityName).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Color.y2yTan)
                    Text("\(Int(listing.availablePounds)) lbs available").font(.system(size: 12, design: .rounded)).foregroundColor(Color.y2ySubtext)
                }
                Spacer()
                Text(String(format: "$%.2f/lb", listing.pricePerPound))
                    .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Color.y2yAccent)
            }
            Button(action: onBuy) {
                HStack {
                    Image(systemName: isPurchased ? "checkmark.circle.fill" : "cart.fill")
                    Text(isPurchased ? "Order Placed!" : "Buy Compost")
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(isPurchased ? Color.y2ySubtext : Color.y2yCard)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(isPurchased ? Color.white.opacity(0.08) : Color.y2yAccent)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .disabled(isPurchased)
        }
        .padding(18).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// composting facility
struct CompostFacilityFlowView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 1
    var body: some View {
        NavigationStack {
            if currentPage == 1 { FacilityPage1(onNext: { currentPage = 2 }).environmentObject(appState) }
            else { FacilityPage2(onBack: { currentPage = 1 }).environmentObject(appState) }
        }
    }
}

struct FacilityPage1: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void

    var body: some View {
        Y2YPage(title: "Your Facility", subtitle: "Set up your composting facility profile") {
            ZStack {
                Circle().fill(Color.y2yCard).frame(width: 118, height: 118)
                    .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 6)
                Image(systemName: "arrow.3.trianglepath")
                    .font(.system(size: 50, weight: .thin)).foregroundColor(Color.y2yAccent)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 8)

            Y2YInputField(label: "Facility Name", placeholder: "e.g. Green Earth Compost Co.", text: $appState.facilityName)
            Y2YButton(title: "Continue to Dashboard", icon: "arrow.right", action: onNext)
                .disabled(appState.facilityName.isEmpty).padding(.top, 4)
        }
        .toolbar { LogoutToolbarItem() }
    }
}

struct FacilityPage2: View {
    @EnvironmentObject var appState: AppState
    let onBack: () -> Void
    @State private var selectedTab = 0
    @State private var newPrice = ""
    @State private var newPounds = ""

    var body: some View {
        Y2YPage(title: appState.facilityName, subtitle: "Facility Dashboard") {
            HStack(spacing: 0) {
                DashTabButton(title: "Pickups",      isSelected: selectedTab == 0) { selectedTab = 0 }
                DashTabButton(title: "Marketplace",  isSelected: selectedTab == 1) { selectedTab = 1 }
            }
            .background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 20))

            if selectedTab == 0 {
                ForEach(appState.pickupRequests) { PickupRequestCard(request: $0) }
            } else {
                ForEach(appState.marketplaceListings) { MyListingCard(listing: $0) }
                VStack(alignment: .leading, spacing: 14) {
                    Text("Add New Listing").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Color.y2ySubtext)
                    Y2YInputField(label: "Price per lb ($)", placeholder: "0.40", text: $newPrice).keyboardType(.decimalPad)
                    Y2YInputField(label: "Available (lbs)", placeholder: "100", text: $newPounds).keyboardType(.numberPad)
                    Y2YButton(title: "Post Listing", icon: "plus.circle.fill") {
                        if let p = Double(newPrice), let lbs = Double(newPounds) {
                            appState.marketplaceListings.append(CompostListing(facilityName: appState.facilityName, pricePerPound: p, availablePounds: lbs))
                            newPrice = ""; newPounds = ""
                        }
                    }
                    .disabled(newPrice.isEmpty || newPounds.isEmpty)
                }
                .padding(18).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 24))
            }
            BackButton(action: onBack)
        }
        .toolbar { LogoutToolbarItem() }
    }
}

struct DashTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? Color.y2yCard : Color.y2ySubtext)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(isSelected ? Color.y2yAccent : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(4)
        }
    }
}

struct PickupRequestCard: View {
    let request: PickupRequest
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color(red: 0.95, green: 0.58, blue: 0.35).opacity(0.18)).frame(width: 46, height: 46)
                Image(systemName: "fork.knife").foregroundColor(Color(red: 0.95, green: 0.58, blue: 0.35))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(request.restaurantName).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(Color.y2yTan)
                Text(request.location).font(.system(size: 11, design: .rounded)).foregroundColor(Color.y2ySubtext)
                Text(request.date.formatted(date: .abbreviated, time: .shortened)).font(.system(size: 11, design: .rounded)).foregroundColor(Color.y2ySubtext)
            }
            Spacer()
            Text("\(Int(request.pounds)) lbs").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(Color.y2yAccent)
        }
        .padding(16).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(0.16), radius: 7, x: 0, y: 3)
    }
}

struct MyListingCard: View {
    let listing: CompostListing
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.facilityName).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(Color.y2yTan)
                Text("\(Int(listing.availablePounds)) lbs available").font(.system(size: 12, design: .rounded)).foregroundColor(Color.y2ySubtext)
            }
            Spacer()
            Text(String(format: "$%.2f/lb", listing.pricePerPound))
                .font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Color(red: 0.78, green: 0.65, blue: 0.38))
        }
        .padding(16).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(0.16), radius: 7, x: 0, y: 3)
    }
}

// on every page at the top there should be the logo / name

struct Y2YPage<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Color.y2yBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Yard2YumHeader().padding(.bottom, 4)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(Font.custom("Georgia-Bold", size: 26)).foregroundColor(Color.y2yTan)
                        Text(subtitle).font(.system(size: 14, design: .rounded)).foregroundColor(Color.y2ySubtext)
                    }
                    content
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 52)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Y2YInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(Color.y2ySubtext)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.y2ySubtext.opacity(0.45)))
                .font(.system(size: 15, design: .rounded)).foregroundColor(Color.y2yTan).tint(Color.y2yAccent)
                .padding(16).background(Color.y2yCard).clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
        }
    }
}

struct Y2YButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title).font(Font.custom("Georgia-Bold", size: 17))
                Image(systemName: icon).font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(Color.y2yCard)
            .frame(maxWidth: .infinity).padding(.vertical, 17)
            .background(Color.y2yAccent)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .shadow(color: Color.y2yAccent.opacity(0.3), radius: 12, x: 0, y: 5)
        }
    }
}

struct BackButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left").font(.system(size: 13, weight: .semibold))
                Text("Back").font(.system(size: 15, weight: .medium, design: .rounded))
            }
            .foregroundColor(Color.y2ySubtext)
        }
        .padding(.top, 4)
    }
}

struct LogoutToolbarItem: ToolbarContent {
    @EnvironmentObject var appState: AppState
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                appState.isLoggedIn = false
                appState.selectedUserType = nil
                appState.showOnboarding = false
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right").foregroundColor(Color.y2yAccent)
            }
        }
    }
}

//

struct Yard2YumHeader: View {
    var body: some View {
        Image("y2y")
            .resizable()
            .scaledToFit()
            .frame(width:200, height:200)
            .padding(.top,1)
    }
}

//

#Preview {
    ContentView()
}

