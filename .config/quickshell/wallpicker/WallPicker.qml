import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../colors.js" as Colors

PanelWindow {
    id: root

    property int cellWidth: 224
    property int cellHeight: 152
    property string wallpaperDir: `${Quickshell.env("HOME")}/.config/wallpapers`
    property string currentWallpaperPath: ""
    property string searchText: ""

    implicitHeight: cellHeight * 3 + 130
    implicitWidth: cellWidth * 5 + 20
    color: Qt.rgba(0.1, 0.1, 0.1, 0.2)

    focusable: true

    function rebuildFilteredModel() {
        filteredModel.clear();

        let query = root.searchText.trim().toLowerCase();

        for (let i = 0; i < folderModel.count; ++i) {
            let name = folderModel.get(i, "fileName");
            let path = folderModel.get(i, "filePath");

            if (!name || !path)
                continue;
            if (query === "" || name.toLowerCase().indexOf(query) !== -1) {
                filteredModel.append({
                    fileName: name,
                    filePath: path
                });
            }
        }

        if (filteredModel.count > 0) {
            if (grid.currentIndex < 0 || grid.currentIndex >= filteredModel.count)
                grid.currentIndex = 0;
        } else {
            grid.currentIndex = -1;
        }
    }

    function setWallpaper(filePath, verbose) {
        root.currentWallpaperPath = filePath;
        console.log("Setting wallpaper to:", root.currentWallpaperPath);

        let cmd = verbose ? `matugen image -t scheme-fidelity -m dark --source-color-index 0 "${filePath}" --show-colors --verbose --fallback-color "#000000" && cp "${filePath}" "${Quickshell.env("HOME")}/.current_wallpaper"` : `matugen image -t scheme-fidelity --source-color-index 0 -m dark "${filePath}" --fallback-color "#000000" && cp "${filePath}" "${Quickshell.env("HOME")}/.current_wallpaper"`;

        Quickshell.execDetached(["/bin/sh", "-c", cmd]);
    }

    function moveSelection(delta) {
        if (filteredModel.count === 0)
            return;
        let next = grid.currentIndex + delta;

        if (grid.currentIndex < 0)
            next = 0;

        next = Math.max(0, Math.min(filteredModel.count - 1, next));
        grid.currentIndex = next;
        grid.positionViewAtIndex(next, GridView.Visible);
    }

    function moveSelectionVertical(deltaRows) {
        if (filteredModel.count === 0)
            return;
        let columns = Math.max(1, Math.floor(grid.width / grid.cellWidth));
        let next = grid.currentIndex + (deltaRows * columns);

        if (grid.currentIndex < 0)
            next = 0;

        next = Math.max(0, Math.min(filteredModel.count - 1, next));
        grid.currentIndex = next;
        grid.positionViewAtIndex(next, GridView.Visible);
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + root.wallpaperDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.avif"]
        showDirs: false

        onCountChanged: root.rebuildFilteredModel()
    }

    ListModel {
        id: filteredModel
    }

    Timer {
        id: searchDebounce
        interval: 120
        repeat: false
        onTriggered: root.rebuildFilteredModel()
    }

    Component.onCompleted: {
        root.rebuildFilteredModel();
        awwwCheck.running = true;
        grid.forceActiveFocus();
    }

    Column {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        property int cellWidth: root.cellWidth
        property int cellHeight: root.cellHeight

        Rectangle {
            width: parent.width
            height: 55
            color: "transparent"
            z: 10

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                height: 40
                radius: 12
                color: Colors.surface

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰍉"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: Colors.on_secondary
                    }

                    TextField {
                        id: searchField
                        width: parent.width - 70
                        height: parent.height
                        text: root.searchText
                        placeholderText: "Search wallpapers..."
                        color: Colors.on_secondary
                        placeholderTextColor: Colors.on_secondary
                        font.family: "MapleMono NF"
                        font.pixelSize: 12
                        background: null
                        selectByMouse: true

                        onTextChanged: {
                            root.searchText = text;
                            searchDebounce.restart();
                        }

                        Keys.onDownPressed: event => {
                            grid.forceActiveFocus();
                            if (filteredModel.count > 0 && grid.currentIndex < 0)
                                grid.currentIndex = 0;
                            event.accepted = true;
                        }

                        Keys.onReturnPressed: event => {
                            if (filteredModel.count > 0 && grid.currentIndex >= 0) {
                                root.setWallpaper(filteredModel.get(grid.currentIndex).filePath, false);
                            }
                            event.accepted = true;
                        }

                        Keys.onEnterPressed: event => {
                            if (filteredModel.count > 0 && grid.currentIndex >= 0) {
                                root.setWallpaper(filteredModel.get(grid.currentIndex).filePath, false);
                            }
                            event.accepted = true;
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: searchField.text.length > 0
                        text: "󰅖"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: Colors.on_secondary

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchField.clear();
                                searchField.forceActiveFocus();
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height - 55
            color: "transparent"
            radius: 16
            clip: true

            GridView {
                id: grid
                focus: true
                anchors.fill: parent
                anchors.margins: 10

                model: filteredModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: 8
                        radius: 4
                        color: Colors.primary
                    }
                }

                cellWidth: 224
                cellHeight: 152
                currentIndex: -1
                cacheBuffer: cellHeight * 2
                keyNavigationEnabled: false

                Keys.onLeftPressed: event => {
                    root.moveSelection(-1);
                    event.accepted = true;
                }

                Keys.onRightPressed: event => {
                    root.moveSelection(1);
                    event.accepted = true;
                }

                Keys.onUpPressed: event => {
                    root.moveSelectionVertical(-1);
                    event.accepted = true;
                }

                Keys.onDownPressed: event => {
                    root.moveSelectionVertical(1);
                    event.accepted = true;
                }

                Keys.onReturnPressed: event => {
                    if (grid.currentIndex >= 0) {
                        root.setWallpaper(filteredModel.get(grid.currentIndex).filePath, false);
                    }
                    event.accepted = true;
                }

                Keys.onEnterPressed: event => {
                    if (grid.currentIndex >= 0) {
                        root.setWallpaper(filteredModel.get(grid.currentIndex).filePath, false);
                    }
                    event.accepted = true;
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Slash || event.key === Qt.Key_F) {
                        searchField.forceActiveFocus();
                        event.accepted = true;
                    }
                }

                delegate: Rectangle {
                    required property string fileName
                    required property string filePath
                    required property int index

                    width: grid.cellWidth - 8
                    height: grid.cellHeight - 8
                    color: "transparent"
                    radius: 8
                    clip: true

                    border.width: grid.currentIndex === index ? 3 : 0
                    border.color: grid.currentIndex === index ? Colors.primary : "transparent"

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: 10
                        clip: true
                        color: Colors.surface

                        Image {
                            id: thumbnail
                            anchors.fill: parent
                            source: "file://" + filePath
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            cache: true
                            asynchronous: true
                            sourceSize.width: grid.cellWidth
                            sourceSize.height: grid.cellHeight

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.error("Failed to load image:", filePath);
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: Colors.surface
                            visible: thumbnail.status === Image.Error || thumbnail.status === Image.Null

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "󰋩"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 48
                                    color: Colors.on_secondary
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Failed to load"
                                    font.family: "MapleMono NF"
                                    font.pixelSize: 10
                                    color: Colors.on_secondary
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: Colors.surface
                            visible: thumbnail.status === Image.Loading

                            Text {
                                anchors.centerIn: parent
                                text: "󰔟"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 48
                                color: Colors.primary
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: mouseArea.containsMouse ? 3 : 0
                            border.color: Colors.primary
                            radius: 10
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            grid.currentIndex = index;
                            root.currentWallpaperPath = filePath;
                            grid.forceActiveFocus();
                            console.log("Selected:", filePath);
                        }

                        onDoubleClicked: {
                            grid.currentIndex = index;
                            grid.forceActiveFocus();
                            root.setWallpaper(filePath, true);
                        }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 220
                    height: 90
                    radius: 12
                    color: Colors.surface
                    visible: filteredModel.count === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "󰍉"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 30
                            color: Colors.on_secondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: root.searchText.length > 0 ? "No wallpapers found" : "No wallpapers"
                            font.family: "MapleMono NF"
                            font.pixelSize: 10
                            color: Colors.on_secondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }

    Process {
        id: awwwCheck
        running: false
        command: ["pgrep", "-x", "awww-daemon"]

        onExited: (code, status) => {
            if (code !== 0) {
                Quickshell.execDetached(["awww-daemon"]);
            }
        }
    }
}
