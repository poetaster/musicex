import QtQuick 2.2
import Sailfish.Silica 1.0   

Component {
  Item {
    id: item

    property var top_album_data
    property int display_index: 0
    property bool item_left: Boolean(display_index % 2 == 0)
    width: parent.width
    height: childrenRect.height

    MouseArea {
      anchors.fill: parent
      onClicked: {
        pageStack.push("TrackPage.qml", {'artist_data': top_album_data.artist, 'album_data': top_album_data.album, 'track_data': top_album_data.track})
      }
    }

    CachedImage {
      id: album_thumb
      fillMode: Image.PreserveAspectFit
      remote_source: top_album_data.top_image
      width: parent.width / 2
      height: width
      anchors {
        left: item_left ? parent.left : parent.horizontalCenter
        right: item_left ? parent.horizontalCenter : parent.right
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          pageStack.push("AlbumPage.qml", {'artist_data': top_album_data.artist, 'album_data': top_album_data.album, 'track_data': top_album_data.track})
        }
      }
    }

    Column {
      width: parent.width / 2

      anchors {
        top: parent.top
        topMargin: Theme.paddingLarge
        leftMargin: Theme.paddingLarge
        rightMargin: Theme.paddingLarge
        left: item_left ? parent.horizontalCenter : parent.left
        right: item_left ? parent.right : parent.horizontalCenter
      }

      Label {
        width: parent.width
        text: top_album_data.track.strTrack
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeLarge
      }

      Label { 
        width: parent.width
        text: top_album_data.track.strAlbum
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
      }

      Label { 
        width: parent.width
        text: top_album_data.track.strArtist
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeMedium
      }
    }

    Component.onCompleted: {

    }

    Component.onDestruction: {

    }
  }
}
