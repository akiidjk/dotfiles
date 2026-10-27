// MacLock for SDDM: the MacLock lock screen (quickshell/MacLock/LockScreen.qml) as the login screen.
// Same backdrop, glass clock, avatar and password pill; PAM becomes sddm.login(), and the parts that need a
// running session (Now Playing, lyrics, notifications, Wi-Fi) are left out. Session and power controls are added.
//
// Not self-contained in the repo: maclock-sddm.sh (hypr-macshell/scripts) builds the installable theme by adding
// MacLock's Glass / ContourGlow / MorphText, the shaders, the fonts, the fixed background and a theme.conf written
// from MacShell → Settings → Lock Screen → Login Screen.
import QtQuick
import QtQuick.Effects

Item {
    id: ls
    width: 1920; height: 1080
    readonly property real u: Math.max(0.6, height / 1200)   // layout unit, 1.0 on a 1200 px tall screen
    readonly property string fam: uiFont.status === FontLoader.Ready ? uiFont.name : "sans-serif"
    // SDDM gives every screen its own copy of this file; only the primary one gets the login column
    readonly property bool isPrimary: typeof primaryScreen === "undefined" || primaryScreen

    FontLoader { id: uiFont; source: "fonts/OpenRunde-Regular.otf" }
    FontLoader { source: "fonts/OpenRunde-Semibold.otf" }

    function cfgBool(v, def) { return v === undefined || v === "" ? def : (v === true || String(v) === "true"); }
    function cfgNum(v, def) { var n = Number(v); return v === undefined || v === "" || isNaN(n) ? def : n; }

    // ── state (what shell.qml's lockState held) ──
    property var now: new Date()
    property string pass: ""
    property bool busy: false
    property int fails: 0
    property string message: ""
    property bool engaged: false
    property bool shown: false
    property bool leaving: false
    readonly property bool use24h: cfgBool(config.use24h, true)
    readonly property bool showPower: cfgBool(config.showPower, true)
    readonly property bool showSessions: cfgBool(config.showSessions, true)
    readonly property bool capsLock: typeof keyboard !== "undefined" && keyboard.capsLock

    property int userIdx: Math.max(0, userModel.lastIndex)
    property int sessionIdx: Math.max(0, sessionModel.lastIndex)
    readonly property var user: users.count > 0 ? users.itemAt(userIdx) : null
    readonly property string userLogin: user ? user.login : userModel.lastUser
    readonly property string userName: user && user.real !== "" ? user.real : userLogin
    readonly property string avatar: user ? user.icon : ""
    readonly property var session: sessions.count > 0 ? sessions.itemAt(sessionIdx) : null

    function poke() { engaged = true; idleTimer.restart(); }
    function submit() {
        if (busy || leaving || pass.length === 0) return;
        busy = true;
        message = "";
        sddm.login(userLogin, pass, sessionIdx);
    }
    Connections {
        target: sddm
        function onLoginSucceeded() { ls.busy = false; ls.leaving = true; }
        function onLoginFailed() { ls.busy = false; ls.pass = ""; ls.message = "Incorrect password"; ls.fails++; msgTimer.restart(); }
    }

    // userModel / sessionModel only expose their data through delegates (a Repeater builds every one of them)
    Repeater { id: users; model: userModel; delegate: Item { required property string name; required property string realName; required property string icon
        readonly property string login: name; readonly property string real: realName } }
    Repeater { id: sessions; model: sessionModel; delegate: Item { required property string name; readonly property string title: name } }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: ls.now = new Date() }
    Timer { id: idleTimer; interval: 9000; onTriggered: if (ls.pass.length === 0 && !ls.busy) ls.engaged = false }
    Timer { id: msgTimer; interval: 3500; onTriggered: ls.message = "" }
    Timer { interval: 450; running: true; onTriggered: ls.shown = true }
    Connections { target: wall; function onStatusChanged() { if (wall.status === Image.Ready || wall.status === Image.Error) ls.shown = true; } }

    focus: true
    Component.onCompleted: forceActiveFocus()

    // ═════════════ BACKDROP ═════════════
    Rectangle { anchors.fill: parent; color: "#0b0b10" }
    Item {
        id: scene
        anchors.fill: parent
        opacity: ls.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 650; easing.type: Easing.OutQuint } }
        Image {
            id: wall
            anchors.fill: parent
            source: config.background ? config.background : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true; smooth: true
            sourceSize.width: Math.max(1, Math.min(ls.width * 1.15, 2560))
            scale: ls.leaving ? 1.06 : (ls.shown ? 1.0 : 1.09)
            Behavior on scale { NumberAnimation { duration: 650; easing.type: Easing.OutQuint } }
        }
        // the wallpaper softens while you are entering the password
        MultiEffect {
            source: wall; anchors.fill: wall; scale: wall.scale
            blurEnabled: true; blurMax: 48
            blur: ls.engaged ? 0.55 : 0.0
            opacity: ls.engaged ? 1 : 0
            visible: opacity > 0.002
            Behavior on blur { NumberAnimation { duration: 650; easing.type: Easing.OutQuint } }
            Behavior on opacity { NumberAnimation { duration: 650; easing.type: Easing.OutQuint } }
        }
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.22) }
                GradientStop { position: 0.35; color: Qt.rgba(0, 0, 0, 0.0) }
                GradientStop { position: 0.72; color: Qt.rgba(0, 0, 0, 0.0) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.30) }
            }
        }
    }
    // shared, pre-blurred copy of the scene that the glass slabs and the clock refract
    ShaderEffectSource {
        id: sceneTex
        sourceItem: scene; visible: false
        textureSize: Qt.size(Math.max(1, Math.round(ls.width / 2)), Math.max(1, Math.round(ls.height / 2)))
    }
    MultiEffect {
        id: sceneBlurFx
        source: sceneTex
        width: sceneTex.textureSize.width; height: sceneTex.textureSize.height
        blurEnabled: true; blurMax: 32; blur: 0.35
        autoPaddingEnabled: false; visible: false
    }
    ShaderEffectSource { id: glassTex; sourceItem: sceneBlurFx; mipmap: true; visible: false }

    // ═════════════ CLOCK ═════════════ (Settings → Lock Screen → Clock, copied into theme.conf)
    readonly property string ckFont: ["rounded", "serif", "inter"].indexOf(config.clockFont) >= 0 ? config.clockFont : "rounded"
    readonly property string ckWant: ckFont === "serif" ? "Noto Serif Display" : (ckFont === "inter" ? "Open Runde" : "Nunito")
    readonly property bool ckFontOk: Qt.fontFamilies().indexOf(ckWant) >= 0
    readonly property string ckFamily: ckFontOk ? ckWant : fam
    readonly property int ckWeight: Math.max(100, Math.min(1000, cfgNum(config.clockWeight, 680)))
    readonly property bool ckGlass: config.clockMaterial !== "solid"
    readonly property real ckIntensity: Math.max(0, Math.min(1, cfgNum(config.clockIntensity, ckGlass ? 0.6 : 0.8)))
    readonly property color ckTint: config.clockTint ? config.clockTint : "#FFFFFF"
    readonly property bool ckShortDate: config.clockDate === "short"
    readonly property real clockPx: (ckFont === "serif" ? 168 : (ckFont === "rounded" ? 176 : 172)) * (ckWeight < 330 ? 1.12 : 1.0) * u

    // the light on the glass follows the pointer; rests at the top-left
    HoverHandler { id: lightHover }
    property real lightX: -0.6
    property real lightY: -0.8
    Behavior on lightX { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on lightY { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Timer {
        interval: 80; repeat: true; running: lightHover.hovered && ls.ckGlass && ls.isPrimary
        onTriggered: {
            var c = clock.mapToItem(ls, clock.width / 2, clock.height / 2);
            var dx = c.x - lightHover.point.position.x, dy = c.y - lightHover.point.position.y;
            var l = Math.sqrt(dx * dx + dy * dy) || 1;
            ls.lightX = -dx / l; ls.lightY = Math.min(-0.25, -dy / l);
        }
    }

    Item {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        y: (ls.shown && !ls.leaving ? 0.075 : 0.035) * ls.height
        width: Math.max(dateTxt.implicitWidth, timeItem.width)
        height: dateTxt.implicitHeight + timeItem.y - dateTxt.height + timeItem.height
        opacity: ls.shown && !ls.leaving ? 1 : 0
        Behavior on y { NumberAnimation { duration: ls.leaving ? 420 : 650; easing.type: Easing.OutQuint } }
        Behavior on opacity { NumberAnimation { duration: ls.leaving ? 300 : 650; easing.type: Easing.OutQuint } }

        MorphText {
            id: dateTxt
            horizontalAlignment: Text.AlignHCenter
            renderType: Text.NativeRendering
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.locale("en_US").toString(ls.now, ls.ckShortDate ? "ddd MMM d" : "dddd, MMMM d")
            color: Qt.rgba(1, 1, 1, 0.92)
            font.family: ls.ckFont === "serif" && ls.ckFontOk ? "Noto Serif Display" : ls.fam
            font.pixelSize: (ls.ckShortDate ? 23 : 25) * ls.u; font.weight: Font.DemiBold
            layer.enabled: true
            layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.6; shadowOpacity: 0.25; shadowVerticalOffset: 1 }
        }

        // big translucent glass clock: the text is a mask, glasstext.frag refracts the wallpaper through it
        Item {
            id: timeItem
            anchors.top: dateTxt.bottom
            anchors.topMargin: -14 * ls.u
            anchors.horizontalCenter: parent.horizontalCenter
            width: timeTxt.implicitWidth + 40
            height: timeTxt.implicitHeight
            readonly property real mp: Math.max(48 * ls.u, ls.clockPx * 0.5)
            MorphText {
                id: timeTxt
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                duration: 560
                useBlur: false; animateWidth: false; stretch: false
                scaleIn: 1.03; scaleOut: 0.97
                text: ls.use24h ? Qt.formatTime(ls.now, "H:mm") : ((ls.now.getHours() % 12) || 12) + Qt.formatTime(ls.now, ":mm")
                color: "white"
                font.family: ls.ckFamily; font.pixelSize: ls.clockPx; font.weight: Font.Bold
                font.variableAxes: ({ "wght": ls.ckWeight })
                font.letterSpacing: (ls.ckWeight < 330 ? 0 : -1.5) * ls.u
                renderType: Text.QtRendering
                visible: false
            }
            ShaderEffectSource {
                id: timeMaskRaw
                sourceItem: timeTxt; hideSource: true; visible: false; smooth: true
                sourceRect: Qt.rect(-timeItem.mp, -timeItem.mp, timeTxt.width + 2 * timeItem.mp, timeTxt.height + 2 * timeItem.mp)
            }
            MultiEffect {
                id: timeMaskFx
                width: timeMaskRaw.sourceRect.width; height: timeMaskRaw.sourceRect.height
                source: timeMaskRaw
                blurEnabled: true; blurMax: 48; blur: timeTxt.morphBlur
                autoPaddingEnabled: false; visible: false
            }
            ShaderEffectSource { id: timeMask; sourceItem: timeMaskFx; visible: false; smooth: true }
            MultiEffect {
                id: timeHeightFx
                width: timeMaskFx.width; height: timeMaskFx.height
                source: timeMask
                blurEnabled: true; blurMax: 16
                blur: Math.max(0.12, Math.min(0.6, ls.clockPx * (ls.ckWeight < 330 ? 0.02 : 0.04) / 16))
                autoPaddingEnabled: false; visible: false
            }
            ShaderEffectSource { id: timeHeight; sourceItem: timeHeightFx; visible: false; smooth: true }
            MultiEffect {
                x: timeTxt.x - timeItem.mp; y: timeTxt.y - timeItem.mp + 8 * ls.u
                width: timeMaskFx.width; height: timeMaskFx.height
                source: timeMask
                blurEnabled: true; blurMax: 64; blur: 1.0
                colorization: 1.0; colorizationColor: "black"; brightness: -1.0
                opacity: ls.ckGlass ? 0.22 : 0.12
            }
            ShaderEffect {
                id: timeGlass
                x: timeTxt.x - timeItem.mp; y: timeTxt.y - timeItem.mp
                width: timeMaskFx.width; height: timeMaskFx.height
                fragmentShader: Qt.resolvedUrl("glasstext.frag.qsb")
                readonly property point fp: { ls.clockPx; clock.y; clock.x; timeItem.x; timeTxt.x; timeTxt.width; return timeGlass.mapToItem(ls, 0, 0); }
                property variant src: glassTex
                property variant mask: timeMask
                property variant hmap: timeHeight
                property vector2d itemSize: Qt.vector2d(width, height)
                property vector2d srcSize: Qt.vector2d(ls.width, ls.height)
                property vector2d srcOffset: Qt.vector2d(fp.x, fp.y)
                property real mode: ls.ckGlass ? 1 : 0
                property real intensity: ls.ckGlass ? ls.ckIntensity : 0.55 + 0.4 * ls.ckIntensity
                property real refract: (6 + 4 * (1 - ls.ckIntensity)) * ls.u
                property real bevel: 4.5
                property color tint: ls.ckTint
                property vector2d lightDir: Qt.vector2d(ls.lightX, ls.lightY)
            }
            Text {
                visible: timeGlass.status === ShaderEffect.Error
                anchors.fill: timeTxt
                text: timeTxt.text; font: timeTxt.font
                horizontalAlignment: Text.AlignHCenter
                color: Qt.rgba(1, 1, 1, 0.85)
            }
        }
    }

    // ═════════════ USER + PASSWORD (bottom) ═════════════
    Column {
        id: login
        visible: ls.isPrimary
        anchors.horizontalCenter: parent.horizontalCenter
        y: ls.height - height - (ls.shown && !ls.leaving ? 78 : 30) * ls.u - (ls.showPower ? 64 * ls.u : 0)
        opacity: ls.shown && !ls.leaving ? 1 : 0
        spacing: 10 * ls.u
        Behavior on y { NumberAnimation { duration: ls.leaving ? 380 : 650; easing.type: Easing.OutQuint } }
        Behavior on opacity { NumberAnimation { duration: ls.leaving ? 260 : 650; easing.type: Easing.OutQuint } }

        // avatar
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 70 * ls.u; height: width
            scale: ls.engaged ? 1.0 : 0.94
            Behavior on scale { NumberAnimation { duration: 650; easing.type: Easing.OutQuint } }
            Rectangle {
                anchors.fill: parent; radius: width / 2
                color: Qt.rgba(1, 1, 1, 0.16)
                Text {
                    anchors.centerIn: parent
                    visible: avatarImg.status !== Image.Ready
                    text: (ls.userName || "?").charAt(0).toUpperCase()
                    color: "white"; font.family: ls.fam; font.pixelSize: 30 * ls.u; font.weight: Font.DemiBold
                }
            }
            Item {
                id: avMask
                anchors.fill: parent; visible: false
                layer.enabled: true; layer.smooth: true
                Rectangle { anchors.fill: parent; radius: width / 2; color: "black" }
            }
            Image {
                id: avatarImg
                anchors.fill: parent
                source: ls.avatar !== "" ? (ls.avatar.indexOf("/") === 0 ? "file://" + ls.avatar : ls.avatar) : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true; smooth: true; mipmap: true
                sourceSize: Qt.size(256, 256)
                layer.enabled: true; layer.smooth: true
                layer.effect: MultiEffect { maskEnabled: true; maskSource: avMask; maskThresholdMin: 0.5; maskSpreadAtMin: 1.0 }
            }
            Rectangle {
                anchors.fill: parent; radius: width / 2; color: "transparent"
                border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.22)
            }
        }

        // name; with more than one user, clicking it picks the next one
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ls.userName
            color: "white"; font.family: ls.fam; font.pixelSize: 15 * ls.u; font.weight: Font.DemiBold
            layer.enabled: true
            layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.5; shadowOpacity: 0.3; shadowVerticalOffset: 1 }
            MouseArea {
                anchors.fill: parent
                enabled: users.count > 1
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: { ls.userIdx = (ls.userIdx + 1) % users.count; ls.pass = ""; }
            }
        }

        // password pill
        Item {
            id: pwBox
            anchors.horizontalCenter: parent.horizontalCenter
            width: (ls.pass.length > 0 || ls.engaged ? 236 : 210) * ls.u
            height: 36 * ls.u
            Behavior on width { NumberAnimation { duration: 450; easing.type: Easing.OutQuint } }
            readonly property bool pressed: pwMa.pressed || ls.enterHeld
            transform: [
                Translate { id: shakeT; x: 0 },
                Scale {
                    origin.x: pwBox.width / 2; origin.y: pwBox.height / 2
                    xScale: pwBox.pressed ? 1.045 : 1.0
                    yScale: pwBox.pressed ? 0.86 : 1.0
                    Behavior on xScale { NumberAnimation { duration: pwBox.pressed ? 140 : 420; easing.type: Easing.OutQuint } }
                    Behavior on yScale { NumberAnimation { duration: pwBox.pressed ? 140 : 420; easing.type: Easing.OutQuint } }
                }
            ]
            SequentialAnimation {
                id: shake
                NumberAnimation { target: shakeT; property: "x"; to: -16 * ls.u; duration: 55; easing.type: Easing.OutQuint }
                NumberAnimation { target: shakeT; property: "x"; to: 14 * ls.u; duration: 80; easing.type: Easing.InOutQuad }
                NumberAnimation { target: shakeT; property: "x"; to: -10 * ls.u; duration: 75; easing.type: Easing.InOutQuad }
                NumberAnimation { target: shakeT; property: "x"; to: 7 * ls.u; duration: 70; easing.type: Easing.InOutQuad }
                NumberAnimation { target: shakeT; property: "x"; to: -3 * ls.u; duration: 65; easing.type: Easing.InOutQuad }
                NumberAnimation { target: shakeT; property: "x"; to: 0; duration: 90; easing.type: Easing.OutQuint }
            }
            Connections { target: ls; function onFailsChanged() { shake.restart(); } }

            Glass {
                anchors.fill: parent
                src: glassTex; frame: ls
                cornerR: height / 2; thickness: 18; tint: 0.50; shadowAmt: 0.4
            }
            MouseArea {
                id: pwMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                onPressed: { ls.forceActiveFocus(); ls.poke(); }
            }
            ContourGlow {
                cornerR: pwBox.height / 2
                hovered: pwMa.containsMouse || pwBox.pressed
                boost: pwBox.pressed ? 1.6 : 1.0
                at: pwMa.containsMouse ? Qt.point(pwMa.mouseX, pwMa.mouseY) : Qt.point(pwBox.width / 2, 0)
                glowColor: "white"
            }
            Text {
                anchors.left: parent.left; anchors.leftMargin: 16 * ls.u
                anchors.verticalCenter: parent.verticalCenter
                text: "Enter Password"
                color: Qt.rgba(1, 1, 1, 0.62)
                font.family: ls.fam; font.pixelSize: 14 * ls.u
                opacity: ls.pass.length === 0 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 140 } }
            }
            // password dots: one entry per character, so only the dot you just typed (or deleted) animates
            ListModel { id: dotModel }
            function syncDots() {
                var want = ls.pass.length, alive = 0, i;
                for (i = 0; i < dotModel.count; i++) if (!dotModel.get(i).dying) alive++;
                while (alive < want) { dotModel.append({ dying: false }); alive++; }
                for (i = dotModel.count - 1; i >= 0 && alive > want; i--)
                    if (!dotModel.get(i).dying) { dotModel.setProperty(i, "dying", true); alive--; }
            }
            Connections { target: ls; function onPassChanged() { pwBox.syncDots(); } }
            Item {
                anchors.left: parent.left; anchors.leftMargin: 16 * ls.u
                anchors.right: ls.capsLock ? capsIcon.left : goBtn.left; anchors.rightMargin: 8 * ls.u
                anchors.verticalCenter: parent.verticalCenter
                height: 12 * ls.u
                clip: true
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.min(0, parent.width - width)
                    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Repeater {
                        model: dotModel
                        delegate: Item {
                            id: dotCell
                            required property bool dying
                            property real grow: 0
                            width: 12 * ls.u * grow; height: 12 * ls.u
                            Component.onCompleted: grow = 1
                            onDyingChanged: if (dying) { grow = 0; dotGone.start(); }
                            Behavior on grow { NumberAnimation { duration: dotCell.dying ? 200 : 240; easing.type: Easing.OutCubic } }
                            Rectangle {
                                x: 2.5 * ls.u; anchors.verticalCenter: parent.verticalCenter
                                width: 7 * ls.u; height: width; radius: width / 2
                                color: "white"
                                opacity: dotCell.grow
                                scale: 0.35 + 0.65 * dotCell.grow
                            }
                            Timer { id: dotGone; interval: 230; onTriggered: { for (var i = dotModel.count - 1; i >= 0; i--) if (dotModel.get(i).dying) { dotModel.remove(i); break; } } }
                        }
                    }
                }
            }
            // Caps Lock indicator, macOS style
            Item {
                id: capsIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: goBtn.on ? goBtn.left : parent.right
                anchors.rightMargin: goBtn.on ? 6 * ls.u : 12 * ls.u
                width: 18 * ls.u; height: width
                opacity: ls.capsLock ? 0.9 : 0
                scale: ls.capsLock ? 1 : 0.5
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }
                Canvas {
                    anchors.fill: parent
                    onWidthChanged: requestPaint()
                    onPaint: {
                        var c = getContext("2d"); c.reset();
                        var s = width / 18;
                        c.scale(s, s);
                        c.strokeStyle = "white"; c.lineWidth = 1.5; c.lineJoin = "round"; c.lineCap = "round";
                        c.beginPath();
                        c.moveTo(9, 2.2); c.lineTo(15.6, 9.2); c.lineTo(12, 9.2); c.lineTo(12, 12.4);
                        c.lineTo(6, 12.4); c.lineTo(6, 9.2); c.lineTo(2.4, 9.2); c.closePath();
                        c.stroke();
                        c.beginPath(); c.moveTo(6, 15.4); c.lineTo(12, 15.4); c.stroke();
                    }
                }
            }
            // arrow / spinner on the right
            Item {
                id: goBtn
                anchors.right: parent.right; anchors.rightMargin: 6 * ls.u
                anchors.verticalCenter: parent.verticalCenter
                width: 24 * ls.u; height: width
                readonly property bool on: ls.pass.length > 0 || ls.busy
                opacity: on ? 1 : 0
                scale: on ? 1 : 0.4
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on scale { NumberAnimation { duration: 340; easing.type: Easing.OutQuint } }
                Rectangle {
                    anchors.fill: parent; radius: width / 2
                    color: Qt.rgba(1, 1, 1, goMa.pressed ? 0.42 : 0.26)
                    visible: !ls.busy
                }
                Canvas {
                    anchors.fill: parent
                    visible: !ls.busy
                    onWidthChanged: requestPaint()
                    onPaint: {
                        var c = getContext("2d"); c.reset();
                        var w = width;
                        c.strokeStyle = "white"; c.lineWidth = Math.max(1.6, w * 0.085); c.lineCap = "round"; c.lineJoin = "round";
                        c.beginPath(); c.moveTo(w * 0.28, w * 0.5); c.lineTo(w * 0.72, w * 0.5); c.stroke();
                        c.beginPath(); c.moveTo(w * 0.53, w * 0.31); c.lineTo(w * 0.72, w * 0.5); c.lineTo(w * 0.53, w * 0.69); c.stroke();
                    }
                }
                Canvas {
                    anchors.fill: parent
                    visible: ls.busy
                    onWidthChanged: requestPaint()
                    onPaint: {
                        var c = getContext("2d"); c.reset();
                        var w = width;
                        c.strokeStyle = "white"; c.lineWidth = Math.max(1.6, w * 0.09); c.lineCap = "round";
                        c.beginPath(); c.arc(w / 2, w / 2, w * 0.36, 0, Math.PI * 1.4); c.stroke();
                    }
                    RotationAnimator on rotation { from: 0; to: 360; duration: 800; loops: Animation.Infinite; running: ls.busy }
                }
                MouseArea { id: goMa; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ls.submit() }
            }
        }

        // hint / error line
        MorphText {
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: ls.message !== "" ? ls.message : "Enter your password to log in"
            color: ls.message !== "" ? Qt.rgba(1, 0.78, 0.76, 0.95) : Qt.rgba(1, 1, 1, 0.55)
            font.family: ls.fam; font.pixelSize: 12 * ls.u
            opacity: ls.engaged || ls.message !== "" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }
    }

    // ═════════════ SESSION (bottom left) ═════════════
    Item {
        id: sessBtn
        visible: ls.isPrimary && ls.showSessions && sessions.count > 0
        anchors.left: parent.left; anchors.bottom: parent.bottom
        anchors.leftMargin: 28 * ls.u; anchors.bottomMargin: 28 * ls.u
        width: sessTxt.implicitWidth + 32 * ls.u; height: 32 * ls.u
        opacity: ls.shown && !ls.leaving ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 650; easing.type: Easing.OutQuint } }
        Glass { anchors.fill: parent; src: glassTex; frame: ls; cornerR: height / 2; thickness: 14; tint: 0.45; shadowAmt: 0.3 }
        Text {
            id: sessTxt
            anchors.centerIn: parent
            text: ls.session ? ls.session.title : ""
            color: "white"; font.family: ls.fam; font.pixelSize: 13 * ls.u; font.weight: Font.Medium
        }
        MouseArea {
            id: sessMa
            anchors.fill: parent; hoverEnabled: true
            enabled: sessions.count > 1
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: ls.sessionIdx = (ls.sessionIdx + 1) % sessions.count
        }
        ContourGlow { cornerR: sessBtn.height / 2; hovered: sessMa.containsMouse; at: Qt.point(sessMa.mouseX, sessMa.mouseY) }
    }

    // ═════════════ POWER (bottom centre, like the macOS login window) ═════════════
    Row {
        visible: ls.isPrimary && ls.showPower
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom; anchors.bottomMargin: 30 * ls.u
        spacing: 34 * ls.u
        opacity: ls.shown && !ls.leaving ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 650; easing.type: Easing.OutQuint } }
        Repeater {
            model: [
                { label: "Sleep", kind: "sleep", ok: sddm.canSuspend },
                { label: "Restart", kind: "restart", ok: sddm.canReboot },
                { label: "Shut Down", kind: "power", ok: sddm.canPowerOff }
            ]
            delegate: Column {
                id: pb
                required property var modelData
                visible: modelData.ok
                spacing: 6 * ls.u
                Item {
                    id: pbBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 36 * ls.u; height: width
                    scale: pbMa.pressed ? 0.9 : 1
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuint } }
                    Glass { anchors.fill: parent; src: glassTex; frame: ls; cornerR: width / 2; thickness: 14; tint: 0.45; shadowAmt: 0.3 }
                    Canvas {
                        anchors.fill: parent
                        onWidthChanged: requestPaint()
                        onPaint: {
                            var c = getContext("2d"); c.reset();
                            var w = width, k = pb.modelData.kind;
                            c.strokeStyle = "white"; c.fillStyle = "white"; c.lineWidth = Math.max(1.5, w * 0.055); c.lineCap = "round";
                            if (k === "power") {
                                c.beginPath(); c.arc(w / 2, w / 2, w * 0.22, -Math.PI * 0.32, Math.PI * 1.32); c.stroke();
                                c.beginPath(); c.moveTo(w / 2, w * 0.24); c.lineTo(w / 2, w * 0.48); c.stroke();
                            } else if (k === "restart") {
                                c.beginPath(); c.arc(w / 2, w / 2, w * 0.22, -Math.PI * 0.35, Math.PI * 1.45); c.stroke();
                                // arrow head at the top end of the arc
                                var ax = w / 2 + w * 0.22 * Math.cos(-Math.PI * 0.35), ay = w / 2 + w * 0.22 * Math.sin(-Math.PI * 0.35);
                                c.beginPath(); c.moveTo(ax - w * 0.1, ay - w * 0.03); c.lineTo(ax, ay); c.lineTo(ax - w * 0.02, ay + w * 0.1); c.stroke();
                            } else {
                                // crescent moon
                                c.beginPath(); c.arc(w / 2, w / 2, w * 0.2, 0, Math.PI * 2); c.fill();
                                c.globalCompositeOperation = "destination-out";
                                c.beginPath(); c.arc(w / 2 + w * 0.1, w / 2 - w * 0.08, w * 0.17, 0, Math.PI * 2); c.fill();
                            }
                        }
                    }
                    MouseArea {
                        id: pbMa
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: pb.modelData.kind === "power" ? sddm.powerOff() : (pb.modelData.kind === "restart" ? sddm.reboot() : sddm.suspend())
                    }
                    ContourGlow { cornerR: pbBtn.width / 2; hovered: pbMa.containsMouse; at: Qt.point(pbMa.mouseX, pbMa.mouseY) }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: pb.modelData.label
                    color: Qt.rgba(1, 1, 1, 0.8); font.family: ls.fam; font.pixelSize: 11 * ls.u; font.weight: Font.Medium
                }
            }
        }
    }

    // ═════════════ INPUT ═════════════
    property bool enterHeld: false
    Keys.onReleased: event => { if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { if (!event.isAutoRepeat) ls.enterHeld = false; } }
    Keys.onPressed: event => {
        ls.poke();
        if (ls.busy || ls.leaving) { event.accepted = true; return; }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            ls.enterHeld = true;
            if (!event.isAutoRepeat) ls.submit();
        } else if (event.key === Qt.Key_Escape) {
            ls.pass = "";
        } else if (event.key === Qt.Key_Backspace) {
            ls.pass = (event.modifiers & Qt.ControlModifier) ? "" : ls.pass.slice(0, -1);
        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_U) {
            ls.pass = "";
        } else if (event.text !== "" && event.text.charCodeAt(0) >= 32 && !(event.modifiers & Qt.ControlModifier)) {
            ls.pass += event.text;
            ls.message = "";
        }
        event.accepted = true;
    }
    MouseArea {
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        property point last: Qt.point(-1, -1)
        onPositionChanged: mouse => {
            if (last.x >= 0 && (Math.abs(mouse.x - last.x) > 2 || Math.abs(mouse.y - last.y) > 2)) ls.poke();
            last = Qt.point(mouse.x, mouse.y);
        }
        onClicked: { ls.forceActiveFocus(); ls.poke(); }
    }
}
