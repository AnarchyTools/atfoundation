====================
Simple date handling
====================


.. swift:struct:: Date

   .. swift:let:: timestamp: Int

    Epoch timestamp (seconds since 1970-01-01)

   .. swift:var:: rfc822DateString: String?

    Return a RFC-822 date string

   .. swift:var:: isoDateString: String?

    Return a ISO-8601 date string

   .. swift:var:: second: Int32

    Second

   .. swift:var:: minute: Int32

    Minute

   .. swift:var:: hour: Int32

    Hour

   .. swift:var:: timeTuple: (hour: Int32, minute: Int32, second: Int32)

    Time tuple

   .. swift:var:: day: Int32

    Day (1-31)

   .. swift:var:: month: Int32

    Month (1-12)

   .. swift:var:: year: Int32

    Year

   .. swift:var:: weekDay: WeekDay

    Weekday

   .. swift:var:: dayOfYear: Int32

    Day of the year

   .. swift:var:: dateTuple: (year: Int32, month: Int32, day: Int32)

    Date tuple

   .. swift:init:: init(timestamp: Int)

    Simple initializer

    :parameter timestamp: Epoch timestamp (seconds since 1970-01-01)

   .. swift:init:: init(year: Int32, month: Int32 = 1, day: Int32 = 1, hour: Int32 = 0, minute: Int32 = 0, second: Int32 = 0)

    Initialize with exact date

    :parameter year: The year
    :parameter month: optional, the month (1-12!)
    :parameter day: optional, the day (1-31!)
    :parameter hour: optional, the hour (0-23)
    :parameter minute: optional, the minute (0-59)
    :parameter second: optional, the second (0-59)

   .. swift:init:: init(isoDateString: String)

    Initialize with ISO-8601 date string

    multiple variants for defining time zone are recognized

    :parameter isoDateString: date string to parse
    :returns: nil if string was not parseable

   .. swift:init:: init(rfc822DateString: String)

    Initialize with RFC-822 date string

    multiple variants for defining the time zone are recognized

    :parameter rfc822DateString: date string to parse
    :returns: nil if string was not parseable

   .. swift:init:: init(string: String, format: String)

    Initialize from string with a custom format.
    see C-Library documentation for strptime/strftime for examples

    :parameter string: string with date to parse
    :parameter format: format string that defines how to parse the string
    :returns: nil if string was not parseable

   .. swift:method:: now() -> Date

    Return current time/date

    :returns: Date() instance with current timestamp

   .. swift:method:: format(_ format: String) -> String?

    Format a date by defined format
    see C-Library documentation for strptime/strftime for examples

    :parameter format: format string
    :returns: formatted date or nil if format string was invalid

   .. swift:enum:: WeekDay : Int32

       .. swift:enum_case:: Sunday = 0


       .. swift:enum_case:: Monday = 1


       .. swift:enum_case:: Tuesday = 2


       .. swift:enum_case:: Wednesday = 3


       .. swift:enum_case:: Thursday = 4


       .. swift:enum_case:: Friday = 5


       .. swift:enum_case:: Saturday = 6




