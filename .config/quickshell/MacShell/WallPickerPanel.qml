import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel

// Wallpaper picker (Super+W): 5 × 3 grid of MacBar's wallpaper folder, search, arrows, `/` or F to search,
// Enter / double-click applies. Applying goes through MacBar.wpApply(), i.e. its wallpaperCmd (matugen → awww →
// re-theme), and the glass + MacLock pick up the new picture straight away.
// Created per screen by MacBar.qml; the Liquid Glass slab is handed in as a child, like Island.qml.
PanelWindow {
    id: wp

    property var bar: null
    property Component backdrop: null
    property bool focusedScreen: true
    default property alias glass: glassHost.data
    readonly property Item backdropItem: bdLoader.item
    readonly property bool shown: bar !== null && bar.wallPickerOpen && focusedScreen

    readonly property real panelX: panel.x
    readonly property real panelY: panel.y
    readonly property real panelW: panel.width
    readonly property real panelH: panel.height
    readonly property real panelR: 28

    readonly property int cellW: 224
    readonly property int cellH: 152
    property string searchText: ""

    visible: shown || panel.opacity > 0
    anchors { left: true; right: true; top: true; bottom: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "macwallpick"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onVisibleChanged: if (bar) bar.popCount += (visible ? 1 : -1)     // keeps the window-geometry poller running
    onShownChanged: if (shown) { search.text = ""; rebuild(); grid.forceActiveFocus(); }

    function close() { bar.wallPickerOpen = false; }
    function apply(path) { if (path) bar.wpApply(path); }
    function rebuild() {
        filtered.clear();
        var q = searchText.trim().toLowerCase();
        for (var i = 0; i < folder.count; ++i) {
            var name = folder.get(i, "fileName"), path = folder.get(i, "filePath");
            if (!name || !path) continue;
            if (q === "" || name.toLowerCase().indexOf(q) !== -1) filtered.append({ fileName: name, filePath: path });
        }
        grid.currentIndex = filtered.count > 0 ? Math.max(0, Math.min(grid.currentIndex, filtered.count - 1)) : -1;
    }
    function move(delta) {
        if (filtered.count === 0) return;
        var next = grid.currentIndex < 0 ? 0 : grid.currentIndex + delta;
        grid.currentIndex = Math.max(0, Math.min(filtered.count - 1, next));
        grid.positionViewAtIndex(grid.currentIndex, GridView.Visible);
    }

    FolderListModel {
        id: folder
        folder: "file://" + (wp.bar ? wp.bar.wpDirEff : "")
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.avif"]
        showDirs: false
        onCountChanged: wp.rebuild()
    }
    ListModel { id: filtered }
    Timer { id: searchDebounce; interval: 120; onTriggered: wp.rebuild() }

    Loader {
        id: bdLoader
        active: wp.bar !== null && wp.bar.liquidActive && wp.backdrop !== null
        sourceComponent: wp.backdrop
        onLoaded: {
            item.hostShown = Qt.binding(function () { return wp.visible; });
            item.region = Qt.binding(function () { return Qt.rect(panel.x - 96, panel.y - 96, panel.width + 192, panel.height + 192); });
        }
    }

    MouseArea { anchors.fill: parent; onPressed: wp.close() }      // click outside closes

    Item {
        id: panel
        z: 10
        width: Math.min(wp.cellW * 5 + 44, wp.width - 80)
        height: Math.min(wp.cellH * 3 + 104, wp.height - 120)
        x: Math.round((wp.width - width) / 2)
        y: Math.round((wp.height - height) / 2)
        opacity: wp.shown ? 1 : 0
        visible: opacity > 0
        scale: wp.shown ? 1 : 0.96
        transformOrigin: Item.Center
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Item { id: glassHost; anchors.fill: parent }
        MenuBorder {
            z: 2
            anchors.fill: parent
            cornerR: wp.panelR
            dark: IslandStyle.dark
            tint: wp.bar ? wp.bar.menuBorderColor : "#8A9AB5"
        }
        MouseArea { anchors.fill: parent }     // clicks inside stay inside

        ColumnLayout {
            z: 3
            anchors.fill: parent
            anchors.margins: 18
            anchors.topMargin: 14
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                Text {
                    text: "Wallpapers"
                    color: IslandStyle.fg
                    font.family: IslandStyle.font(Font.DemiBold)
                    font.weight: Font.DemiBold
                    font.pixelSize: 15
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 10
                    color: IslandStyle.tile
                    border.width: 1
                    border.color: search.activeFocus ? IslandStyle.accent : IslandStyle.tileBorder
                    TextInput {
                        id: search
                        anchors.fill: parent
                        anchors.leftMargin: 12; anchors.rightMargin: 30
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        color: IslandStyle.fg
                        selectionColor: IslandStyle.accent
                        font.family: IslandStyle.fam
                        font.pixelSize: 13
                        onTextChanged: { wp.searchText = text; searchDebounce.restart(); }
                        Keys.onDownPressed: event => { grid.forceActiveFocus(); if (filtered.count > 0 && grid.currentIndex < 0) grid.currentIndex = 0; event.accepted = true; }
                        Keys.onReturnPressed: event => { if (grid.currentIndex >= 0) wp.apply(filtered.get(grid.currentIndex).filePath); event.accepted = true; }
                        Keys.onEnterPressed: event => { if (grid.currentIndex >= 0) wp.apply(filtered.get(grid.currentIndex).filePath); event.accepted = true; }
                        Keys.onEscapePressed: event => { if (text !== "") text = ""; else wp.close(); event.accepted = true; }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: search.text === ""
                            text: "Search wallpapers…"
                            color: IslandStyle.fg3
                            font: search.font
                        }
                    }
                    Text {
                        anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: search.text !== ""
                        text: "✕"
                        color: clearMa.containsMouse ? IslandStyle.fg : IslandStyle.fg3
                        font.pixelSize: 12
                        MouseArea { id: clearMa; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; onClicked: { search.text = ""; search.forceActiveFocus(); } }
                    }
                }
                Text {
                    text: filtered.count + " / " + folder.count
                    color: IslandStyle.fg3
                    font.family: IslandStyle.fam
                    font.pixelSize: 11
                }
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                focus: true
                model: filtered
                cellWidth: wp.cellW
                cellHeight: wp.cellH
                currentIndex: -1
                cacheBuffer: cellHeight * 2
                keyNavigationEnabled: false
                boundsBehavior: Flickable.StopAtBounds

                Keys.onLeftPressed: event => { wp.move(-1); event.accepted = true; }
                Keys.onRightPressed: event => { wp.move(1); event.accepted = true; }
                Keys.onUpPressed: event => { wp.move(-Math.max(1, Math.floor(grid.width / grid.cellWidth))); event.accepted = true; }
                Keys.onDownPressed: event => { wp.move(Math.max(1, Math.floor(grid.width / grid.cellWidth))); event.accepted = true; }
                Keys.onReturnPressed: event => { if (currentIndex >= 0) wp.apply(filtered.get(currentIndex).filePath); event.accepted = true; }
                Keys.onEnterPressed: event => { if (currentIndex >= 0) wp.apply(filtered.get(currentIndex).filePath); event.accepted = true; }
                Keys.onEscapePressed: event => { wp.close(); event.accepted = true; }
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Slash || event.key === Qt.Key_F) { search.forceActiveFocus(); event.accepted = true; }
                }

                delegate: Item {
                    id: cell
                    required property string fileName
                    required property string filePath
                    required property int index
                    readonly property bool selected: grid.currentIndex === index
                    readonly property bool current: wp.bar !== null && wp.bar.wallpaperPath === filePath
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        id: frame
                        anchors.fill: parent
                        anchors.margins: 5
                        radius: 14
                        color: "transparent"
                        border.width: cell.selected ? 2.5 : (ma.containsMouse ? 1.5 : 0)
                        border.color: cell.selected ? IslandStyle.accent : IslandStyle.tileBorder
                        scale: ma.pressed ? 0.97 : 1
                        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 2 } }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 10
                            clip: true
                            color: IslandStyle.tile

                            Image {
                                id: thumb
                                anchors.fill: parent
                                source: "file://" + cell.filePath
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                sourceSize.width: grid.cellWidth
                                sourceSize.height: grid.cellHeight
                                opacity: status === Image.Ready ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: IslandStyle.aMed } }
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: thumb.status === Image.Error
                                text: "Failed to load"
                                color: IslandStyle.fg3
                                font.family: IslandStyle.fam
                                font.pixelSize: 10
                            }
                            // "in use" check mark
                            Rectangle {
                                visible: cell.current
                                anchors.right: parent.right; anchors.top: parent.top
                                anchors.margins: 6
                                width: 20; height: 20; radius: 10
                                color: IslandStyle.accent
                                Text { anchors.centerIn: parent; text: "✓"; color: IslandStyle.accentFg; font.pixelSize: 12; font.bold: true }
                            }
                        }
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { grid.currentIndex = cell.index; grid.forceActiveFocus(); }
                        onDoubleClicked: { grid.currentIndex = cell.index; wp.apply(cell.filePath); }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: filtered.count === 0
                    text: wp.searchText.length > 0 ? "No wallpapers found" : "No wallpapers in " + (wp.bar ? wp.bar.wpDirEff : "")
                    color: IslandStyle.fg2
                    font.family: IslandStyle.fam
                    font.pixelSize: 12
                }
            }
        }
    }
}
