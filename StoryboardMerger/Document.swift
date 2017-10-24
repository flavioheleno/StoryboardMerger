//
//  Document.swift
//  StoryboardMerger
//
//  Created by Flavio Heleno on 23/10/17.
//  Copyright © 2017 Flavio Heleno. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    var originalXml: XMLDocument?
    var mergedXml: XMLDocument?
    var tempXml: XMLDocument?
    var indexesToRemove: [Int] = []

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
//        guard let xml = XMLParser(data: data) else {
//            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//        }
        
        do {
            try
                self.originalXml = XMLDocument(data: data)
        } catch  {
            //error
        }
        
    }

    func merge() {
        self.tempXml = self.originalXml
        if let root = self.tempXml?.rootElement() {
            if let inferredMetricsTieBreakers = root.elements(forName: "inferredMetricsTieBreakers").first {

                if inferredMetricsTieBreakers.children?.count == 0 {
                    self.mergedXml = self.originalXml
                    return
                } else {
                    if let arrayOfSegues = inferredMetricsTieBreakers.children {
                        let arrayOfUniqueIds = self.createArrayOfUniqueIds(arrayOfSegues: arrayOfSegues)
                        if self.checkIfThereAreReplicatedIds(arrayOfUniqueIDs: arrayOfUniqueIds, arrayOfSegues: arrayOfSegues) {
                            self.removeIds()
                        }
                    }
                    
                    if let arrayOfSegues = inferredMetricsTieBreakers.children {
                        if self.checkIfThereAreIdsWithOnlyOneReference(arrayOfSegues: arrayOfSegues) {
                            self.removeIds()
                        }
                    }
                    
                    self.mergedXml = self.tempXml
                }
            }
        }

    }
    
    func createArrayOfUniqueIds(arrayOfSegues: [XMLNode]) -> [String] {
        var arrayOfUniqueIDs: [String] = []
        
        for i in 0...arrayOfSegues.count - 1 {
            
            if arrayOfSegues[i].kind == .element {
                let node = arrayOfSegues[i]
                let element = node as! XMLElement
                
                if let keyNode = element.attribute(forName: "reference")?.stringValue  {
                    if arrayOfUniqueIDs.contains(keyNode) {
                        self.indexesToRemove.append(i)
                    } else {
                        arrayOfUniqueIDs.append(keyNode)
                    }
                }
            }
        }
        
        return arrayOfUniqueIDs
    }
    
    func checkIfThereAreReplicatedIds(arrayOfUniqueIDs: [String], arrayOfSegues: [XMLNode]) -> Bool {
        if arrayOfSegues.count > arrayOfUniqueIDs.count {
            return true
        }
        
        return false
    }
    
    func removeIds() {
        for index in self.indexesToRemove {
            self.tempXml!.rootElement()!.elements(forName: "inferredMetricsTieBreakers").first!.removeChild(at: index)
        }
        
        self.indexesToRemove.removeAll()
    }
    
    func checkIfThereAreIdsWithOnlyOneReference(arrayOfSegues: [XMLNode]) -> Bool {
        let xmlAsString = self.tempXml?.xmlString

        for i in 0...arrayOfSegues.count - 1 {
            
            if arrayOfSegues[i].kind == .element {
                let node = arrayOfSegues[i]
                let element = node as! XMLElement
                
                if let keyNode = element.attribute(forName: "reference")?.stringValue  {
                    if xmlAsString?.countInstances(of: keyNode) == 1 {
                        self.indexesToRemove.append(i)
                    }
                }
            }
        }
        
        if self.indexesToRemove.count > 0 {
            return true
        }
        
        return false
    }
}

