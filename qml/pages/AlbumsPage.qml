import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          

Page {
  id: main_page

  property var artist_data
  property var albums_data

  SilicaListView {
    width: parent.width; 
    height: parent.height

    model: albums_data

    header: Item {
      width: parent.width
      height: Theme.itemSizeMedium

      Label { 
        text: artist_data.strArtist
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeLarge
        fontSizeMode: Text.Fit
        minimumPixelSize: Theme.fontSizeExtraSmall
        horizontalAlignment: Text.AlignRight
        anchors {
          left: parent.left
          right: parent.right
          leftMargin: Theme.paddingMedium
          rightMargin: Theme.paddingMedium
        }
      }
    }

    delegate: AlbumInfoItem {
      model_data: modelData

      MouseArea {
        anchors.fill: parent
        onClicked: {
          pageStack.push("AlbumPage.qml", {'artist_data': artist_data, 'album_data': modelData})
        }
      }
    }
  }
   
  Component.onCompleted: {
    python.get_videos(artist_data.idArtist)
  }

  Component.onDestruction: {

  }
}
