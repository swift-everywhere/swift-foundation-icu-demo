import _FoundationICU
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

print("Foundation ICU Tool!")

func isAcceptable(context: UnsafeMutableRawPointer?,
                 type: UnsafePointer<CChar>?,
                 name: UnsafePointer<CChar>?,
                 pInfo: UnsafePointer<UDataInfo>?) -> UBool {
    UBool(1) // always acceptable
}

// do not attempt to load from the file system
udata_setFileAccess(UDATA_NO_FILES, nil)

for ttype in ["dat", "icudt74l", "icu", "icudt", "res", "icu.icudt", "fr_FR"] {
    for name in ["icudt74l", "dat", "icu", "icudt", "res", "icu.icudt", "fr", "fr_FR", "", "."] {
        print("### trying ttype=\(ttype) name=\(name)")

        var status = U_ZERO_ERROR
        let icuData = udata_openChoice(U_ICUDATA_ALIAS, ttype, name, isAcceptable, nil, &status)

//        let rawData = udata_getMemory(icuData)
//        var rawInfo: UDataInfo = .init()
//        udata_getInfo(icuData, &rawInfo)

        //var size: size_t = icuDa

        print("data=\(icuData) opened type=\(ttype) name=\(name) with status \(status)")

        if let icuData {
            let length = udata_getLength(icuData)
            let raw = udata_getRawMemory(icuData)
            print("")
        }
    }
}

//let x = U_ICUDATA_ENTRY_POINT


//guard let sym = dlsym(handle, "gCommonICUDataArray") else {

//let handle = dlopen(nil, RTLD_NOW)
//defer { dlclose(handle) }
//
//let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
//
//let symbolPtr = dlsym(RTLD_DEFAULT, "udata_findCachedData")
//print("Loaded udata_findCachedData: \(symbolPtr)")


//udata_findCachedData

//udata_getMemory(nil)
