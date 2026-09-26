import Testing
@testable import PortKillCore

struct ProcessMemoryTests {
    @Test func parsesRSSFromPSOutput() {
        let out = "  49201       14:00  189440\n 50112    01:05:00    2048\ngarbage\n 7 10:00 notanumber\n"
        let memory = ProcessMemory.bytes(fromPS: out)
        #expect(memory[49201] == 189_440 * 1024)
        #expect(memory[50112] == 2048 * 1024)
        #expect(memory.count == 2)
    }

    @Test func formatsMemory() {
        #expect(ProcessMemory.format(nil) == nil)
        #expect(ProcessMemory.format(100 * 1024) == "<1 MB")
        #expect(ProcessMemory.format(142 * 1_048_576) == "142 MB")
        #expect(ProcessMemory.format(1_288_490_189) == "1.2 GB")
    }

    @Test func snippetsStayGraceful() {
        #expect(CommandSnippets.terminate(pid: 8123) == "kill 8123")
        #expect(CommandSnippets.listeners(port: 3000) == "lsof -nP -iTCP:3000 -sTCP:LISTEN")
    }
}
