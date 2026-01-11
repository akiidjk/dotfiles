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

    implicitHeight: cellHeight * 3 + 85
    implicitWidth: cellWidth * 5 + 20
    color: Qt.rgba(0.1, 0.1, 0.1, 0.2)

    focusable: true

    Column {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        property int cellWidth: root.cellWidth
        property int cellHeight: root.cellHeight

        // Grid of thumbnails
        Rectangle {
            width: parent.width
            height: parent.height - 65
            color: "transparent"
            radius: 16

            GridView {
                id: grid
                focus: true  // Enable keyboard focus
                anchors.fill: parent
                anchors.margins: 10

                model: FolderListModel {
                    id: folderModel
                    folder: "file://" + root.wallpaperDir
                    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.avif"]
                    showDirs: false
                }

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

                    Image {
                        id: thumbnail
                        anchors.fill: parent
                        anchors.margins: 3
                        source: "file://" + filePath
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        cache: true
                        asynchronous: true

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: grid.cellWidth - 6
                                height: grid.cellHeight - 6
                                radius: 10
                            }
                        }

                        // Show loading/error state
                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.error("Failed to load image:", model.path);
                            }
                        }
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            grid.currentIndex = index;
                            root.currentWallpaperPath = filePath;
                            console.log("Setting wallpaper to:", root.currentWallpaperPath);
                            Quickshell.execDetached(["/bin/sh", "-c", `matugen image -t scheme-fidelity -m dark "${filePath}" --show-colors --verbose --fallback-color "#000000" && cp "${filePath}" "${Quickshell.env("HOME")}/.current_wallpaper"`]);
                            event.accepted = true;
                        }
                    }

                    // Fallback for failed images
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: 10
                        color: Colors.surface
                        visible: thumbnail.status === Image.Error || thumbnail.status === Image.Null

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "󰋩"  // broken image icon
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

                    // Loading indicator
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: 10
                        color: Colors.surface
                        visible: thumbnail.status === Image.Loading

                        Text {
                            anchors.centerIn: parent
                            text: "󰔟"  // loading spinner icon
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 48
                            color: Colors.primary
                        }
                    }

                    // Border overlay - only shows on hover
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        color: "transparent"
                        border.width: mouseArea.containsMouse ? 3 : 0
                        border.color: Colors.primary
                        radius: 10
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            grid.currentIndex = index;
                            root.currentWallpaperPath = filePath;
                            console.log("Selected:", filePath);
                        }

                        onDoubleClicked: {
                            grid.currentIndex = index;
                            root.currentWallpaperPath = filePath;
                            console.log("Setting wallpaper to:", root.currentWallpaperPath);
                            Quickshell.execDetached(["/bin/sh", "-c", `matugen image -t scheme-fidelity -m dark "${filePath}" --show-colors --verbose --fallback-color "#000000" && cp "${filePath}" "${Quickshell.env("HOME")}/.current_wallpaper"`]);
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
                // Start swww-daemon if not running
                Quickshell.execDetached(["awww-daemon"]);
            }
        }
    }
}
