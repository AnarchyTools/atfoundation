public struct URL {
    public var schema: String?
    public var domain: String
    public var path: Path
    public var port: Int

    public var parameters = [(name: String, value: String?)]()
    public var fragment: String?
    public var user: String?
    public var password: String?

    public init(string: String) {
        self.domain = ""
        self.path = Path(string: "/")
        self.port = -1

        var parserState = ParserState.Schema("")
        for character in string.characters {
            parserState = self._parse(character, parserState)
            if case .Invalid = parserState {
                break
            }
        }
        if case .Fragment(let data) = parserState where data.characters.count > 0 {
            self.fragment = data
        }

        if self.schema == "http" && self.port < 0 {
            self.port = 80
        }
        if self.schema == "https" && self.port < 0 {
            self.port = 443
        }
    }

    private enum ParserState {
        case Schema(String)
        case AfterSchema
        case Domain(String)
        case Path(String)
        case Parameter(String)
        case Fragment(String)
        case Invalid
    }

    private mutating func _parse(_ character: Character, _ state: ParserState) -> ParserState {
        var newState: ParserState
        switch state {
            case .Schema(let data):
                var schema: String? = nil
                (newState, schema) = self._parseSchema(character, data)
                if let schema = schema where schema.characters.count > 0 {
                    self.schema = schema
                }
            case .AfterSchema:
                newState = self._parseAfterSchema(character)
            case .Domain(let data):
                var domain: String? = nil
                (newState, domain) = self._parseDomain(character, data)
                if let domain = domain {
                    // if domain contains @ split up
                    if domain.position(character: "@") != nil {
                        let parts = domain.split(character: "@", maxSplits: 1)
                        if parts[0].position(character: ":") != nil {
                            let parts = parts[0].split(character: ":", maxSplits: 1)
                            self.user = parts[0]
                            self.password = parts[1]
                        } else {
                            self.user = parts[0]
                        }
                        if parts[1].position(character: ":") != nil {
                            let parts = parts[1].split(character: ":", maxSplits: 1)
                            self.domain = parts[0]
                            if let port = Int(parts[1]) {
                                self.port = port
                            }
                        } else {
                            self.domain = parts[1]
                        }
                    } else {
                        self.domain = domain
                    }
                }
            case .Path(let data):
                var path: String? = nil
                (newState, path) = self._parsePath(character, data)
                if let path = path {
                    self.path = Path(string: path)
                }
            case .Parameter(let data):
                var parameter: String? = nil
                (newState, parameter) = self._parseParameter(character, data)
                if let parameter = parameter {
                    let parts = parameter.split(character: "=", maxSplits: 1)
                    if parts.count == 2 {
                        if let parameter = parts[0].urlDecoded, let value = parts[1].urlDecoded {
                            self.parameters.append((name: parameter, value: value))
                        }
                    } else {
                        if let parameter = parameter.urlDecoded {
                            self.parameters.append((name: parameter, value: nil))
                        }
                    }
                }
            case .Fragment(let data):
                newState = self._parseFragment(character, data)
            case .Invalid:
                return .Invalid
        }
        return newState
    }

    private func _parseSchema(_ character: Character, _ data: String) -> (ParserState, String?) {
        switch character {
            case "0"..."9", "a"..."z", "A"..."Z", "-":
                var value = data
                value.append(character)
                return (.Schema(value), nil)
            case ":":
                return (.AfterSchema, data)
            case "/":
                return (.Path("/"), data)
            default:
                return (.Invalid, data)
        }
    }

    private func _parseAfterSchema(_ character: Character) -> ParserState {
        switch character {
            case "/":
                return .AfterSchema
            default:
                let value = String(character)
                return .Domain(value)
        }
    }

    private func _parseDomain(_ character: Character, _ data: String) -> (ParserState, String?) {
        var value = data
        switch character {
            case "0"..."9", "a"..."z", "A"..."Z", "-", ".", "@", ":":
                value.append(character)
                return (.Domain(value), nil)
            case "/":
                return (.Path("/"), data)
            default:
                return (.Invalid, data)
        }
    }

    private func _parsePath(_ character: Character, _ data: String) -> (ParserState, String?) {
        var value = data
        switch character {
            case "0"..."9", "a"..."z", "A"..."Z", "-", ".", "_", "~", "%", "/":
                value.append(character)
                return (.Path(value), nil)
            case "?":
                return (.Parameter(""), data)
            default:
                return (.Invalid, data)
        }
    }

    private func _parseParameter(_ character: Character, _ data: String) -> (ParserState, String?) {
        switch character {
            case "0"..."9", "a"..."z", "A"..."Z", "-", ".", "_", "~", "%", "=", "/":
                var value = data
                value.append(character)
                return (.Parameter(value), nil)
            case "&":
                return (.Parameter(""), data)
            case "#":
                return (.Fragment(""), data)
            default:
                return (.Invalid, data)
        }
    }

    private func _parseFragment(_ character: Character, _ data: String) -> ParserState {
        var value = data
        value.append(character)
        return .Fragment(value)
    }
}

extension URL: CustomStringConvertible {
    public var description: String {
        var result = ""

        if let schema = self.schema {
            result += "\(schema)://"
        }

        if let user = self.user {
            if let password = self.password {
                result += "\(user):\(password)@"
            } else {
                result += "\(user)@"
            }
        }
        result += "\(self.domain)"

        if (self.port != 80 && self.schema == "http") || (self.port != 443 && self.schema == "https") {
            result += ":\(self.port)"
        }

        result += "\(self.path.description)"

        if self.parameters.count > 0 {
            result += "?"
            var params = [String]()
            for (name, value) in self.parameters {
                if let value = value {
                    params.append("\(name.urlEncoded)=\(value.urlEncoded)")
                } else {
                    params.append("\(name.urlEncoded)=")
                }
            }
            result += String.join(parts: params, delimiter: "&")
        }
        if let fragment = self.fragment {
            result += "#\(fragment)"
        }
        return result
    }
}

public extension String {
    public var urlEncoded: String {
        let dict = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]
        var result = ""
        for c in self.characters {
            switch c {
                case "0"..."9", "a"..."z", "A"..."Z", "-", ".", "_", "~":
                    result.append(c)
                default:
                    result.append("%")
                    let s = String(c)
                    for item in s.utf8 {
                        result.append(dict[Int((item & 0xf0) >> 4)])
                        result.append(dict[Int(item & 0x0f)])
                    }
            }
        }
        return result
    }

    public var urlDecoded: String? {
        let dict: [Character] = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]
        var result = [Int8]()
        var index = self.startIndex
        while true {
            let c = self[index]
            if c == "%" {
                if let highIndex = dict.index(of: self[index.advanced(by: 1)]), let lowIndex = dict.index(of: self[index.advanced(by: 2)]) {
                    let high = Int8(truncatingBitPattern: dict.startIndex.distance(to: highIndex))
                    let low = Int8(truncatingBitPattern: dict.startIndex.distance(to: lowIndex))
                    result.append(high << 4 + low)
                    index = index.advanced(by: 2)
                } else {
                    let s = String(c)
                    for item in s.utf8 {
                        result.append(Int8(item))
                    }
                }
            } else {
                let s = String(c)
                for item in s.utf8 {
                    result.append(Int8(item))
                }
            }

            index = index.successor()
            if index == self.endIndex {
                break
            }
        }
        result.append(0)
        return String(validatingUTF8: result)
    }
}