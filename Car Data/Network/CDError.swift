//
//  CDError.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import Foundation

enum CDError: Error {
    case parseError
    case noDataProvided
    case requestError
    case notFound
    case badData
    case serverFailed
    case unknownError
    case timeout
    case canceled
    
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
        default:
            return "an unknown error has occured"
        }
    }
}
