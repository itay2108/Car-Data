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
            return "התשובה מהשרת חזרה בפורמט שאנחנו לא מכירים. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .noDataProvided:
            return "לא הצלחנו להמיר את המספר שהזנת לבקשת רשת. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .requestError:
            return "לא הצלחנו לחפש במאגרי המידע הרלוונטיים. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .notFound:
            return "לא הצלחנו למצוא את הרכב שחיפשת. כדאי לוודא שהזנת את המספר נכון, ולקחת בחשבון שרכבים שעלו לכביש לפני פחות מחודש או יותר מ-25 שנה לא תמיד נמצאים במאגר"
        case .badData:
            return "השרת החזיר לנו תשובה בפורמט שאנחנו לא מכירים, אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .serverFailed:
            return "לא הצלחנו לתקשר עם מאגרי המידע הרלוונטיים. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .timeout:
            return "חיכינו וחיכינו אבל לא קיבלנו תשובה מהשרת. שווה לוודא שחיבור האינטרנט שלכם יציב."
            
        case .flashFailed:
            return "לא הצלחנו להפעיל את הפלאש"
        case .noFlash:
            return "נראה שלמכשיר שלך אין פלאש תקין"
        case .flashUnavailable:
            return "הפלאש לא זמין, כדאי לוודא שהוא לא דולק מהאפליקציה אחרת"
        case .cameraFailed:
            return "לא הצלחנו להפעיל את המצלמה. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .cameraPermissions:
            return "לא אפשרתם לנו גישה למצלמה, כדי להשתמש במצלמה - יש לאפשר לנו גישה מההגדרות של הטלפון"
        case .genericCamera:
            return "קרתה שגיאה שאנחנו לא מכירים עם המצלמה. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .imagePickerFailed:
            return "לא הצלחנו לטעון את הגלריה שלך. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
            
        case .noImageForRecognition:
            return "לא הצלחנו להשתמש בתמונה שסופקה לזיהוי מספר רכב"
        case .noRequestForRecognition:
            return "נראה שיש בעיה באלגוריתם זיהוי שלנו. אם הבעיה ממשיכה כדאי ליצור קשר ממסך ההגדרות"
        case .noResultsForImageRecognition:
            return "לא מצאנו מספר רכב בתמונה שסיפקת. כדאי לנסות לעשות זום על מספר הרכב, או לצלם תמונה חדה יותר"
            
        case .urlFailed:
            return "הייתה בעיה בגישה לאחסון של הטלפון"
        case .pdfFailed:
            return "לא הצלחנו ליצור קובץ נתונים לשיתוף"
        case .deletionFailed:
            return "לא הצלחנו למחוק את הקובץ הזמני שיצרנו באחסון. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .pdfNoData:
            return "לא מצאנו נתונים לשתף. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .noRealm:
            return "הייתה בעיה עם מבנה הנתונים שלנו. אם הבעיה ממשיכה כדאי לנסות לאפס את הנתונים או ליצור איתנו קשר ממסך ההגדרות"
        case .realmFailed:
            return "לא הצלחנו לערוך את מבנה הנתונים שלנו. אם הבעיה ממשיכה כדאי לנסות לאפס את הנתונים או ליצור איתנו קשר ממסך ההגדרות"
            
        case .purchaseFailed:
            return "הייתה בעיה בתהליך הרכישה, אנא וודאו שאמצעי התשלום פעיל ונסו שנית"
        case .purchaseCancelled:
            return "תהליך הרכישה בוטל"
        case .restoreFailed:
            return "לא הצלחנו לשחזר את הרכישות. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .nothingToRestore:
            return "לא היו רכישות לשחזר"
            
        case .emailError:
            return "לא הצלחנו לשלוח את המייל שלך. אם הבעיה ממשיכה כדאי ליצור איתנו קשר ממסך ההגדרות"
        case .emailUnavailable:
            return "שירות האימיילים לא זמין כרגע, אנא נסו שנית מאוחר יותר"
        default:
            return "קרתה שגיאה שאנחנו לא מכירים. אם הבעיה ממשיכה, כדאי ליצור איתנו קשר ממסך ההגדרות"
        }
    }
}
