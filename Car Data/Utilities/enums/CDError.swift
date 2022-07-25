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
    
    //Camera
    case flashFailed
    case noFlash
    case flashUnavailable
    case cameraFailed
    case cameraPermissions
    case genericCamera
    case imagePickerFailed
    
    //Vision
    case noImageForRecognition
    case noRequestForRecognition
    case noResultsForImageRecognition
    
    //PDF
    case urlFailed
    case pdfFailed
    case deletionFailed
    case pdfNoData
    
    //Realm
    case noRealm
    case realmFailed
    
    //SK
    case purchaseFailed
    case purchaseCancelled
    case restoreFailed
    case nothingToRestore
    
    //Mail
    case emailError
    case emailUnavailable
    
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
        case .imagePickerFailed:
            return "Could not load gallery"
            
        case .noImageForRecognition:
            return "No image was provided for recognition in the correct format"
        case .noRequestForRecognition:
            return "recognition request was not found"
        case .noResultsForImageRecognition:
            return "Could not find a license plate in this image. Try zooming in on the license plate number for better results."
            
        case .urlFailed:
            return "Could not initialize a write url for data"
        case .pdfFailed:
            return "Could not render PDF"
        case .deletionFailed:
            return "Could not delete file at specified URL"
        case .pdfNoData:
            return "Could not find license plate number to share"
        case .noRealm:
            return "Could not find database"
        case .realmFailed:
            return "Could not modify database"
            
        case .purchaseFailed:
            return "Could not complete purchase, please try again."
        case .purchaseCancelled:
            return "The purchase has been cancelled"
        case .restoreFailed:
            return "could not restore purchases"
        case .nothingToRestore:
            return "nothing to restore"
            
        case .emailError:
            return "could not send email"
        case .emailUnavailable:
            return "emailing is not available"
        default:
            return "an unknown error has occured"
        }
    }
}
