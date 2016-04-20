
// So apparently this is how you access a fixed length C array from
// an imported struct -.-
public func fixedCArrayToArray<T, E>(data: inout T) -> [E] {
    return withUnsafePointer(&data) { ptr -> [E] in
        let buffer = UnsafeBufferPointer(
            start: unsafeBitCast(ptr, to: UnsafePointer<E>.self),
            count: sizeofValue(data)
        )
        return [E](buffer)
    }
}
