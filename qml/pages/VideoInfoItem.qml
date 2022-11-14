import QtQuick 2.2
import Sailfish.Silica 1.0   

ListItem {
  id: list_item
  property var model_data
  property var track_data
  property var album_data
  property string local_media_file: ''
  property bool data_requested

  width: parent.width
  height: context_menu.height + (main_column.height > video_thumb.height ? main_column.height : video_thumb.height)

  Image {
    id: video_thumb
    height: Theme.itemSizeMedium
    width: height
    fillMode: Image.PreserveAspectCrop
    source: model_data.thumbnail_url

    MouseArea {
      anchors.fill: parent
      onClicked: {
        Qt.openUrlExternally("https://www.youtube.com/watch?v=" + model_data.video_id);
      }
    }
  }

  Icon {
    height: 50
    width: height
    source: "image://theme/icon-m-video"
    anchors {
      bottom: video_thumb.bottom
      right: video_thumb.right
      rightMargin: Theme.paddingSmall
      bottomMargin: Theme.paddingSmall
    }
  }

  Column {
    id: main_column
    anchors {
      top: parent.top
      left: video_thumb.right
      right: parent.right
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
    }

    Label {
      width: parent.width
      visible: Boolean(model_data.title)
      text: model_data.title
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
    }

    Label {
      width: parent.width
      visible: Boolean(model_data.length)
      text: main_handler.seconds_to_minutes_seconds(model_data.length)
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
    }
  }

  Icon {
    visible: local_media_file.length
    height: 50
    width: height
    source: "image://theme/icon-m-file-audio"
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: Theme.paddingExtraSmall
      bottomMargin: Theme.paddingExtraSmall
    }
  }

  BusyIndicator {
    size: BusyIndicatorSize.Small
    running: data_requested
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: Theme.paddingMedium
    } 
  }

  menu: ContextMenu {
    id: context_menu
    MenuItem {
      text: "Copy video URL"
      onClicked: {
        Clipboard.text = "https://www.youtube.com/watch?v=" + model_data.video_id
      }
    }
    MenuItem {
      text: "Download and play audio"
      onClicked: {
        data_requested = true
        python.get_audio_stream_yt(track_data.idTrack, model_data.video_id)
        //main_handler.audio_player.stop()
        //main_handler.replace_playlist(null, {'track_id': track_data.idTrack, 'track': track_data.strTrack, 'album': track_data.strAlbum, 'artist': track_data.strArtist, 'artwork': String(album_data.strAlbumThumbHQ || album_data.strAlbumThumb)})        
        pageStack.push("PlayerPage.qml", {});
      }
    }
    MenuItem {
      visible: Boolean(local_media_file.length)
      text: "Play audio"
      onClicked: {
        main_handler.audio_player.stop()
        main_handler.replace_playlist(local_media_file, {'track_id': track_data.idTrack, 'track': track_data.strTrack, 'album': track_data.strAlbum, 'artist': track_data.strArtist, 'artwork': String(album_data.strAlbumThumbHQ || album_data.strAlbumThumb)})
        main_handler.audio_player.play()
        pageStack.push("PlayerPage.qml", {});
      }
    }
    MenuItem {
      visible: Boolean(local_media_file.length)
      text: "Enqueue audio"
      onClicked: {
        main_handler.add_playlist_item(local_media_file, {'track_id': track_data.idTrack, 'track': track_data.strTrack, 'album': track_data.strAlbum, 'artist': track_data.strArtist, 'artwork': String(album_data.strAlbumThumbHQ || album_data.strAlbumThumb)})
        pageStack.push("PlayerPage.qml", {});
      }
    }
    MenuItem {
      visible: Boolean(local_media_file.length)
      text: "Delete audio"
      onClicked: {
        list_item.remorseDelete(function() { if (python.delete_local_media(track_data.idTrack, model_data.video_id)) local_media_file = '' })
      }
    }
  }
  
  onClicked: {
    if (!Boolean(local_media_file.length)) return
    main_handler.audio_player.stop()
    main_handler.replace_playlist(local_media_file, {'track_id': track_data.idTrack, 'track': track_data.strTrack, 'album': track_data.strAlbum, 'artist': track_data.strArtist, 'artwork': String(album_data.strAlbumThumbHQ || album_data.strAlbumThumb)})
    main_handler.audio_player.play()
    pageStack.push("PlayerPage.qml", {});
  }

  Component.onCompleted: {
    app.signal_media_download.connect(handle_media_download)
    
    const file_name = python.get_local_media_first(track_data.idTrack, model_data.video_id)
    if (file_name) {
      local_media_file = file_name
    } else {
      local_media_file = ''
    }
  }

  Component.onDestruction: {
    app.signal_media_download.disconnect(handle_media_download)
  }

  function handle_media_download(media) {
    console.log('handle_media_download - status:', media.status, 'file:',  media.file_name)
    if ((media.status == 'complete' || media.status == 'fail') && (media.track_id == track_data.idTrack || String(media.file_name).indexOf('track_' + track_data.idTrack + '_' + model_data.video_id) > 4)) data_requested = false
    if (media.status == 'complete' && media.file_name.indexOf('track_' + track_data.idTrack + '_' + model_data.video_id) > 4) {
      console.log('handle_media_download finished:',  media.file_name)
      const media_file = python.get_local_media_first(track_data.idTrack)
      if (media_file) {
        local_media_file = media_file
      }
    }
  }
}
