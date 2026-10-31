import QtQuick 2.15

Item {
  id: root
  property bool powerMenuOpen: false
  property bool canSleep: false
  property bool canHibernate: false
  signal actionRequested(string action)
  signal wakeRequested()

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
          readonly property bool available: modelData === "Sleep" ? root.canSleep : (modelData === "Hibernate" ? root.canHibernate : true)
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
              root.wakeRequested()
              root.powerMenuOpen = false
              root.actionRequested(modelData)
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
        root.wakeRequested()
        root.powerMenuOpen = !root.powerMenuOpen
      }
    }
  }

}
