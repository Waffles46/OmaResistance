import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
  id: root
  width: 1920
  height: 1080
  color: "#010603"

  property string currentUser: userModel.lastUser
  property int sessionIndex: sessionModel.lastIndex
  property bool authenticating: false
  property bool loginFailed: false
  property int failedAttempts: 0
  property bool powerMenuOpen: false

  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 67
  readonly property int outlineThickness: 3
  readonly property int fieldFontSize: 18
  readonly property int passwordDotFontSize: 21
  readonly property int passwordDotLetterSpacing: 3
  // Keep the existing login panel position while removing the old action row.
  readonly property real loginCenterOffset: (loginHeading.implicitHeight + 34
    - (24 + 15)) / 2
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (password.width - 4) / dotMetrics.advanceWidth)
    : 1

  function submitLogin() {
    if (authenticating || password.text.length === 0) return
    authenticating = true
    loginFailed = false
    sddm.login(currentUser, password.text, sessionIndex)
  }

  TextMetrics {
    id: dotMetrics
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(password.text.length)
  }

  Canvas {
    id: matrixRain
    anchors.fill: parent
    property int glyphSize: 18
    property var drops: []
    property string glyphs: "01ABCDEFGHIJKLMNOPQRSTUVWXYZｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉ"

    function resetDrops() {
      var count = Math.max(1, Math.floor(width / glyphSize))
      var next = []
      for (var i = 0; i < count; i++) next.push(Math.random() * -40)
      drops = next
    }

    onWidthChanged: resetDrops()
    onHeightChanged: resetDrops()
    Component.onCompleted: resetDrops()

    onPaint: {
      var ctx = getContext("2d")
      ctx.fillStyle = "rgba(1, 6, 3, 0.16)"
      ctx.fillRect(0, 0, width, height)
      ctx.font = "bold " + glyphSize + "px monospace"

      for (var i = 0; i < drops.length; i++) {
        var glyph = glyphs.charAt(Math.floor(Math.random() * glyphs.length))
        var y = drops[i] * glyphSize
        ctx.fillStyle = Math.random() > 0.94 ? "#dffff0" : (Math.random() > 0.72 ? "#00ff66" : "#00b846")
        ctx.fillText(glyph, i * glyphSize, y)
        if (y > height && Math.random() > 0.975) drops[i] = Math.random() * -15
        else drops[i] += 1
      }
    }
  }

  Timer {
    interval: 52
    running: root.visible
    repeat: true
    onTriggered: matrixRain.requestPaint()
  }

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    border.width: 1
    border.color: "#123c24"
  }

  Column {
    id: loginHeading
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: inputField.top
    anchors.bottomMargin: 34
    spacing: 8

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
            "⠀⠀⠀⠀⠀⠀⠀⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
            "⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀\n" +
            "⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⢿⠀⠀⠀⠀⠀⠀⠀⠀\n" +
            "⠀⠀⠀⠀⠀⠀⢻⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⢶⣆⠀⠀⠀⠀⠀⠀\n" +
            "⠀⠀⠀⠀⠀⠀⠀⠻⢠⣿⠿⠻⠻⢿⣿⣿⡇⠀⠀⠀⠀⠀⢿⣄⠀⠀⠀⠀⠀⠀\n" +
            "⠀⠀⠀⠀⠀⠀⠀⢸⣏⠀⠀⠀⠀⠀⣸⠿⢷⣦⢤⢤⣴⣿⠻⠀⠀⣠⣴⣶⣄⠀\n" +
            "⠀⠀⠀⠀⠀⠀⠀⠀⣿⣤⢤⢤⣴⣿⣿⡅⡄⢹⣿⢿⠻⠋⠀⠀⣠⣼⣿⣿⣿⢧⠀\n" +
            "⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠸⠻⠿⠻⢸⣿⣿⣿⣿⣿⣿⢿⠀⠀⣀⣤⣶⣿⠿⠻\n" +
            "⠀⠀⣿⣿⣦⢤⢤⢤⣄⢠⠀⠀⠀⣈⠛⠻⠻⠻⠁⢠⢾⢿⠻⠉⠀⠀⠀⠀⠀⣀\n" +
            "⠀⣼⣿⣿⣿⠿⠿⠿⠿⠿⠿⢿⢿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣶⣶⣶⣶⢾⣿⣏\n" +
            "⠀⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⠿⠋⠁⠈⠉⠉⠉⠉⠉⠉⠙⠻⠻⠻⣿"
      color: "#ffffff"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 11
      lineHeight: 1.0
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "OMARCHY"
      color: "#00ff66"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 18
      font.bold: true
      font.letterSpacing: 2
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Resistance is futile!"
      color: "#b8ffd0"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "SYSTEM LOGIN  ·  AUTHORIZATION REQUIRED"
      color: "#b8ffd0"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
      font.letterSpacing: 1
    }
  }

  Rectangle {
    id: inputField
    width: root.fieldWidth
    height: root.fieldHeight
    anchors.centerIn: parent
    anchors.verticalCenterOffset: root.loginCenterOffset
    color: "#e607130b"
    border.width: root.outlineThickness
    border.color: root.loginFailed ? "#ff5f56" : "#00ff66"
    radius: 0
    clip: true

    TextInput {
      id: password
      anchors.fill: parent
      anchors.margins: root.outlineThickness + 18
      verticalAlignment: TextInput.AlignVCenter
      horizontalAlignment: TextInput.AlignHCenter
      activeFocusOnPress: true
      clip: true
      enabled: !root.authenticating
      readOnly: root.authenticating
      echoMode: TextInput.Password
      passwordCharacter: "●"
      passwordMaskDelay: 0
      color: "#e8fff0"
      selectionColor: "#145c2d"
      selectedTextColor: "#ffffff"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: text.length > 0
        ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale))
        : root.fieldFontSize
      font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
      cursorVisible: activeFocus && !root.authenticating && !root.loginFailed && text.length > 0
      cursorDelegate: Rectangle {
        width: 2
        color: "#00ff66"
        visible: password.cursorVisible
      }

      onTextEdited: {
        if (root.loginFailed) root.loginFailed = false
      }
      onAccepted: root.submitLogin()

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
          password.text = ""
          root.loginFailed = false
          event.accepted = true
        }
      }
    }

    Text {
      anchors.fill: password
      text: root.authenticating
        ? "Checking…"
        : (root.loginFailed ? "Authentication failed (" + root.failedAttempts + ")" : "Enter Password")
      visible: password.text.length === 0
      color: root.authenticating ? "#ffd479" : (root.loginFailed ? "#ff5f56" : "#8affb1")
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: root.fieldFontSize
      font.italic: !root.authenticating && root.loginFailed
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
    }
  }


  Rectangle {
    id: powerMenu
    width: 224
    height: menuColumn.implicitHeight + 20
    anchors.right: powerButton.right
    anchors.bottom: powerButton.top
    anchors.bottomMargin: 12
    color: "#f209110c"
    border.width: 0
    radius: 5
    visible: root.powerMenuOpen
    z: 5

    Column {
      id: menuColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 10
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2

      Repeater {
        model: ["Sleep", "Hibernate", "Restart", "Shutdown"]
        Rectangle {
          required property string modelData
          readonly property bool available: modelData === "Sleep" ? sddm.canSuspend : (modelData === "Hibernate" ? sddm.canHibernate : true)
          width: menuColumn.width
          height: 42
          opacity: available ? 1.0 : 0.35
          radius: 3
          color: itemMouse.containsMouse ? "#153820" : "transparent"
          Text {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: modelData
            color: itemMouse.containsMouse ? "#b8ffd0" : "#00ff66"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
          }
          MouseArea {
            id: itemMouse
            anchors.fill: parent
            enabled: parent.available
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.powerMenuOpen = false
              if (modelData === "Sleep") sddm.suspend()
              else if (modelData === "Hibernate") sddm.hibernate()
              else if (modelData === "Restart") sddm.reboot()
              else if (modelData === "Shutdown") sddm.powerOff()
            }
          }
        }
      }
    }
  }

  Rectangle {
    id: powerButton
    width: 72
    height: 72
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.rightMargin: 40
    anchors.bottomMargin: 28
    color: "transparent"
    z: 5

    Canvas {
      anchors.centerIn: parent
      width: 72
      height: 72
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.translate(14, 14)
        ctx.strokeStyle = "#ff6a00"
        ctx.lineWidth = 4.8
        ctx.lineCap = "round"
        ctx.shadowColor = "rgba(255, 106, 0, 0.7)"
        ctx.shadowBlur = 10
        ctx.beginPath()
        ctx.arc(22, 23, 14.5, -Math.PI * 0.28, Math.PI * 1.28)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(22, 4)
        ctx.lineTo(22, 22)
        ctx.stroke()
      }
    }
    MouseArea {
      id: powerMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        root.powerMenuOpen = !root.powerMenuOpen
      }
    }
  }

  Connections {
    target: sddm

    function onLoginFailed() {
      root.authenticating = false
      root.loginFailed = true
      root.failedAttempts += 1
      password.text = ""
      password.forceActiveFocus()
    }

    function onLoginSucceeded() {
      root.authenticating = false
      root.loginFailed = false
    }
  }

  Component.onCompleted: password.forceActiveFocus()
}
