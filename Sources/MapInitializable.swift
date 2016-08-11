// MediaType.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

extension MapInitializable {
    public init(map: Map) throws {
        guard case .dictionary(let dictionary) = map else {
            throw MapError.cannotInitialize(type: Self.self, from: try type(of: map.get()))
        }
        self = try construct { property in
            guard let initializable = property.type as? MapInitializable.Type else {
                throw MapError.notMapInitializable(property.type)
            }
            switch dictionary[property.key] ?? .null {
            case .null:
                guard let expressibleByNilLiteral = property.type as? ExpressibleByNilLiteral.Type else {
                    throw ReflectionError.requiredValueMissing(key: property.key)
                }
                return expressibleByNilLiteral.init(nilLiteral: ())
            case let x:
                return try initializable.init(map: x)
            }
        }
    }
}

extension Map : MapInitializable {
    public init(map: Map) throws {
        self = map
    }
}

extension Bool : MapInitializable {
    public init(map: Map) throws {
        guard case .bool(let bool) = map else {
            throw MapError.cannotInitialize(type: Bool.self, from: try type(of: map.get()))
        }
        self = bool
    }
}

extension Double : MapInitializable {
    public init(map: Map) throws {
        guard case .double(let double) = map else {
            throw MapError.cannotInitialize(type: Double.self, from: try type(of: map.get()))
        }
        self = double
    }
}

extension Int : MapInitializable {
    public init(map: Map) throws {
        guard case .int(let int) = map else {
            throw MapError.cannotInitialize(type: Int.self, from: try type(of: map.get()))
        }
        self = int
    }
}

extension String : MapInitializable {
    public init(map: Map) throws {
        guard case .string(let string) = map else {
            throw MapError.cannotInitialize(type: String.self, from: try type(of: map.get()))
        }
        self = string
    }
}

extension Data : MapInitializable {
    public init(map: Map) throws {
        guard case .data(let data) = map else {
            throw MapError.cannotInitialize(type: Data.self, from: try type(of: map.get()))
        }
        self = data
    }
}

extension Optional : MapInitializable {
    public init(map: Map) throws {
        guard let initializable = Wrapped.self as? MapInitializable.Type else {
            throw MapError.notMapInitializable(Wrapped.self)
        }
        if case .null = map {
            self = .none
        } else {
            self = try initializable.init(map: map) as? Wrapped
        }
    }
}

extension Array : MapInitializable {
    public init(map: Map) throws {
        guard case .array(let array) = map else {
            throw MapError.cannotInitialize(type: Array.self, from: try type(of: map.get()))
        }
        guard let initializable = Element.self as? MapInitializable.Type else {
            throw MapError.notMapInitializable(Element.self)
        }
        var this = Array()
        this.reserveCapacity(array.count)
        for element in array {
            if let value = try initializable.init(map: element) as? Element {
                this.append(value)
            }
        }
        self = this
    }
}

public protocol MapDictionaryKeyInitializable {
    init(mapDictionaryKey: String)
}

extension String : MapDictionaryKeyInitializable {
    public init(mapDictionaryKey: String) {
        self = mapDictionaryKey
    }
}

extension Dictionary : MapInitializable {
    public init(map: Map) throws {
        guard case .dictionary(let dictionary) = map else {
            throw MapError.cannotInitialize(type: Dictionary.self, from: try type(of: map.get()))
        }
        guard let keyInitializable = Key.self as? MapDictionaryKeyInitializable.Type else {
            throw MapError.notMapDictionaryKeyInitializable(type(of: self))
        }
        guard let valueInitializable = Value.self as? MapInitializable.Type else {
            throw MapError.notMapInitializable(Element.self)
        }
        var this = Dictionary(minimumCapacity: dictionary.count)
        for (key, value) in dictionary {
            if let key = keyInitializable.init(mapDictionaryKey: key) as? Key {
                this[key] = try valueInitializable.init(map: value) as? Value
            }
        }
        self = this
    }
}
