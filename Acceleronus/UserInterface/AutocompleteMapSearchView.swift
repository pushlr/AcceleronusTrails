import SwiftUI
import MapKit

// Delegate wrapper to forward MKLocalSearchCompleter results
class CompleterDelegateWrapper: NSObject, MKLocalSearchCompleterDelegate {
    var onUpdate: ([MKLocalSearchCompletion]) -> Void
    
    init(onUpdate: @escaping ([MKLocalSearchCompletion]) -> Void) {
        self.onUpdate = onUpdate
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Completer failed: \(error)")
        onUpdate([])
    }
}

struct AutocompleteMapSearchView: View {
    @EnvironmentObject var userModel: UserModel
    
    @State var searchText: String = ""
    
    @State private var showDropdown = false
    @State private var completions: [MKLocalSearchCompletion] = []
    @State private var completer = MKLocalSearchCompleter()
    @State private var completerDelegate: CompleterDelegateWrapper? = nil
    @State private var selectFromDropDown = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search box
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search city or place", text: $searchText)
                        .focused($isFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocorrectionDisabled(true)
                        .onChange(of: searchText) { _ in
                            if !(selectFromDropDown) {
                                updateCompleter()
                            }
                            self.selectFromDropDown = false
                        }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            completions = []
                            showDropdown = false
                            hideKeyboard()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.15), value: searchText)
            
            // Dropdown
            if showDropdown {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(completions, id: \.self) { item in
                            Button(action: {
                                selectCompletion(item)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .foregroundColor(.primary)
                                    Text(item.subtitle)
                                        .foregroundColor(.gray)
                                        .font(.footnote)
                                        
                                    
                                    //Spacer()
                                }
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                
                            }
                            Divider()
                        }
                    }
                }
//                .frame(maxHeight: 300)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 4)
            }
        }
//        .frame(maxWidth: 350)
//        .padding(.top, 50)
        .onAppear {
            // Setup completer
            completer.resultTypes = [.address, .pointOfInterest]
            completerDelegate = CompleterDelegateWrapper { results in
                DispatchQueue.main.async {
                    self.completions = results
                    self.showDropdown = !results.isEmpty
                }
            }
            completer.delegate = completerDelegate
        }
    }
    
    // Update search results
    private func updateCompleter() {
        guard !searchText.isEmpty else {
            completions = []
            showDropdown = false
            return
        }
        completer.queryFragment = searchText
    }
    
    // Select a result
    private func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            
            print(response?.mapItems.first?.placemark.region)
    //        DispatchQueue.main.async {
//                // Center map
//                let region = MKCoordinateRegion(
//                    center: coordinate,
//                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//                )
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                
                userModel.map.setRegion(region, animated: true)
            //}
        }
        
        
        self.selectFromDropDown = true
        searchText = completion.title
        showDropdown = false
        hideKeyboard()
    }
    
    private func hideKeyboard() {
        isFocused = false
    }
}
