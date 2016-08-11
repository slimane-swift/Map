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

extension MapFallibleRepresentable {
    public func asMap() throws -> Map {
        let props = try properties(self)
        var dictionary = [String: Map](minimumCapacity: props.count)
        for property in props {
            guard let representable = property.value as? MapFallibleRepresentable else {
                throw MapError.notMapRepresentable(type(of: property.value))
            }
            dictionary[property.key] = try representable.asMap()
        }
        return .dictionary(dictionary)
    }
}

extension Map : MapRepresentable {
    public var map: Map {
        return self
    }
}

extension Bool : MapRepresentable {
    public var map: Map {
        return .bool(self)
    }
}

extension Double : MapRepresentable {
    public var map: Map {
        return .double(self)
    }
}

extension Int : MapRepresentable {
    public var map: Map {
        return .int(self)
    }
}

extension String : MapRepresentable {
    public var map: Map {
        return .string(self)
    }
}

extension Data : MapRepresentable {
    public var map: Map {
        return .data(self)
    }
}

extension Optional where Wrapped : MapRepresentable {
    public var map: Map {
        switch self {
        case .some(let wrapped): return wrapped.map
        case .none: return .null
        }
    }
}

extension Array where Element : MapRepresentable {
    public var mapArray: [Map] {
        return self.map({$0.map})
    }
    
    public var map: Map {
        return .array(mapArray)
    }
}

public protocol MapDictionaryKeyRepresentable {
    var mapDictionaryKey: String { get }
}

extension String : MapDictionaryKeyRepresentable {
    public var mapDictionaryKey: String {
        return self
    }
}

extension Dictionary where Key : MapDictionaryKeyRepresentable, Value : MapRepresentable {
    public var mapDictionary: [String: Map] {
        var dictionary: [String: Map] = [:]
        
        for (key, value) in self.map({($0.0.mapDictionaryKey, $0.1.map)}) {
            dictionary[key] = value
        }
        
        return dictionary
    }
    
    public var map: Map {
        return .dictionary(mapDictionary)
    }
}

// MARK: MapFallibleRepresentable

extension Optional : MapFallibleRepresentable {
    public func asMap() throws -> Map {
        guard Wrapped.self is MapFallibleRepresentable.Type else {
            throw MapError.notMapRepresentable(Wrapped.self)
        }
        if case .some(let wrapped as MapFallibleRepresentable) = self {
            return try wrapped.asMap()
        }
        return .null
    }
}

extension Array : MapFallibleRepresentable {
    public func asMap() throws -> Map {
        guard Element.self is MapFallibleRepresentable.Type else {
            throw MapError.notMapRepresentable(Element.self)
        }
        var array: [Map] = []
        array.reserveCapacity(count)
        for element in self {
            let element = element as! MapFallibleRepresentable
            array.append(try element.asMap())
        }
        return .array(array)
    }
}

extension Dictionary : MapFallibleRepresentable {
    public func asMap() throws -> Map {
        guard Key.self is MapDictionaryKeyRepresentable.Type else {
            throw MapError.notMapDictionaryKeyRepresentable(Value.self)
        }
        guard Value.self is MapFallibleRepresentable.Type else {
            throw MapError.notMapRepresentable(Value.self)
        }
        var dictionary = [String: Map](minimumCapacity: count)
        for (key, value) in self {
            let value = value as! MapFallibleRepresentable
            let key = key as! MapDictionaryKeyRepresentable
            dictionary[key.mapDictionaryKey] = try value.asMap()
        }
        return .dictionary(dictionary)
    }
}
