import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Scratchpad (Super+Shift+N, Apple menu → Scratchpad): one autosaved note, Markdown preview.
// ~/.local/share/macshell/scratchpad.md, saved 500 ms after typing stops and on close.
// Created per screen by MacBar.qml like KeybindsPanel.qml; only the focused screen shows it.
// ponytail: one note, no tabs; add tabs (one file each) if one page stops being enough
PanelWindow {
    id: sp

    property var bar: null
    property Component backdrop: null
    property bool focusedScreen: true
    default property alias glass: glassHost.data
    readonly property Item backdropItem: bdLoader.item
    readonly property bool shown: bar !== null && bar.scratchpadOpen && focusedScreen
    property bool preview: false

    readonly property real panelX: panel.x
    readonly property real panelY: panel.y
    readonly property real panelW: panel.width
    readonly property real panelH: panel.height
    readonly property real panelR: 28

    readonly property string dir: Quickshell.env("HOME") + "/.local/share/macshell"

    visible: shown || panel.opacity > 0
    anchors { left: true; right: true; top: true; bottom: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "macscratch"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onVisibleChanged: if (bar) bar.popCount += (visible ? 1 : -1)     // keeps the window-geometry poller running
    // every screen has its own copy: read the file again on open (another screen may have written it)
    onShownChanged: {
        if (shown) { note.reload(); if (!preview) editor.forceActiveFocus(); }
        else if (saveTimer.running) { saveTimer.stop(); save(); }
    }

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", dir])
    FileView {
        id: note
        path: sp.dir + "/scratchpad.md"
        blockLoading: true
        onLoaded: if (editor.text !== text()) editor.text = text()
    }
    Timer { id: saveTimer; interval: 500; onTriggered: sp.save() }
    function save() { if (note.text() !== editor.text) note.setText(editor.text); }

    Loader {
        id: bdLoader
        active: sp.bar !== null && sp.bar.liquidActive && sp.backdrop !== null
        sourceComponent: sp.backdrop
        onLoaded: {
            item.hostShown = Qt.binding(function () { return sp.visible; });
            item.region = Qt.binding(function () { return Qt.rect(panel.x - 96, panel.y - 96, panel.width + 192, panel.height + 192); });
        }
    }

    MouseArea { anchors.fill: parent; onPressed: sp.bar.scratchpadOpen = false }      // click outside closes

    Item {
        id: panel
        z: 10
        width: Math.min(620, sp.width - 120)
        height: Math.min(560, sp.height - 160)
        x: Math.round((sp.width - width) / 2)
        y: Math.round((sp.height - height) / 2)
        opacity: sp.shown ? 1 : 0
        visible: opacity > 0
        scale: sp.shown ? 1 : 0.96
        transformOrigin: Item.Center
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Item { id: glassHost; anchors.fill: parent }
        MenuBorder {
            z: 2
            anchors.fill: parent
            cornerR: sp.panelR
            dark: IslandStyle.theme.dark
            tint: sp.bar ? sp.bar.menuBorderColor : "#8A9AB5"
        }
        MouseArea { anchors.fill: parent }     // clicks inside stay inside

        Keys.onEscapePressed: event => { sp.bar.scratchpadOpen = false; event.accepted = true; }

        ColumnLayout {
            z: 3
            anchors.fill: parent
            anchors.margins: 22
            anchors.topMargin: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Scratchpad"
                    color: IslandStyle.theme.fg
                    font.family: IslandStyle.font(Font.DemiBold)
                    font.weight: Font.DemiBold
                    font.pixelSize: 15
                }
                Item { Layout.fillWidth: true }
                // Edit | Preview
                Repeater {
                    model: ["Edit", "Preview"]
                    Rectangle {
                        required property string modelData
                        required property int index
                        readonly property bool on: sp.preview === (index === 1)
                        implicitWidth: segText.implicitWidth + 20
                        implicitHeight: 24
                        radius: 7
                        color: on ? IslandStyle.alpha(IslandStyle.accent, 0.28) : segMa.containsMouse ? IslandStyle.theme.hover : "transparent"
                        Text {
                            id: segText
                            anchors.centerIn: parent
                            text: parent.modelData
                            color: IslandStyle.theme.fg
                            font.family: IslandStyle.fam
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: segMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: { sp.preview = parent.index === 1; if (sp.preview) panel.forceActiveFocus(); else editor.forceActiveFocus(); }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: IslandStyle.theme.tile
                border.width: 1
                border.color: editor.activeFocus ? IslandStyle.accent : IslandStyle.theme.tileBorder

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 4
                    visible: !sp.preview
                    TextArea {
                        id: editor
                        wrapMode: TextEdit.Wrap
                        color: IslandStyle.theme.fg
                        selectionColor: IslandStyle.accent
                        font.family: "monospace"
                        font.pixelSize: 13
                        placeholderText: "Notes, commands, anything. Saved as you type."
                        placeholderTextColor: IslandStyle.theme.fg3
                        background: null
                        onTextChanged: if (activeFocus) saveTimer.restart()
                        Keys.onEscapePressed: event => { sp.bar.scratchpadOpen = false; event.accepted = true; }
                    }
                }
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 12
                    visible: sp.preview
                    Text {
                        width: parent.width
                        text: editor.text
                        textFormat: Text.MarkdownText
                        wrapMode: Text.Wrap
                        color: IslandStyle.theme.fg
                        linkColor: IslandStyle.accent
                        font.family: IslandStyle.fam
                        font.pixelSize: 13
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }
                }
            }
        }
    }
}
