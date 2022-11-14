import QtQuick 2.2
import Sailfish.Silica 1.0   

ListItem {
  id: track_info_item

  property var artist_data
  property var album_data
  property var model_data
  property string local_media_file
  property bool data_requested

  width: parent.width
  height: Theme.itemSizeMedium + context_menu.height 

  Label { 
    id: track_number_label
    width: 100
    visible: model_data.intTrackNumber > 0
    text: model_data.intTrackNumber
    font.pixelSize: Theme.fontSizeLarge
    horizontalAlignment: Text.AlignHCenter
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
    }
  }

  Column {
    id: main_column
    anchors {
      top: parent.top
      left: track_number_label.right
      right: play_button.left
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
    }

    Label {
      width: parent.width
      text: model_data.strTrack
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeMedium
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
    }

    Label { 
      id: duration_label
      visible: model_data.intDuration > 0
      text: main_handler.seconds_to_hms(model_data.intDuration / 1000)
      font.pixelSize: Theme.fontSizeSmall
    }
  }

  Icon {
    id: disc_number_icon
    visible: Boolean(model_data.intCD)
    height: disc_number_label.height * 0.8
    width: height
    source: "image://theme/icon-m-media-albums"
    anchors {
      bottom: main_column.bottom
      right: parent.horizontalCenter
    }
  }

  Label { 
    id: disc_number_label
    visible: disc_number_icon.visible
    text: String(model_data.intCD)
    font.pixelSize: Theme.fontSizeSmall
    anchors {
      verticalCenter: disc_number_icon.verticalCenter
      left: disc_number_icon.right
    }
  }

  IconButton {                       
    id: play_button
    height: Theme.iconSizeMedium
    width: visible ? height : 0                               
    icon.source: "image://theme/icon-m-play" 
    onClicked: {
      main_handler.audio_player.stop()
      main_handler.replace_playlist(local_media_file, {'track_id': model_data.idTrack, 'track': model_data.strTrack, 'album': model_data.strAlbum, 'artist': model_data.strArtist, 'artwork': String(album_data.strAlbumThumbHQ || album_data.strAlbumThumb)})
      main_handler.audio_player.play()
      pageStack.push("PlayerPage.qml", {});
    }
    enabled: true
    visible: Boolean(local_media_file)
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: Theme.paddingMedium
    }           
  }

  IconButton {                       
    id: download_button
    height: Theme.iconSizeMedium
    width: visible ? height : 0                               
    icon.source: "image://theme/icon-s-cloud-download" 
    onClicked: {
      enabled = false
      data_requested = true
      python.get_audio_stream_yt(model_data.idTrack, app.video_by_track[model_data.idTrack].video_id)
    }
    enabled: true
    visible: !play_button.visible && Boolean(app.video_by_track[model_data.idTrack])
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: Theme.paddingMedium
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
      visible: Boolean(local_media_file.length)
      text: "Add to playlist"
      onClicked: {
        main_handler.add_playlist_item(local_media_file, {'track_id': model_data.idTrack, 'track': model_data.strTrack, 'album': model_data.strAlbum, 'artist': model_data.strArtist, 'artwork': String(album_data.strAlbumThumbHQ || album_data.strAlbumThumb)})
        pageStack.push("PlayerPage.qml", {});
      }
    }

    MenuItem {
      visible: Boolean(local_media_file.length)
      text: "Delete media file"
      onClicked: {
        track_info_item.remorseDelete(function() {  
          python.delete_local_media(model_data.idTrack)
          local_media_file = ''
        })
      }
    }
    
    MenuItem {
      visible: !Boolean(local_media_file.length) && Boolean(app.video_by_track[model_data.idTrack])
      text: "Download an play"
      onClicked: {
        python.get_audio_stream_yt(model_data.idTrack, app.video_by_track[model_data.idTrack].video_id)
        pageStack.push("PlayerPage.qml", {});
      }
    }

    MenuItem {
      visible: !Boolean(local_media_file.length) && !Boolean(app.video_by_track[model_data.idTrack])
      text: "Find and download media"
      onClicked: {
        data_requested = true
        python.find_download_media_yt(model_data.strArtist, model_data.strTrack, model_data.idTrack, model_data.intDuration)
      }
    }
  }

  onClicked: {
    pageStack.push("TrackPage.qml", {'track_data': model_data, 'artist_data': artist_data, 'album_data': album_data})
  }  

  Component.onCompleted: {
    app.signal_media_download.connect(handle_media_download)

    if (model_data.local_media_file) {
      local_media_file = model_data.local_media_file
    } else {
      const media_file = python.get_local_media_first(model_data.idTrack)
      if (media_file) {
        local_media_file = media_file
      }
    }
  }

  Component.onDestruction: {
    app.signal_media_download.disconnect(handle_media_download)
  }

  function handle_media_download(media) {
    console.log('handle_media_download - status:', media.status, 'file:',  media.file_name)
    if ((media.status == 'complete' || media.status == 'fail') && (media.track_id == model_data.idTrack || String(media.file_name).indexOf('track_' + model_data.idTrack + '_') > 4)) data_requested = false
    if (media.status == 'complete' && media.file_name.indexOf('track_' + model_data.idTrack + '_') > 4) {
      console.log('handle_media_download finished:',  media.file_name)
      const media_file = python.get_local_media_first(model_data.idTrack)
      if (media_file) {
        local_media_file = media_file
      }
    }
  }
}
