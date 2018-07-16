//
//  ViewModel.swift
//  TableViewCellExtensionDemo
//
//  Created by Andreas Hård on 2018-07-13.
//  Copyright © 2018 Andreas Hård. All rights reserved.
//

import Foundation
import UIKit

public enum SectionId {
    case tableware
    case sneakers
    case actors
    case person
}

public enum CellId {
    case icon
    case text
    case portraitImage
}

protocol CellCapable {
    var cellId: CellId { get }
    var title: String { get }
    
    init(cellId: CellId, title: String)
}

protocol LocalImageCellCapable: CellCapable {
    var image: UIImage? { get }
}

protocol ImageURLCellCapable: CellCapable {
    var imageURL: URL? { get }
}

protocol SectionCapable {
    var sectionId: SectionId { get }
    var title: String { get }
    var rows: [CellCapable] { get }
    
    init(sectionId: SectionId, title: String, rows: [CellCapable])
}

protocol ViewModelCapable {
    var title: String { get }
    var sections: [SectionCapable] { get }
}

struct SectionViewModel: SectionCapable {
    let sectionId: SectionId
    let title: String
    let rows: [CellCapable]
    
    init(sectionId: SectionId, title: String, rows: [CellCapable]) {
        self.sectionId = sectionId
        self.title = title
        self.rows = rows
    }
}

struct CellViewModel: CellCapable {
    let cellId: CellId
    let title: String
    
    init(cellId: CellId, title: String) {
        self.cellId = cellId
        self.title = title
    }
}

struct ImageCellViewModel: LocalImageCellCapable {
    let cellId: CellId
    let title: String
    let imageName: String?
    var image: UIImage? {
        if let imageName = self.imageName {
            return UIImage(named: imageName)
        }
        return nil
    }
    
    init(cellId: CellId, title: String) {
        self.cellId = cellId
        self.title = title
        self.imageName = nil
    }
    
    init(cellId: CellId, title: String, imageName: String) {
        self.cellId = cellId
        self.title = title
        self.imageName = imageName
    }
}

struct ImageURLCellViewModel: ImageURLCellCapable {
    let cellId: CellId
    let title: String
    let imageURL: URL?
    
    init(cellId: CellId, title: String) {
        self.cellId = cellId
        self.title = title
        self.imageURL = nil
    }
    
    init(cellId: CellId, title: String, imageURL: URL) {
        self.cellId = cellId
        self.title = title
        self.imageURL = imageURL
    }
}

struct ViewModel: ViewModelCapable {
    let sections: [SectionCapable]
    let title: String
    
    init() {
        title = "FirstViewController"
        
        let cutlery = ImageCellViewModel(cellId: .icon,
                                           title: "Cutlery",
                                           imageName: "Cutlery")
        let teapot = ImageCellViewModel(cellId: .icon,
                                        title: "Teapot",
                                        imageName: "Teapot")
        let wineglass = ImageCellViewModel(cellId: .icon,
                                           title: "Wine glass",
                                           imageName: "Wineglass")
        let beerglass = ImageCellViewModel(cellId: .icon,
                                           title: "Beer glass",
                                           imageName: "Beerglass")
        let tableware = SectionViewModel(sectionId: .tableware,
                                         title: "Tableware",
                                         rows: [cutlery, teapot, wineglass, beerglass])
        
        let adidas = CellViewModel(cellId: .text, title: "Adidas")
        let converse = CellViewModel(cellId: .text, title: "Converse")
        let nike = CellViewModel(cellId: .text, title: "Nike")
        let rebook = CellViewModel(cellId: .text, title: "Rebook")
        
        
        let sneakers = SectionViewModel(sectionId: .sneakers,
                                         title: "Sneakers",
                                         rows: [adidas, converse, nike, rebook])

        let diCaprio = ImageURLCellViewModel(cellId: .portraitImage,
                                        title: "Leonardo DiCaprio",
                                        imageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMjI0MTg3MzI0M15BMl5BanBnXkFtZTcwMzQyODU2Mw@@._V1_UY317_CR10,0,214,317_AL_.jpg")!)
        let monroe = ImageURLCellViewModel(cellId: .portraitImage,
                                           title: "Marilyn Monroe",
                                           imageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BNzQzNDMxMjQxNF5BMl5BanBnXkFtZTYwMTc5NTI2._V1_UY317_CR7,0,214,317_AL_.jpg")!)
        let deNiro = ImageURLCellViewModel(cellId: .portraitImage,
                                        title: "Robert De Niro",
                                        imageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMjAwNDU3MzcyOV5BMl5BanBnXkFtZTcwMjc0MTIxMw@@._V1_UY317_CR13,0,214,317_AL_.jpg")!)
        let actors = SectionViewModel(sectionId: .actors, title: "Actors", rows: [diCaprio, monroe, deNiro])
        
        let promotedTitle = CellViewModel(cellId: .text, title: "Alicia Vikander")
        let promotedStarSign = ImageCellViewModel(cellId: .icon,
                                           title: "Star sign",
                                           imageName: "Libra")
        let promotedImage = ImageURLCellViewModel(cellId: .portraitImage,
                                                   title: "A Swedish actress, dancer and producer. She was born and raised in Gothenburg, Västra Götalands län, Sweden, to Maria Fahl-Vikander, an actress of stage and screen, and Svante Vikander, a psychiatrist.",
                                                   imageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BZmMxYzk1OWEtMjE0MC00NTRlLTgwNTEtMGQ1YjA1Yzg1Nzc3XkEyXkFqcGdeQXVyMjQwMDg0Ng@@._V1_UY317_CR3,0,214,317_AL_.jpg")!)
        
        let promotedPerson = SectionViewModel(sectionId: .person, title: "Promoted Person", rows: [promotedTitle, promotedImage, promotedStarSign])
        
            
        sections = [tableware, sneakers, promotedPerson, actors]
    }
}
