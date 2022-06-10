//
//  PDFManager.swift
//  Car Data
//
//  Created by itay gervash on 10/06/2022.
//

import UIKit

public extension UIViewController {
    
    func render(pdfWithName fileName: String, withHeader header: UIImage? = nil, from tableView: UITableView, section sectionNumber: Int = 0, numberOfCells: Int) throws {
        
        guard let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last else {
            throw CDError.urlFailed
        }
        let fileURL = docURL.appendingPathComponent("\(fileName).pdf")
        
        
        var pdfPages: [UIImage] = []
        
        if let header = header {
            pdfPages.append(header)
        }
        
        for row in 0..<numberOfCells {
            tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: false)
            
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: sectionNumber)) {
                pdfPages.append(cell.asImage())
            }
        }
        
        var totalPageHeight: CGFloat = 0
        
        if let header = header {
            totalPageHeight += header.size.height
        }
        
        for page in pdfPages {
            totalPageHeight += page.size.height
        }
        
        var currentYOffset: CGFloat = 0
        
        let pdfGenerator = UIGraphicsPDFRenderer(bounds: .init(x: 0, y: 0, width: tableView.bounds.width, height: totalPageHeight))
        
        do {
            try pdfGenerator.writePDF(to: fileURL) { context in
                context.beginPage()
                
                for pdfPage in pdfPages {
                    
                    pdfPage.draw(in: CGRect(x: 0, y: currentYOffset, width: pdfPage.size.width, height: pdfPage.size.height))
                    
                    currentYOffset += pdfPage.size.height
                }
            }
        } catch {
            throw CDError.pdfFailed
        }
        
       

    }
}
