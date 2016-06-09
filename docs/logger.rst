===================
Customizable logger
===================


.. swift:protocol:: LoggerProcotol

   .. swift:var:: logFileAndLine: Bool

    Log file and line too?

   .. swift:var:: logDate: Bool

    Log current date, useful for permanent logfiles

   .. swift:method:: log(_ level: Log.LogLevel, _ msg: [Any], date: Date?, file: String?, line: Int?, function: String?)

    Primary function to log something


.. swift:extension:: LoggerProcotol

   .. swift:method:: log(_ level: Log.LogLevel, _ msg: [Any])

    Convenience override if you don't want to log the file and line info

    :parameter level: log severity
    :parameter msg: data to log

   .. swift:method:: log(_ level: Log.LogLevel, _ msg: [Any], file: String?, line: Int?, function: String?)

    Convenience override if you don't want to provide an explicit date

    :parameter level: log severity
    :parameter msg: data to log
    :parameter file: set to ``#file``
    :parameter line: set to ``#line``
    :parameter function: set to ``#function``


.. swift:class:: StdErrLogger : LoggerProcotol

   .. swift:var:: logFileAndLine: Bool = false

    Log file and line too?

   .. swift:var:: logDate: Bool = false

    Log current date, useful for permanent logfiles

   .. swift:method:: log(_ level: Log.LogLevel, _ msg: [Any], date: Date?, file: String?, line: Int?, function: String?)



.. swift:class:: StdOutLogger : LoggerProcotol

   .. swift:var:: logFileAndLine: Bool = false

    Log file and line too?

   .. swift:var:: logDate: Bool = false

    Log current date, useful for permanent logfiles

   .. swift:method:: log(_ level: Log.LogLevel, _ msg: [Any], date: Date?, file: String?, line: Int?, function: String?)



.. swift:class:: FileLogger : LoggerProcotol

   .. swift:var:: logFileAndLine: Bool = false

    Log file and line too?

   .. swift:var:: logDate: Bool = true

    Log current date, useful for permanent logfiles

   .. swift:var:: logFileName: Path? = nil

    Current log file name

   .. swift:init:: init(filename: Path) throws

    Initialize with filename

    :parameter filename: the file to write to
    :throws: ``SysError`` when the file cannot be opened

   .. swift:method:: reopenLog()

    Close and re-open log file (usually bound to a HUP UNIX Signal)

   .. swift:method:: log(_ level: Log.LogLevel, _ msg: [Any], date: Date?, file: String?, line: Int?, function: String?)



.. swift:class:: Log

   .. swift:static_var:: logger: LoggerProcotol = StdErrLogger()


   .. swift:static_var:: logLevel: LogLevel = .Debug

    Active log level

   .. swift:class_method:: debug(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function)

    Log a debug message

    :parameter msg: message or object to log, works like in print

   .. swift:class_method:: info(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function)

    Log an informal message

    :parameter msg: message or object to log, works like in print

   .. swift:class_method:: warn(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function)

    Log a warning message

    :parameter msg: message or object to log, works like in print

   .. swift:class_method:: error(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function)

    Log an error message

    :parameter msg: message or object to log, works like in print

   .. swift:class_method:: fatal(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function)

    Log a fatal message, program usually quits after these

    :parameter msg: message or object to log, works like in print

   .. swift:enum:: LogLevel : Int

       .. swift:enum_case:: Debug = 0


       .. swift:enum_case:: Info = 1


       .. swift:enum_case:: Warn = 2


       .. swift:enum_case:: Error = 3


       .. swift:enum_case:: Fatal = 4




