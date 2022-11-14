import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  property alias url: web_view.url

  SilicaWebView {
    id: web_view

    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }
  }
}