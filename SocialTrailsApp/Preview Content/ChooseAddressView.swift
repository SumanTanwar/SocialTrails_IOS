import SwiftUI
import GoogleMaps
import GooglePlaces

struct ChooseAddressView: View {
    @Binding var show: Bool
    @Binding var selectedLocation: Location?
    @State private var address: String = ""
    @State private var predictions: [GMSAutocompletePrediction] = []
    @State private var selectedPrediction: GMSAutocompletePrediction?
    @State private var placeDetails: GMSPlace?
    @State private var mapCoordinate: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    TextField("Search Location", text: $address)
                        .onChange(of: address) { newValue in
                            self.performAutocomplete()
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 10)
                        .padding(.top, 20) // Add top padding

                    if !predictions.isEmpty {
                        List(predictions, id: \.placeID) { prediction in
                            Text(prediction.attributedFullText.string)
                                .onTapGesture {
                                    self.selectedPrediction = prediction
                                    self.address = prediction.attributedFullText.string
                                    self.fetchPlaceDetails(for: prediction.placeID)
                                    self.predictions = []
                                }
                        }
                        .frame(height: 100)
                        .padding(.horizontal, -20)
                    }

                    MapView(
                        coordinate: mapCoordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                        markerCoordinate: $mapCoordinate,
                        onTap: { tappedCoordinate in
                            self.reverseGeocodeCoordinate(tappedCoordinate)
                        }
                    )
                    .frame(height: 350)
                    .cornerRadius(10)
                    .padding(.bottom, 8)

                    Spacer()

                    HStack {
                        Spacer()
                        Button(action: {
                            show.toggle()
                        }) {
                            Text("Cancel")
                                .frame(width: 80, height: 30) // Set a small size
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }

                        Button(action: {
                            if let place = self.placeDetails {
                                let location = Location(
                                    address: place.formattedAddress ?? "",
                                    latitude: place.coordinate.latitude,
                                    longitude: place.coordinate.longitude
                                )
                                self.selectedLocation = location
                            }
                            show.toggle()
                        }) {
                            Text("Confirm")
                                .frame(width: 80, height: 30) // Set a small size
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 15) // Add bottom padding to the buttons
                }
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
                Spacer()
            }
            .frame(maxWidth: 400, maxHeight: 600)
            .background(Color.white)
            .cornerRadius(15)
            .padding()
        }
    }

    private func performAutocomplete() {
        guard !address.isEmpty else {
            self.predictions = []
            return
        }

        let filter = GMSAutocompleteFilter()
        filter.type = .address

        let token = GMSAutocompleteSessionToken.init()

        GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: address, filter: filter, sessionToken: token) { (results, error) in
            if let error = error {
                print("Autocomplete error: \(error.localizedDescription)")
                return
            }

            if let results = results {
                self.predictions = results
            } else {
                self.predictions = []
            }
        }
    }

    private func fetchPlaceDetails(for placeID: String) {
        let placeFields: GMSPlaceField = [.name, .formattedAddress, .coordinate]

        GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: placeFields, sessionToken: nil) { (place, error) in
            if let error = error {
                print("Place details error: \(error.localizedDescription)")
                return
            }

            if let place = place {
                self.placeDetails = place
                self.mapCoordinate = place.coordinate
            }
        }
    }

    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }

            if let result = response?.firstResult() {
                let formattedAddress = result.lines?.joined(separator: ", ") ?? ""
                self.selectedLocation = Location(address: formattedAddress, latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.address = formattedAddress
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    @Binding var markerCoordinate: CLLocationCoordinate2D?
    var onTap: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView(frame: .zero)
        mapView.isMyLocationEnabled = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 15.0)
        uiView.camera = camera
        uiView.clear()

        if let markerCoordinate = markerCoordinate {
            let marker = GMSMarker()
            marker.position = markerCoordinate
            marker.title = "Selected Location"
            marker.map = uiView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            parent.onTap(coordinate)
            parent.markerCoordinate = coordinate
        }
    }
}
