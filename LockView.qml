import QtQuick
import QtQuick.Effects
import qs.Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool canSleep: false
  property bool canHibernate: false
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 67
  readonly property int outlineThickness: 3
  readonly property int fieldFontSize: Math.round(Style.font.heading * 1.125)
  readonly property int passwordDotFontSize: Math.round(Style.font.heading * 1.33)
  readonly property int passwordDotLetterSpacing: Math.round(Style.font.heading * 0.19)
  // Center the complete lock prompt instead of centering only its password field.
  readonly property real lockCenterOffset: (lockHeading.implicitHeight + 34 - 39) / 2
  // Space to keep clear on each side of the field for the fingerprint icon
  // (icon width plus a gap) so the centered dots never run under it.
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 12) : 0
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0
  readonly property var inputBorderSpec: errorState
    ? Border.surfaceSpec("lock", "border-error", "#ff5f56", root.outlineThickness, "border-alpha")
    : Border.surfaceSpec("lock", "border-active", "#00ff66", root.outlineThickness, "border-alpha")

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()
  signal powerRequested(string action)

  // Cache-busts the lock background by appending `?v=`. Adding a query
  // string keeps Image's loader happy while forcing it to reload when the
  // user picks a new background mid-session.
  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
    else powerMenu.powerMenuOpen = false
  }
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  // Measures the masked password at full size; passwordDotScale compares this
  // against the field width to decide how far the dots must shrink to fit.
  TextMetrics {
    id: dotMetrics
    font.family: Style.font.family
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(passwordInput.text.length)
  }

  Rectangle {
    anchors.fill: parent
    color: "#010603"

    Image {
      id: wallpaper
      anchors.fill: parent
      source: root.loadBackground ? root.fileUrl(root.backgroundPath) : ""
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
      visible: false
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.status === Image.Ready
      blur: 1.0
      blurMax: 128
      blurMultiplier: 1.25
      contrast: -0.08
      visible: false
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
      id: lockHeading
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
        font.family: Style.font.family
        font.pixelSize: 18
        font.bold: true
        font.letterSpacing: 2
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Resistance is futile!"
        color: "#b8ffd0"
        font.family: Style.font.family
        font.pixelSize: 12
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "SYSTEM LOCKED  ·  AUTHORIZATION REQUIRED"
        color: "#b8ffd0"
        font.family: Style.font.family
        font.pixelSize: 12
        font.letterSpacing: 1
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    BorderSurface {
      id: inputField
      width: root.fieldWidth
      height: root.fieldHeight
      anchors.centerIn: parent
      anchors.verticalCenterOffset: root.lockCenterOffset
      color: "#e607130b"
      borderSpec: root.inputBorderSpec
      radius: Style.cornerRadius
      clip: true

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.topMargin: inputField.borderTop
        // Reserve the fingerprint icon's width on both sides so the centered
        // dots stay symmetric and never slide under the icon as they grow.
        anchors.rightMargin: inputField.borderRight + 18 + root.fingerprintReserve
        anchors.bottomMargin: inputField.borderBottom
        anchors.leftMargin: inputField.borderLeft + 18 + root.fingerprintReserve
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: TextInput.Password
        passwordCharacter: "\u25CF"
        passwordMaskDelay: 0
        color: "#e8fff0"
        selectionColor: "#145c2d"
        selectedTextColor: "#ffffff"
        font.family: Style.font.family
        font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.fieldFontSize
        font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
        cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
        cursorDelegate: Rectangle {
          width: 2
          color: "#00ff66"
          visible: passwordInput.cursorVisible
        }

        onTextChanged: {
          if (!root.syncingPasswordText) root.passwordTextEdited(text)
          if (text.length > 0) {
            root.wakeRequested()
          }
          if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
        }

        onAccepted: {
          var submitted = root.passwordText
          root.passwordTextEdited("")
          if (submitted.length > 0) root.submitPassword(submitted)
        }

        Keys.onPressed: function(event) {
          root.wakeRequested()
          if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
            root.passwordTextEdited("")
            event.accepted = true
          }
        }
      }

      Text {
        anchors.fill: passwordInput
        text: root.authenticatingPassword ? "Checking…" : (root.failureMessage.length > 0 ? root.failureMessage : root.placeholderText)
        visible: passwordInput.text.length === 0
        color: root.authenticatingPassword ? "#ffd479" : (root.failureMessage.length > 0 ? "#ff5f56" : "#8affb1")
        font.family: Style.font.family
        font.pixelSize: root.fieldFontSize
        font.italic: !root.authenticatingPassword && root.failureMessage.length > 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
      }

      // Fingerprint hint pinned inside the field's right edge when a sensor is
      // enrolled, so the user knows they can touch to unlock instead of typing.
      // Matches hyprlock, which draws its fingerprint icon in the same spot.
      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.rightMargin: inputField.borderRight + 18
        anchors.verticalCenter: parent.verticalCenter
        visible: root.fingerprintConfigured
        text: "󰈷"
        color: "#00ff66"
        font.family: Style.font.family
        font.pixelSize: Math.round(root.fieldFontSize * 1.1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
  }
  PowerMenu {
    id: powerMenu
    anchors.fill: parent
    canSleep: root.canSleep
    canHibernate: root.canHibernate
    onWakeRequested: root.wakeRequested()
    onActionRequested: function(action) { root.powerRequested(action) }
  }

}
