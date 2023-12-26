//
//  LocationDetailsView.swift
//  MAPKIT_TUT
//
//  Created by G Yashwanth Sharma on 26/12/23.
//

import SwiftUI
import MapKit

struct LocationDetailsView: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var show: Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var getDirection: Bool
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                
                Spacer()
                
                Button{
                    show.toggle()
                    mapSelection = nil
                    
                    
                }label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24,height: 24)
                        .foregroundColor(Color(.systemGray6))
                }
                
            }
            if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                    
            }else{
                ContentUnavailableView("No Preview available",systemImage: "eye.slash")
            }
            
            HStack(spacing: 24){
                Button {
                    if let mapSelection{
                        mapSelection.openInMaps()
                    }
                } label: {
                    Text("Open in Maps")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 170,height: 48)
                        .background(.green)
                        .cornerRadius(12)
                }
                
                Button {
                    getDirection = true
                    show = false
                    
                } label: {
                    Text("Get Directions")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 170,height: 48)
                        .background(.blue)
                        .cornerRadius(12)
                }

            }
        }
        
        .onAppear{
            fetchLookAroundPreview()
        }
        .onChange(of:mapSelection){oldValue, newValue in
            fetchLookAroundPreview()
        }
    }
}

// for secene
extension LocationDetailsView{
    func fetchLookAroundPreview() {
        if let mapSelection{
            lookAroundScene = nil
            Task{
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}
#Preview {
    LocationDetailsView(mapSelection:.constant(nil),show: .constant(false), getDirection: .constant(false))
}
