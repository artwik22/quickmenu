import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

PanelWindow {
    id: root

    anchors { left: true; top: true; bottom: true }
    margins { left: 15; right: 15; top: 15; bottom: 15 }
    implicitWidth: 460

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
    }

    Column {
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 24

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            Rectangle {
                width: 180
                height: 50
                color: bluetoothEnabled ? "#666666" : "#333333"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.LeftButton) {
                            toggleBluetooth()
                        } else if (mouse.button === Qt.RightButton) {
                            launchBluetuiInTerminal()
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󰂯"
                        font.pixelSize: 22
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: bluetoothEnabled ? "ON" : "OFF"
                        font.pixelSize: 14
                        font.family: "JetBrains Mono"
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Rectangle {
                width: 180
                height: 50
                color: vpnEnabled ? "#666666" : "#333333"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.LeftButton) {
                            toggleVPN()
                        } else if (mouse.button === Qt.RightButton) {
                            launchVPNManager()
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󰖂"
                        font.pixelSize: 22
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: vpnEnabled ? "ON" : "OFF"
                        font.pixelSize: 14
                        font.family: "JetBrains Mono"
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        Rectangle {
            width: 380
            height: 50
            color: "#333333"
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    lockScreen()
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: ""
                    font.pixelSize: 22
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: ""
                    font.pixelSize: 14
                    font.family: "JetBrains Mono"
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // --- Media Player ---
        Rectangle {
            id: mpContainer
            width: 380
            height: 130
            color: "#202020"
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Image {
                    id: albumArt
                    width: 100
                    height: 100
                    fillMode: Image.PreserveAspectFit
                    source: mpArt ? mpArt : ""
                    asynchronous: true
                    cache: false
                }

                Column {
                    id: mpInfoCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    width: parent.width - albumArt.width - spacing - anchors.margins * 2

                    Text {
                        id: trackTitle
                        text: mpTitle ? mpTitle : "Brak odtwarzacza"
                        font.pixelSize: 15
                        font.family: "JetBrains Mono"
                        color: "#ffffff"
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        id: trackArtist
                        text: mpArtist ? mpArtist : ""
                        font.pixelSize: 13
                        font.family: "JetBrains Mono"
                        color: "#cccccc"
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Rectangle {
                        id: progressBarBg
                        width: parent.width - 20
                        height: 10
                        color: "#2a2a2a"
                        clip: true
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: progressFill
                            width: 0
                            height: parent.height
                            color: "#ffffff"
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function(mouse) {
                                if (mpLength > 0) {
                                    var newPosSeconds = Math.round((mouse.x / parent.width) * mpLength)
                                    seekPlayer(newPosSeconds)
                                }
                            }
                        }
                    }

                    Row {
                        spacing: 14
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            width: 44
                            height: 36
                            color: "#333333"
                            MouseArea { anchors.fill: parent; onClicked: playerPrev() }
                            Text { text: "⏮"; anchors.centerIn: parent; font.pixelSize: 20; color: "#ffffff" }
                        }

                        Rectangle {
                            id: playPauseBtn
                            width: 54
                            height: 36
                            color: "#ffffff"
                            MouseArea { anchors.fill: parent; onClicked: playerPlayPause() }
                            Text { text: mpPlaying ? "⏸" : "▶"; anchors.centerIn: parent; font.pixelSize: 20; color: "#000000" }
                        }

                        Rectangle {
                            width: 44
                            height: 36
                            color: "#333333"
                            MouseArea { anchors.fill: parent; onClicked: playerNext() }
                            Text { text: "⏭"; anchors.centerIn: parent; font.pixelSize: 20; color: "#ffffff" }
                        }
                    }

                    Text {
                        id: posText
                        text: formatTime(mpPosition) + " / " + (mpLength > 0 ? formatTime(mpLength) : "--:--")
                        font.pixelSize: 11
                        font.family: "JetBrains Mono"
                        color: "#cccccc"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Rectangle {
                width: 380
                height: 34
                color: "#222222"

                Rectangle {
                    id: volumeTrack
                    width: parent.width - 20
                    height: 6
                    anchors.centerIn: parent
                    color: "#444444"

                    Rectangle {
                        width: parent.width * (volumeValue / 100)
                        height: parent.height
                        color: "#ffffff"
                    }
                }

                Rectangle {
                    id: volumeHandle
                    width: 20
                    height: 20
                    color: "#ffffff"
                    x: volumeTrack.x + (volumeTrack.width - width) * (volumeValue / 100)
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: function(mouse) {
                        updateVolume(mouse.x)
                    }

                    onPositionChanged: function(mouse) {
                        if (pressed) {
                            updateVolume(mouse.x)
                        }
                    }

                    function updateVolume(mouseX) {
                        var relX = mouseX - volumeTrack.x;
                        var newValue = (relX / volumeTrack.width) * 100;
                        volumeValue = Math.max(0, Math.min(100, newValue));
                        setSystemVolume(volumeValue);
                    }
                }
            }

            Text {
                text: "Volume: " + Math.round(volumeValue) + "%"
                font.pixelSize: 16
                font.family: "JetBrains Mono"
                color: "#ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Column {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        spacing: 14

        Column {
            spacing: 6
            Text { text: "CPU"; font.pixelSize: 17; font.family: "JetBrains Mono"; color: "#ffffff" }

            Rectangle {
                width: 320
                height: 20
                color: "#222222"

                Rectangle {
                    id: cpuFill
                    height: parent.height
                    width: parent.width * (cpuUsageValue / 100)
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
                    color: "#ffffff"
                }

                Text {
                    text: cpuUsageValue + "%"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 13
                    font.family: "JetBrains Mono"
                    color: "#ffffff"
                    anchors.rightMargin: 6
                }
            }
        }

        Column {
            spacing: 6
            Text { text: "RAM"; font.pixelSize: 17; font.family: "JetBrains Mono"; color: "#ffffff" }

            Rectangle {
                width: 320
                height: 20
                color: "#222222"

                Rectangle {
                    id: ramFill
                    height: parent.height
                    width: parent.width * (ramUsageValue / 100)
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
                    color: "#ffffff"
                }

                Text {
                    text: ramUsageValue + "%"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 13
                    font.family: "JetBrains Mono"
                    color: "#ffffff"
                    anchors.rightMargin: 6
                }
            }
        }

        Column {
            spacing: 6
            Text { text: "DISK"; font.pixelSize: 17; font.family: "JetBrains Mono"; color: "#ffffff" }

            Rectangle {
                width: 320
                height: 20
                color: "#222222"

                Rectangle {
                    id: diskFill
                    height: parent.height
                    width: parent.width * (diskUsageValue / 100)
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
                    color: "#ffffff"
                }

                Text {
                    text: diskUsageValue + "%"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 13
                    font.family: "JetBrains Mono"
                    color: "#ffffff"
                    anchors.rightMargin: 6
                }
            }
        }
    }

    property int ramUsageValue: 0
    property int cpuUsageValue: 0
    property int diskUsageValue: 0
    property real volumeValue: 50
    property bool bluetoothEnabled: false
    property bool vpnEnabled: false
    property string mpTitle: ""
    property string mpArtist: ""
    property string mpArt: ""
    property bool mpPlaying: false
    property real mpPosition: 0
    property int mpLength: 0

    function toggleBluetooth() {
        var command = bluetoothEnabled ? "off" : "on"
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['bluetoothctl','power','" + command + "']; running: true }", root)
        bluetoothCheckTimer.restart()
    }

    function launchBluetuiInTerminal() {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['kitty','bluetui']; running: true }", root)
    }

    function toggleVPN() {
        if (vpnEnabled) {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','nmcli connection show --active | grep vpn | awk \\\"{print $1}\\\" | xargs -I {} nmcli connection down {}']; running: true }", root)
        } else {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','nmcli connection show | grep vpn | head -1 | awk \\\"{print $1}\\\" | xargs -I {} nmcli connection up {}']; running: true }", root)
        }
        vpnCheckTimer.restart()
    }

    function launchVPNManager() {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['nm-connection-editor']; running: true }", root)
    }

    function lockScreen() {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['hyprlock']; running: true }", root)
    }

    function setSystemVolume(value) {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['pactl','set-sink-volume','@DEFAULT_SINK@','" + Math.round(value) + "%']; running: true }", root)
    }

    function getSystemVolume() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///tmp/quickshell_volume")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.responseText) {
                var vol = parseInt(xhr.responseText.trim())
                if (!isNaN(vol) && vol >= 0 && vol <= 100) {
                    volumeValue = vol
                }
            }
        }
        xhr.send()

        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','pactl get-sink-volume @DEFAULT_SINK@ | head -1 | awk \\\"{print $5}\\\" | tr -d % > /tmp/quickshell_volume']; running: true }", root)
    }

    function checkBluetooth() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///tmp/quickshell_bt_status")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var status = xhr.responseText.trim()
                bluetoothEnabled = (status === "on")
            }
        }
        xhr.send()

        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','bluetoothctl show | grep -q \"Powered: yes\" && echo on > /tmp/quickshell_bt_status || echo off > /tmp/quickshell_bt_status']; running: true }", root)
    }

    function checkVPN() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///tmp/quickshell_vpn_status")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var status = xhr.responseText.trim()
                vpnEnabled = (status === "on")
            }
        }
        xhr.send()

        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','nmcli connection show --active | grep -q vpn && echo on > /tmp/quickshell_vpn_status || echo off > /tmp/quickshell_vpn_status']; running: true }", root)
    }

    function parseTimeToSeconds(str) {
        if (!str) return 0
        var n = parseFloat(str)
        if (!isNaN(n) && str.indexOf(':') === -1) return n
        var parts = str.split(':').map(function(x) { return parseInt(x) || 0 })
        if (parts.length === 2) {
            return parts[0] * 60 + parts[1]
        } else if (parts.length === 3) {
            return parts[0] * 3600 + parts[1] * 60 + parts[2]
        }
        return 0
    }

    function updatePlayerMetadata() {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','if command -v playerctl >/dev/null 2>&1; then playerctl metadata --format \"{{artist}}\\n{{title}}\\n{{mpris:artUrl}}\\n{{mpris:length}}\\n{{status}}\" > /tmp/quickshell_player_info 2>/dev/null || true; else echo MISSING > /tmp/quickshell_player_info; fi']; running: true }", root)

        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///tmp/quickshell_player_info")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var txt = xhr.responseText || ""
                if (txt.trim() === "MISSING") {
                    mpTitle = "playerctl nie znaleziony"
                    mpArtist = ""
                    mpArt = ""
                    mpPlaying = false
                    mpPosition = 0
                    mpLength = 0
                    return
                }
                var lines = txt.split("\n")
                mpArtist = lines[0] ? lines[0].trim() : ""
                mpTitle = lines[1] ? lines[1].trim() : ""
                var art = lines[2] ? lines[2].trim() : ""
                var lengthRaw = (lines[3] || "").trim()
                var status = (lines[4] || "").trim().toLowerCase()

                var len = parseInt(lengthRaw) || 0
                if (len > 1000000) mpLength = Math.round(len / 1000000)
                else mpLength = Math.round(parseTimeToSeconds(lengthRaw))

                mpPlaying = (status === "playing")

                if (art.indexOf("file://") === 0) mpArt = art.replace("file://", "")
                else if (art.indexOf("http") === 0) mpArt = art
                else mpArt = ""
            }
        }
        xhr.send()
    }

    function updatePlayerPosition() {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','if command -v playerctl >/dev/null 2>&1; then playerctl position > /tmp/quickshell_player_pos 2>/dev/null || true; else echo MISSING > /tmp/quickshell_player_pos; fi']; running: true }", root)

        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///tmp/quickshell_player_pos")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var txt = (xhr.responseText || "").trim()
                if (txt === "MISSING" || txt === "") {
                    return
                }
                var pos = parseTimeToSeconds(txt)
                if (!isNaN(pos)) {
                    mpPosition = pos
                }

                if (mpLength > 0) {
                    var frac = mpPosition / mpLength
                    if (frac < 0) frac = 0
                    if (frac > 1) frac = 1
                    progressFill.width = Math.round(progressBarBg.width * frac)
                } else {
                    progressFill.width = 0
                }
            }
        }
        xhr.send()
    }

    function playerPlayPause() {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['playerctl','play-pause']; running: true }", root)
        Qt.createQmlObject("import QtQuick; Timer { interval: 250; running: true; repeat: false; onTriggered: updatePlayerMetadata() }", root)
        Qt.createQmlObject("import QtQuick; Timer { interval: 400; running: true; repeat: false; onTriggered: updatePlayerPosition() }", root)
    }

    function playerNext() {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['playerctl','next']; running: true }", root)
        Qt.createQmlObject("import QtQuick; Timer { interval: 300; running: true; repeat: false; onTriggered: updatePlayerMetadata() }", root)
    }

    function playerPrev() {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['playerctl','previous']; running: true }", root)
        Qt.createQmlObject("import QtQuick; Timer { interval: 300; running: true; repeat: false; onTriggered: updatePlayerMetadata() }", root)
    }

    function seekPlayer(seconds) {
        Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['playerctl','position','" + seconds + "']; running: true }", root)
        Qt.createQmlObject("import QtQuick; Timer { interval: 200; running: true; repeat: false; onTriggered: updatePlayerPosition() }", root)
        Qt.createQmlObject("import QtQuick; Timer { interval: 300; running: true; repeat: false; onTriggered: updatePlayerMetadata() }", root)
    }

    function formatTime(sec) {
        if (!sec || sec <= 0) return "0:00"
        var s = Math.floor(sec % 60)
        var m = Math.floor((sec / 60) % 60)
        var h = Math.floor(sec / 3600)
        if (h > 0) return h + ":" + (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    Timer {
        id: metadataTimer
        interval: 3000
        repeat: true
        running: true
        onTriggered: updatePlayerMetadata()
        Component.onCompleted: updatePlayerMetadata()
    }

    Timer {
        id: positionTimer
        interval: 500
        repeat: true
        running: true
        onTriggered: updatePlayerPosition()
        Component.onCompleted: updatePlayerPosition()
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        function readRam() {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "file:///proc/meminfo")
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var lines = xhr.responseText.split("\n")
                    var memTotal = 0
                    var memAvailable = 0
                    for (var i = 0; i < lines.length; i++) {
                        if (lines[i].startsWith("MemTotal:")) memTotal = parseInt(lines[i].match(/\d+/)[0])
                        else if (lines[i].startsWith("MemAvailable:")) memAvailable = parseInt(lines[i].match(/\d+/)[0])
                    }
                    if (memTotal > 0) ramUsageValue = 100 - Math.round((memAvailable / memTotal) * 100)
                }
            }
            xhr.send()
        }
        onTriggered: readRam()
        Component.onCompleted: readRam()
    }

    Timer {
        interval: 2000
        repeat: true
        running: true

        property int lastIdle: 0
        property int lastTotal: 0

        function readCpu() {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "file:///proc/stat")
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var lines = xhr.responseText.split("\n")
                    for (var i = 0; i < lines.length; i++) {
                        if (lines[i].startsWith("cpu ")) {
                            var parts = lines[i].trim().split(/\s+/)
                            var user = parseInt(parts[1])
                            var nice = parseInt(parts[2])
                            var system = parseInt(parts[3])
                            var idle = parseInt(parts[4])
                            var total = user + nice + system + idle
                            if (lastTotal > 0) {
                                cpuUsageValue = Math.round((total - lastTotal - (idle - lastIdle)) / (total - lastTotal) * 100)
                            }
                            lastTotal = total
                            lastIdle = idle
                            break
                        }
                    }
                }
            }
            xhr.send()
        }
        onTriggered: readCpu()
        Component.onCompleted: readCpu()
    }

    Timer {
        interval: 2000
        repeat: true
        running: true

        function readDisk() {
            diskUsageValue = 45
        }
        onTriggered: readDisk()
        Component.onCompleted: readDisk()
    }

    Timer {
        id: bluetoothCheckTimer
        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            checkBluetooth()
            checkVPN()
        }
        Component.onCompleted: {
            checkBluetooth()
            checkVPN()
        }
    }

    Timer {
        id: volumeCheckTimer
        interval: 10000
        repeat: true
        running: true
        onTriggered: {
            getSystemVolume()
        }
        Component.onCompleted: {
            getSystemVolume()
        }
    }
}
