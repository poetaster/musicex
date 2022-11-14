import QtQuick 2.2
import Sailfish.Silica 1.0   

ListItem {
  property var track_data
  property var album_data
  property string local_media_file

  width: parent.width
  height: Theme.itemSizeMedium + context_menu.height

  Item {
    id: audio_thumb_item
    height: Theme.itemSizeMedium
    width: height
    anchors {
      left: parent.left
    }

    Icon {
      id: audio_thumb
      source: "image://theme/icon-m-file-audio"
      anchors {
        centerIn: parent
      }
    }
  }

  Column {
    id: main_column
    anchors {
      top: parent.top
      left: audio_thumb_item.right
      right: parent.right
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
    }

    Label {
      width: parent.width
      visible: Boolean(track_data.strTrack)
      text: track_data.strTrack
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeSmall
    }
  }

  onClicked: {
    main_handler.audio_player.stop()
    main_handler.replace_playlist(local_media_file, {'track_id': track_data.idTrack, 'track': track_data.strTrack, 'album': track_data.strAlbum, 'artist': track_data.strArtist, 'artwork': String(album_data.strAlbumThumbHQ || album_data.strAlbumThumb)})
    main_handler.audio_player.play()
    pageStack.push("PlayerPage.qml", {});
  }
  
  menu: ContextMenu {
    id: context_menu
    visible: false
    MenuItem {
      text: "Enqueue audio"
      onClicked: {
        main_handler.add_playlist_item(local_media_file, {'track_id': track_data.idTrack, 'track': track_data.strTrack, 'album': track_data.strAlbum, 'artist': track_data.strArtist, 'artwork': String(album_data.strAlbumThumbHQ || album_data.strAlbumThumb)})
        pageStack.push("PlayerPage.qml", {});
      }
    }
  }

  Component.onCompleted: {

  }
}
