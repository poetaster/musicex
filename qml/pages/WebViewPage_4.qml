import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0

Page {
  property alias url: web_view.url

  WebView {
    id: web_view

    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }
  }
}
