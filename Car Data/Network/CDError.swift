//
//  CDError.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import Foundation

enum CDError: Error {
    
    case unknownError
    
    //Network
    case parseError
    case noDataProvided
    case requestError
    case notFound
    case badData
    case serverFailed
    case timeout
    case canceled
    
    //Device
    case flashFailed
    case noFlash
    case flashUnavailable
    case cameraFailed
    case cameraPermissions
    case genericCamera
    
    var localizedDescription: String {
        switch self {
        case .parseError:
            return "Could not parse data from responce with the provided decoding structure"
        case .noDataProvided:
            return "No data was provided for the network request"
        case .requestError:
            return "Could not send request to server"
        case .notFound:
            return "Could not find what you were looking for"
        case .badData:
            return "Some of the data is missing in the server"
        case .serverFailed:
            return "There was an error with the remote database"
        case .timeout:
            return "The request timed out"
            
        case .flashFailed:
            return "Could not toggle flash"
        case .noFlash:
            return "This device doesn't have a flash"
        case .flashUnavailable:
            return "The flash is currently unavailable"
        case .cameraFailed:
            return "Could not start camera session"
        case .cameraPermissions:
            return "The app is not allowed to use the camera, please allow camera usage from settings"
        case .genericCamera:
            return "Something went wrong when trying to use the camera"
        default:
            return "an unknown error has occured"
        }
    }
}
