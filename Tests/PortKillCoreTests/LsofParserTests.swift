import Foundation
import Testing
@testable import PortKillCore

private func fixture(_ name: String) throws -> String {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "txt", subdirectory: "Fixtures"))
    return try String(contentsOf: url, encoding: .utf8)
}

struct LsofParserTests {
    @Test func parsesEveryListenerAndSortsByPort() throws {
        let ports = LsofParser.parseListeningPorts(try fixture("lsof-listen"))
        #expect(ports.map(\.port) == [3000, 5000, 5353, 7000, 9222, 9229, 54870, 62118])
    }

    @Test func collapsesIPv4AndIPv6ListenersOnOnePID() throws {
        let ports = LsofParser.parseListeningPorts(try fixture("lsof-listen"))
        #expect(ports.filter { $0.pid == 49201 && $0.port == 3000 }.count == 1)
        #expect(ports.filter { $0.pid == 1328 && $0.port == 7000 }.count == 1)
    }

    @Test func keepsMultiplePortsForOnePID() throws {
        let ports = LsofParser.parseListeningPorts(try fixture("lsof-listen"))
        #expect(Set(ports.filter { $0.pid == 49201 }.map(\.port)) == [3000, 9229])
    }

    @Test func readsProcessFields() throws {
        let ports = LsofParser.parseListeningPorts(try fixture("lsof-listen"))
        let node = try #require(ports.first { $0.pid == 49201 })
        #expect(node.command == "node")
        #expect(node.uid == 501)
        #expect(node.user == "fr3on")
        let mdns = try #require(ports.first { $0.pid == 150 })
        #expect(mdns.uid == 0)
        #expect(mdns.user == "root")
    }

    @Test func decodesEscapedCommandNames() throws {
        let ports = LsofParser.parseListeningPorts(try fixture("lsof-listen"))
        let chrome = try #require(ports.first { $0.pid == 60010 })
        #expect(chrome.command == "Google Chrome Helper")
    }

    @Test func ignoresNamesWithoutAPort() throws {
        let ports = LsofParser.parseListeningPorts(try fixture("lsof-listen"))
        #expect(!ports.contains { $0.pid == 777 })
    }

    @Test func emptyOutputGivesNoPorts() {
        #expect(LsofParser.parseListeningPorts("").isEmpty)
    }

    @Test func portExtraction() {
        #expect(LsofParser.port(fromName: "*:8080") == 8080)
        #expect(LsofParser.port(fromName: "[fe80::1]:443") == 443)
        #expect(LsofParser.port(fromName: "no-colon") == nil)
    }
}
