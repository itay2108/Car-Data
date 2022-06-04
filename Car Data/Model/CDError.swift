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
    case unknownError
    
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
        default:
            return "an unknown error has occured"
        }
    }
}
