================
File information
================


.. swift:struct:: FileMode : OptionSet

   .. swift:let:: rawValue: Mode_t


   .. swift:static_let:: Inaccessible= FileMode(rawValue: 0)


   .. swift:static_let:: ExecOthers= FileMode(rawValue: 1 << 0)


   .. swift:static_let:: WriteOthers= FileMode(rawValue: 1 << 1)


   .. swift:static_let:: ReadOthers= FileMode(rawValue: 1 << 2)


   .. swift:static_let:: RWOthers= ReadOthers + WriteOthers


   .. swift:static_let:: ExecGroup= FileMode(rawValue: 1 << 3)


   .. swift:static_let:: WriteGroup= FileMode(rawValue: 1 << 4)


   .. swift:static_let:: ReadGroup= FileMode(rawValue: 1 << 5)


   .. swift:static_let:: RWGroup= ReadGroup + WriteGroup


   .. swift:static_let:: ExecOwner= FileMode(rawValue: 1 << 6)


   .. swift:static_let:: WriteOwner= FileMode(rawValue: 1 << 7)


   .. swift:static_let:: ReadOwner= FileMode(rawValue: 1 << 8)


   .. swift:static_let:: RWOwner= ReadOwner + WriteOwner


   .. swift:static_let:: ExecAll= ExecOthers  + ExecGroup  + ExecOwner


   .. swift:static_let:: WriteAll= WriteOthers + WriteGroup + WriteOwner


   .. swift:static_let:: ReadAll= ReadOthers  + ReadGroup  + ReadOwner


   .. swift:static_let:: StickyBit= FileMode(rawValue: 1 << 9)


   .. swift:static_let:: SetGID= FileMode(rawValue: 1 << 10)


   .. swift:static_let:: SetUID= FileMode(rawValue: 1 << 11)


   .. swift:init:: init(rawValue: Mode_t)



.. swift:extension:: FileMode : CustomStringConvertible



.. swift:enum:: FileType : Mode_t

   .. swift:enum_case:: Invalid = 0


   .. swift:enum_case:: FIFO = 1


   .. swift:enum_case:: CharacterDevice = 2


   .. swift:enum_case:: Directory = 4


   .. swift:enum_case:: BlockDevice = 6


   .. swift:enum_case:: File = 8


   .. swift:enum_case:: Symlink = 10


   .. swift:enum_case:: Socket = 12


   .. swift:enum_case:: Whiteout = 14



.. swift:struct:: FileInfo

   .. swift:let:: path: Path

    path to the file

   .. swift:let:: owner: uid_t

    owner id

   .. swift:var:: ownerName: String

    owner name, if unresolvable defaults to stringified owner id

   .. swift:let:: group: gid_t

    group id

   .. swift:var:: groupName: String

    group name, if unresolvable defaults to stringified group id

   .. swift:let:: mode: FileMode

    mode

   .. swift:let:: size: UInt64

    file size

   .. swift:let:: type: FileType

    file type

   .. swift:let:: linkTarget: Path?

    path to original if this is a symlink

   .. swift:let:: mTime: Int

    modification timestamp

   .. swift:var:: modificationDate: Date

    modification date

   .. swift:let:: cTime: Int

    creation timestamp

   .. swift:var:: creationDate: Date

    creation date

   .. swift:let:: aTime: Int

    last access timestamp

   .. swift:var:: accessDate: Date

    last access date


