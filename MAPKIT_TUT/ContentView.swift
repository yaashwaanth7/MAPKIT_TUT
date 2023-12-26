//
//  ContentView.swift
//  MAPKIT_TUT
//
//  Created by G Yashwanth Sharma on 26/12/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    // for polylines
    @State private var getDirection = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    var body: some View {
        
        Map(position: $cameraPosition, selection: $mapSelection){
//            Marker("My location",systemImage: "paperplane",coordinate: .userLocation)
//                .tint(.blue)
            
            UserAnnotation() // display current of user , only if user given permission to see current location
            
                // custom annotation
            Annotation("My location",coordinate: .userLocation){
                ZStack{
                    Circle()
                        .frame(width: 32,height: 32)
                        .foregroundStyle(.blue.opacity(0.25))
                    
                    Circle()
                        .frame(width: 20,height: 20)
                        .foregroundStyle(.white)
                    
                    Circle()
                        .frame(width: 12,height: 12)
                        .foregroundStyle(.blue)
                        
                }
            }
            // loads picker points in map for searched results
            ForEach(results,id:\.self){item in
                if routeDisplaying{
                    if item == routeDestination{
                        let placemark = item.placemark
                        Marker(placemark.name ?? "" , coordinate: placemark.coordinate)
                    }
                }else{
                    let placemark = item.placemark
                    Marker(placemark.name ?? "" , coordinate: placemark.coordinate)
                }
            }
            
            if let route{
                MapPolyline(route.polyline)
                    .stroke(.blue,lineWidth: 6)
            }
                
        }
        .overlay(alignment: .top){
            TextField("Search for a location",text: $searchText)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .padding()
                .shadow(radius: 10)
        }
        .onSubmit(of: .text) {
            print("Search for location with query \(searchText)")
            Task{
                await searchPlaces()
            }
        }
        .onChange(of: getDirection, {oldValue, newValue in
            if newValue{
                fetchRoute()
            }
        })
        .onChange(of: mapSelection,{oldValue,newValue in
            showDetails = newValue != nil
        })
        .sheet(isPresented: $showDetails, content: {
            LocationDetailsView(mapSelection: $mapSelection, show: $showDetails, getDirection: $getDirection)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        })
        .mapControls {
            MapCompass()
            MapPitchToggle()  // press option key to zoom in and out
            MapUserLocationButton()
        }
        
    }
    

}


extension ContentView{
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    
    // for polyline
    func fetchRoute() {
        if let mapSelection{
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            
            Task{
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy){
                    routeDisplaying = true
                    showDetails = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying{
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 25.7602, longitude: -80.1959)
    }
}

extension MKCoordinateRegion{
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,latitudinalMeters: 10000,longitudinalMeters: 10000)
    }

}




#Preview {
    ContentView()
}
