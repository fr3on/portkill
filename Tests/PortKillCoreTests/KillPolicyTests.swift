import Testing
@testable import PortKillCore

struct KillPolicyTests {
    let policy = KillPolicy(currentUID: 501, ownPID: 4242)

    private func port(pid: Int = 100, uid: UInt32 = 501, command: String = "node") -> ListeningPort {
        ListeningPort(port: 3000, pid: pid, command: command, uid: uid, user: "u")
    }

    @Test func allowsOrdinaryOwnProcess() {
        #expect(policy.readOnlyReason(for: port()) == nil)
    }

    @Test func protectsPIDZeroAndOne() {
        #expect(policy.readOnlyReason(for: port(pid: 0)) == .protectedPID)
        #expect(policy.readOnlyReason(for: port(pid: 1)) == .protectedPID)
    }

    @Test func protectsTheAppItself() {
        #expect(policy.readOnlyReason(for: port(pid: 4242)) == .ownProcess)
    }

    @Test func blocksOtherUsersAndRoot() {
        #expect(policy.readOnlyReason(for: port(uid: 0)) == .otherUser)
        #expect(policy.readOnlyReason(for: port(uid: 502)) == .otherUser)
    }

    @Test func blocksKnownSystemProcesses() {
        #expect(policy.readOnlyReason(for: port(command: "ControlCenter")) == .systemProcess)
    }

    @Test func hidesSystemAndOtherUserButNotProtectedRows() {
        #expect(policy.isSystemOrOtherUser(port(uid: 0)))
        #expect(policy.isSystemOrOtherUser(port(command: "rapportd")))
        #expect(!policy.isSystemOrOtherUser(port()))
    }

    @Test func killerRefusesReadOnlyProcessesWithoutSignalling() {
        let killer = ProcessKiller(policy: policy)
        #expect(throws: KillError.notAllowed(.otherUser)) {
            try killer.terminate(port(uid: 0))
        }
        #expect(throws: KillError.notAllowed(.protectedPID)) {
            try killer.forceKill(port(pid: 1))
        }
    }
}
