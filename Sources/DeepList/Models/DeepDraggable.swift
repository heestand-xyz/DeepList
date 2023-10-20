//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-20.
//

import UniformTypeIdentifiers
import CoreTransferable

public protocol DeepDraggable: Codable, Transferable {
    var itemID: UUID { get }
    static var contentType: UTType { get }
}

extension DeepDraggable {
    
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: self, contentType: contentType)
    }
}
