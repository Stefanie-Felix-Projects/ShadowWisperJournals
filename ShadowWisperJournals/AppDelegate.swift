//
//  AppDelegate.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 12.01.25.
//

import UIKit
import GoogleMaps
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Hier dein Google Maps API Key
        GMSServices.provideAPIKey("AIzaSyC5hx7FGU09gxrRW5pnU8ldI-PPK7dl76c")

        // Falls du Firebase hier initialisieren willst (anstatt im init deines @main App)
        // FirebaseApp.configure()

        return true
    }
}
