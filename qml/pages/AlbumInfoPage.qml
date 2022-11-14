import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          

Item {
  id: item

  property bool isCurrentItem

  property alias flickable: flickable
  property var artist_data
  property var album_data

  anchors.fill: parent

  SilicaFlickable {
    id: flickable

    width: item.width
    height: item.height

    contentHeight: top_column.height + text_column.height + Theme.paddingLarge

    Column {
      id: top_column
      height: childrenRect.height
      
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
          id: artist_label
          width: parent.width / 3
          text: 'Artist'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: album_data.strArtist
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
          text: album_data.strAlbum
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Released'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: album_data.intYearReleased
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Format'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: album_data.strReleaseFormat
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Tracks'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: String(album_page.tracks.length)
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }
      
      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Label'
          font.pixelSize: Theme.fontSizeSmall
        }
        Label {
          text: album_data.strLabel
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
          text: album_data.strGenre
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
          text: album_data.strStyle
          width: parent.width / 3 * 2
          wrapMode: Text.WordWrap
          font.pixelSize: Theme.fontSizeSmall
        }
      }

      Row {
        width: parent.width
        Label {
          width: parent.width / 3
          text: 'Links'
          font.pixelSize: Theme.fontSizeSmall
        }
        LinkedLabel {
          visible: Boolean(album_data.strWikipediaID)
          text: '<a href="https://en.wikipedia.org/wiki/' + album_data.strWikipediaID + '">Wikipedia</a>'
          defaultLinkActions: true
          font.pixelSize: Theme.fontSizeSmall
        }
      }
    }

    Column {
      id: text_column

      height: childrenRect.height

      anchors {
        top: top_column.bottom
        left: parent.left
        right: parent.right
        topMargin: Theme.paddingLarge
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
      }

      Label { 
        id: album_description_label
        visible: Boolean(album_data.strDescriptionEN)
        text: String(album_data.strDescriptionEN)
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

