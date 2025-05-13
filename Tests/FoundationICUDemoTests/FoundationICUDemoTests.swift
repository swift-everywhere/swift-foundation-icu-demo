import XCTest
@testable import FoundationICUDemo
import _FoundationICU
#if canImport(Darwin)
import Darwin
#elseif canImport(Android)
import Android
#endif

class TestFoundationICUDemo: XCTestCase {
    func testICUFunctions() throws {
        //setenv("ICU_DATA_DIR_PREFIX", "/opt/src/github/skiptools/swift-foundation-icu-demo/LOCALE_DATA", 1)

        let defloc = uloc_getDefault()!

        XCTAssertEqual(String(validatingCString: defloc), "en_US_POSIX")
        XCTAssertEqual(uloc_getISO3Country(defloc).flatMap(String.init(validatingCString:)), "USA")

        let name = try withICUString(ULOC_FULLNAME_CAPACITY) { uloc_getName(defloc, $0, $1, $2) }
        XCTAssertEqual(name, "en_US_POSIX")
        let country = try withICUString(ULOC_COUNTRY_CAPACITY) { uloc_getCountry(defloc, $0, $1, $2) }
        XCTAssertEqual(country, "US")
        let language = try withICUString(ULOC_LANG_CAPACITY) { uloc_getLanguage(defloc, $0, $1, $2) }
        XCTAssertEqual(language, "en")

        //let testString = "This is a simple Test string"
        // seems to use a wide char
        //let upper = try withICUString(.init(testString.count)) { u_strToUpper($0, $1, testString, .init(testString.count), defloc, $2) }
        //XCTAssertEqual(upper, testString.uppercased())

        let numberUK = try formatNumber(locale: "en_UK", style: UNUM_DECIMAL, number: 1234.5678)
        XCTAssertEqual(numberUK, "1,234.568")

        let currencyUK = try formatNumber(locale: "en_UK", style: UNUM_CURRENCY, number: 1234.5678)
        XCTAssertEqual(currencyUK, "¤1,234.5")

        let spelloutUK = try formatNumber(locale: "en_UK", style: UNUM_SPELLOUT, number: 1234.5678)
        XCTAssertEqual(spelloutUK, "one thousand two hundred thirty-four point five six seven eight")

        let numberFR = try formatNumber(locale: "fr_FR", style: UNUM_DECIMAL, number: 1234.5678)
        XCTAssertEqual(numberFR, "1 234,5")

        let currencyFR = try formatNumber(locale: "fr_FR", style: UNUM_CURRENCY, number: 1234.5678)
        XCTAssertEqual(currencyFR, "1 234,57")

        let spelloutFR = try formatNumber(locale: "fr_FR", style: UNUM_SPELLOUT, number: 1234.5678)
        XCTAssertEqual(spelloutFR, "mille deux cent trente-quatre virgule cinq six sept huit")
    }
}

func formatNumber(locale: String, style: UNumberFormatStyle, number: Double) throws -> String? {
    let numberFormat = try tryICU { unum_open(style, nil, 0, locale, nil, $0) }
    defer { unum_close(numberFormat) }
    let result = try withICUWideString(1024) { unum_formatDouble(numberFormat, number, $0, $1, nil, $2) }
    return result
}

/// Try to perform an operation that might set an ICU `UErrorCode` pointer,
/// and throw an error if an error occurs.
func tryICU<T>(_ function: (_ err: UnsafeMutablePointer<UErrorCode>) -> T) throws -> T {
    var err = U_ZERO_ERROR
    let result = function(&err)
    if err.rawValue <= U_ZERO_ERROR.rawValue {
        return result
    } else {
        throw ICUError(errorCode: err)
    }
}

/// Allocates a buffer with the given capacity and executes the closure,
/// returning the result and deallocating the buffer.
func withAllocatedBuffer<T, U>(_ capacity: Int32, _ function: (_ buffer: UnsafeMutablePointer<T>, _ capacity: Int32, _ err: UnsafeMutablePointer<UErrorCode>) -> U) throws -> U {
    let buffer = UnsafeMutablePointer<T>.allocate(capacity: Int(capacity))
    defer { buffer.deallocate() }
    return try tryICU { function(buffer, capacity, $0) }
}

func withICUString(_ capacity: Int32 = 1024, _ function: (_ buffer: UnsafeMutablePointer<CChar>, _ capacity: Int32, _ err: UnsafeMutablePointer<UErrorCode>) -> Int32) throws -> String? {
    try withAllocatedBuffer(capacity) { buffer, capacity, err in
        _ = function(buffer, capacity, err)
        return String(validatingCString: buffer)
    }
}

func withICUWideString(_ capacity: Int32 = 1024, _ function: (_ buffer: UnsafeMutablePointer<UChar>, _ capacity: Int32, _ err: UnsafeMutablePointer<UErrorCode>) -> Int32) throws -> String? {
    try withAllocatedBuffer(capacity) { buffer, capacity, err in
        let bufferSize = function(buffer, capacity, err)
        // TODO: handle buffer overflow with U_BUFFER_OVERFLOW_ERROR by reallocating larger buffer?
        let buffer2 = UnsafeMutablePointer<CChar>.allocate(capacity: Int(bufferSize * 2))
        defer { buffer2.deallocate() }
        // convert the UChar into a C String
        return String(validatingCString: u_austrncpy(buffer2, buffer, bufferSize))
    }
}

struct ICUError : Error, CustomDebugStringConvertible {
    let errorCode: UErrorCode

    var debugDescription: String {
        if let desc = u_errorName(errorCode).flatMap(String.init(validatingCString:)) {
            return "UErrorCode \(errorCode.rawValue): \(desc)"
        } else {
            return "UErrorCode \(errorCode.rawValue)"
        }
    }
}
