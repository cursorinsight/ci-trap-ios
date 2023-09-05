import Foundation

class TrapTime {
    private static var bootTime: Date?

    public static func normalizeTime(_ time: TimeInterval) -> Int64 {
        if bootTime == nil {
            // Query system boot time
            var tv = timeval()
            var tvSize = MemoryLayout<timeval>.size
            let err = sysctlbyname("kern.boottime", &tv, &tvSize, nil, 0)
            if err == 0, tvSize == MemoryLayout<timeval>.size {
                bootTime = Date(timeIntervalSince1970: Double(tv.tv_sec) + Double(tv.tv_usec) / 1_000_000.0)
            } else {
                debugPrint("Cannot load the system boot time for touch precision timestamp")
                bootTime = Date() - ProcessInfo().systemUptime
            }
        }

        return Int64((bootTime!.timeIntervalSince1970 + time) * 1000)
    }
}
