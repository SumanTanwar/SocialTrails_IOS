import SwiftUI
import GoogleMaps

struct MapOnlyView: View {
    var selectedLocation: CLLocationCoordinate2D
    @State private var mapCoordinate: CLLocationCoordinate2D?
    
    var body: some View {
        ZStack {
            MapViewWrapper(selectedLocation: selectedLocation) { location in
                // Handle the pin tap event here
                print("Marker tapped at: \(location.latitude), \(location.longitude)")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            mapCoordinate = selectedLocation
        }
    }
}

struct MapViewWrapper: UIViewRepresentable {
    var selectedLocation: CLLocationCoordinate2D
    var onMarkerTap: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        let camera = GMSCameraPosition.camera(withLatitude: selectedLocation.latitude,
                                              longitude: selectedLocation.longitude,
                                              zoom: 15) // Adjust zoom level as needed
        mapView.camera = camera
        
        // Add a marker for the selected location
        let marker = GMSMarker()
        marker.position = selectedLocation
        marker.map = mapView
        
        // Set the delegate to handle marker taps
        mapView.delegate = context.coordinator
        context.coordinator.marker = marker
        
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Optional: You can update the map view here if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: MapViewWrapper
        var marker: GMSMarker?

        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            // Notify the parent about the marker tap
            parent.onMarkerTap(marker.position)
            return true
        }
    }
}
