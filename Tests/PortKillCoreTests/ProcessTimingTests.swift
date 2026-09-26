import Foundation
import Testing
@testable import PortKillCore

struct ProcessTimingTests {
    @Test func parsesElapsedFormats() {
        #expect(ProcessTiming.elapsedSeconds("05") == 5)
        #expect(ProcessTiming.elapsedSeconds("14:03") == 843)
        #expect(ProcessTiming.elapsedSeconds("01:05:00") == 3900)
        #expect(ProcessTiming.elapsedSeconds("2-03:00:10") == 2 * 86_400 + 3 * 3600 + 10)
        #expect(ProcessTiming.elapsedSeconds("abc") == nil)
    }

    @Test func buildsStartDatesFromPSOutput() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let dates = ProcessTiming.startDates(fromPS: "  49201       14:00\n 50112    01:05:00\ngarbage\n", now: now)
        #expect(dates[49201] == now.addingTimeInterval(-840))
        #expect(dates[50112] == now.addingTimeInterval(-3900))
        #expect(dates.count == 2)
    }

    @Test func ignoresExtraColumnsAfterElapsedTime() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let dates = ProcessTiming.startDates(fromPS: "49201 14:00 189440\n", now: now)
        #expect(dates[49201] == now.addingTimeInterval(-840))
    }

    @Test func formatsUptime() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        #expect(ProcessTiming.format(uptime: now.addingTimeInterval(-30), now: now) == "30s")
        #expect(ProcessTiming.format(uptime: now.addingTimeInterval(-840), now: now) == "14m")
        #expect(ProcessTiming.format(uptime: now.addingTimeInterval(-3900), now: now) == "1h 05m")
        #expect(ProcessTiming.format(uptime: now.addingTimeInterval(-200_000), now: now) == "2d 7h")
        #expect(ProcessTiming.format(uptime: nil, now: now) == "–")
    }
}
