# README

This is a small example project made to demonstrate the possibilities you can do with Protocol Oriented Programming (POP).

## Assets

All stored assets have been labeled for a [Creative Commons](https://creativecommons.org/) license and are not my intellectual property.
These assets have been taken from the following sites:

- [https://www.publicdomainpictures.net/](https://www.publicdomainpictures.net/)
- [https://commons.wikimedia.org/](https://commons.wikimedia.org/)

## Design choices

### `Extensions.swift`

In the file a `Reusable` protocol has been declared:

```swift
protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}
```

Thanks to protocol extensions we can provide a default implementation for this protocol:

```swift
extension Reusable {
    static var reuseIdentifier: String { return String(describing: Self.self) }
    static var nib: UINib? {
        if UINib.nibExists(nibName: reuseIdentifier){
            return UINib(nibName: reuseIdentifier, bundle: nil)
        } else {
            return nil
        }
    }
}
```

In order for this protocol extension to work we need to provide a `nibExists(nibName: String) -> Bool` function as an extension to the `UINib` class:

```swift
let fileTypeNib = "nib"

extension UINib {
    static func nibExists(nibName: String) -> Bool {
        guard let path = Bundle.main.path(forResource: nibName, ofType: fileTypeNib) else {
            return false
        }
        return fileExists(at: path)
    }
}
```

In order for this `UINib` function to work we need to provide a `fileExists(at path: String) -> Bool` function.
Since `UINib` is a subclass of `NSObject` we can place the function as an extension of `NSObject` to have this method in all classes that are a subclass of `NSObject`:

```swift
extension NSObject {
    static func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}
```

#### Usage of the protocol

Now that we have the protocol all setup, we can provide extensions to `UITableView` and `UICollectionView` that relies less on hardcoded strings and is more type safe:

```swift
extension UITableView {
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: Reusable {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
    func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: Reusable {
        return self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}
```

Create a `UITableViewCell` that implements the `Reusable` protocol:

```swift
class MyTableViewCell: UITableViewCell, Reusable {

}
```

All one needs to do now is to register the `UITableViewCell` class:

```swift
tableView.registerReusableCell(MyTableViewCell.self)
```

And use the `UITableViewCell` class like so:

```swift
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MyTableViewCell
}
```

Neat!

### `ViewModel.swift`

The `ViewModel` is inspired by the [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel) architectural pattern.
It's built based upon a bunch of protocol and structs.

#### Protocols

##### `ViewModelCapable`

```swift
protocol ViewModelCapable {
    var title: String { get }
    var sections: [SectionCapable] { get }
}
```

This protocol has a title string and an array of sections.

##### SectionCapable

```swift
public enum SectionId {
    case tableware
    case sneakers
    case actors
    case person
}

protocol SectionCapable {
    var sectionId: SectionId { get }
    var title: String { get }
    var rows: [CellCapable] { get }
    
    init(sectionId: SectionId, title: String, rows: [CellCapable])
}
```

This protocol has:

- A sectionId for determining what type of section it is _(this enum is up to you to define to what suits your needs, in some cases it may not even be needed)_
	- For instance: It could be useful to have if you have different types of section header views that you want do display
- A title string _(for the section header)_
- An array of rows

##### The cells

###### CellCapable

The root protocol is defined like so:

```swift
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
```

- cellId _(The different types of cells we want to display)_
- title _(The text we want to display in the cell)_

We also have other protocols based upon the root protocol:

###### LocalImageCellCapable

```swift
protocol LocalImageCellCapable: CellCapable {
    var image: UIImage? { get }
}
```

- Has an optional immutable UIImage getter

###### ImageURLCellCapable

```swift
protocol ImageURLCellCapable: CellCapable {
    var imageURL: URL? { get }
}
```

- Has an optional immutable imageURL getter

#### Structs

We choose to use structs instead of a classes due to a multitude of reasons.<br>
You can read more about it on this StackOverflow post: [Why Choose Struct Over Class?](https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845)

##### The cells

###### CellViewModel

```swift
struct CellViewModel: CellCapable {
    let cellId: CellId
    let title: String
    
    init(cellId: CellId, title: String) {
        self.cellId = cellId
        self.title = title
    }
}
```

Nothing special, just a standard implementation of the protocol.

###### ImageCellViewModel

```swift
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
```

Here we store an `imageName` string instead of the `UIImage` class.
This has a few befinits:

- By storing a primitive type instead of a class the struct will be on the stack instead of on the heap

Instead we provide a getter to generate the `UIImage`:

```swift
var image: UIImage? {
    if let imageName = self.imageName {
        return UIImage(named: imageName)
    }
    return nil
}
```

###### ImageURLCellViewModel

```swift
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
```

- Nothing special, just a standard implementation of the protocol.
- Also worthy to mention is that Swift's `URL` type is a struct and not an `NSObject` subclass like in Objective-C

##### SectionViewModel

```swift
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
```

- Nothing special, just a standard implementation of the protocol.

##### ViewModel

- Now that we have all the protocols and child structs setup we can build our `ViewModel`
- It implements the `ViewModelCapable` protocol
- The `init()` function sets all the data we need in order to display our cells
- In this example all data is hardcoded in the init method, but in a real world application this would be an `init(with dto: SomeDTO)` function or equivalent
- By setting up the `ViewModel` like this you can mix and match what types of cells you display in each section just by switching what type of `CellViewModel` you use.
	- Take a look at the `promotedPerson` variable for an example

```swift
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
```