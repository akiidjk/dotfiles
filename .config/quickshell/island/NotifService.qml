pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Notification centre backed by mako (like ~/.config/quickshell/hub/NotificationsCard.qml):
// polls `makoctl`, so it coexists with mako instead of fighting it for the dbus name.
Singleton {
    id: root
    readonly property alias model: notifModel

    ListModel { id: notifModel }
    property var _dismissed: ({})
    property var _seen: ({})
    property int unreadCount: 0

    function markAllRead() {
        for (let i = 0; i < notifModel.count; i++)
            root._seen[notifModel.get(i).nid] = true;
        root.unreadCount = 0;
    }

    function _sh(c) { return ["bash", "-lc", c]; }

    Process {
        id: proc
        command: root._sh("{ makoctl list; makoctl history; } 2>/dev/null || true")
        stdout: StdioCollector {
            id: out
            onStreamFinished: root._apply(root._parse(out.text))
        }
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    function _parse(raw) {
        const lines = String(raw ?? "").split("\n");
        const seen = ({});
        const items = [];
        for (let i = 0; i < lines.length; i++) {
            const m = lines[i].match(/^Notification\s+(\d+):\s*(.*)$/);
            if (!m)
                continue;
            const id = Number(m[1]);
            if (seen[id] || root._dismissed[id])
                continue;
            seen[id] = true;
            let app = "";
            for (let j = i + 1; j < Math.min(i + 10, lines.length); j++) {
                const a = lines[j].match(/^\s+App name:\s*(.+)$/);
                if (a) { app = a[1].trim(); break; }
                if (/^Notification\s+\d+:/.test(lines[j]))
                    break;
            }
            items.push({
                nid: id,
                app: app,
                summary: (m[2] || "").replace(/[⁦⁧⁨⁩]/g, "").trim()
            });
        }
        return items;
    }

    function _apply(items) {
        if (items.length === notifModel.count) {
            let same = true;
            for (let i = 0; i < items.length; i++)
                if (notifModel.get(i).nid !== items[i].nid || notifModel.get(i).summary !== items[i].summary) {
                    same = false;
                    break;
                }
            if (same)
                return;
        }
        notifModel.clear();
        for (const it of items)
            notifModel.append(it);
        let unread = 0;
        for (const it of items)
            if (!root._seen[it.nid])
                unread++;
        root.unreadCount = unread;
    }

    function dismiss(id, index) {
        root._dismissed[id] = true;
        if (index !== undefined && index >= 0 && index < notifModel.count)
            notifModel.remove(index);
        if (!root._seen[id])
            root.unreadCount = Math.max(0, root.unreadCount - 1);
        Quickshell.execDetached(root._sh("makoctl dismiss -n " + id + " >/dev/null 2>&1 || true"));
    }

    function clearAll() {
        for (let i = notifModel.count - 1; i >= 0; i--)
            root._dismissed[notifModel.get(i).nid] = true;
        notifModel.clear();
        root.unreadCount = 0;
        Quickshell.execDetached(root._sh("makoctl dismiss -a >/dev/null 2>&1 || true"));
    }
}
