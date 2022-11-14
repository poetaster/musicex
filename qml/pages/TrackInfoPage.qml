import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          

Item {
  id: item

  property bool isCurrentItem

  property var artist_data
  property var album_data
  property var track_data

  anchors.fill: parent

  SilicaFlickable {
    id: flickable

    width: item.width
    height: item.height

    Column {
      id: top_column
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Artist'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: track_data.strArtist
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Album'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: track_data.strAlbum
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Track'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: track_data.strTrack
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Track No.'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: track_data.intTrackNumber
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Duration'
          font.pixelSize: Theme.fontSizeSmall
        }

        Label { 
          visible: track_data.intDuration > 0
          text: main_handler.seconds_to_hms(track_data.intDuration / 1000)
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        } 
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Genre'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: track_data.strGenre
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Style'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: track_data.strStyle
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Theme'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: track_data.strTheme
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Mood'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: track_data.strMood
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }
    }

    Column {
      id: text_column
      anchors {
        top: top_column.bottom
        left: parent.left
        right: parent.right
        topMargin: Theme.paddingLarge
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
      }

      Label { 
        visible: Boolean(track_data.strDescriptionEN)
        text: String(track_data.strDescriptionEN)
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors {
          left: parent.left
          right: parent.right
        }
      }
    }
  }

  Component.onCompleted: {

  }

  Component.onDestruction: {

  }
}
