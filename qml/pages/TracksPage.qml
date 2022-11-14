import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          

Item {
  id: tracks_page

  property var artist_data
  property var album_data
  property var local_media_files: []
  property int local_media_files_count: 0
  
  property var tracks: []

  anchors.fill: parent

  Timer {
    id: local_media_timer
    interval: 500
    running: false
    repeat: false
    onTriggered: {
      for (var i = 0; i < album_page.tracks.length; i++) {
        if (album_page.tracks[i].local_media_file) local_media_files.push(album_page.tracks[i].local_media_file)
      }
      local_media_files_count = local_media_files.length
    }
  }

  SilicaListView {
    width: parent.width; 
    height: parent.height

    model: album_page.tracks

    header: Item {
      visible: local_media_files_count > 1
      height: visible ? Theme.itemSizeSmall : 0
      width: parent.width

      Item {
        id: audio_thumb_item
        height: Theme.itemSizeSmall
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

      IconButton {                       
        id: play_button
        height: Theme.iconSizeMedium
        width: height
        visible: true                             
        icon.source: "image://theme/icon-m-play" 
        onClicked: {
          main_handler.audio_player.stop()
          main_handler.playlist.clear()
          for (var i = 0; i < local_media_files.length; i++) {
            main_handler.add_playlist_item(local_media_files[i])
          }
          main_handler.audio_player.play()
          pageStack.push("PlayerPage.qml", {});
        }
        anchors {
          verticalCenter: parent.verticalCenter
          right: parent.right
          rightMargin: Theme.paddingMedium
        }           
      }

      Label {
        text: local_media_files_count + " Tracks"
        anchors {
          left: audio_thumb_item.right
          verticalCenter: parent.verticalCenter
        }
      }
    }

    delegate: TrackInfoItem {
      model_data: modelData
      artist_data: tracks_page.artist_data
      album_data: tracks_page.album_data
    }

    onCountChanged: {
      if (count > 0) {
        if (!local_media_timer.running) local_media_timer.start()
      } else {
        local_media_files_count = 0
      }
    }
  }
  
  Component.onCompleted: {
    app.signal_media_download.connect(handle_media_download)
  }

  Component.onDestruction: {
    app.signal_media_download.disconnect(handle_media_download)
  }

  function handle_media_download(media) {
    if (media.status == 'complete') {
      local_media_files = []
      for (var i = 0; i < album_page.tracks.length; i++) {
        if (album_page.tracks[i].local_media_file) local_media_files.push(album_page.tracks[i].local_media_file)
        else {
          const local_media_file = python.get_local_media_first(album_page.tracks[i].idTrack)
          if (local_media_file) {
            album_page.tracks[i].local_media_file = local_media_file
            local_media_files.push(local_media_file)
          }
        }
      }
      local_media_files_count = local_media_files.length
    }
  }
}
