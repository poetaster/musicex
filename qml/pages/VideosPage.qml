import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          

Item {
  id: videos_page

  property var artist_data
  property var album_data
  property var track_data
  property var videos
  property string local_media_file
  property bool media_requested

  anchors.fill: parent

  SilicaListView {
    id: list_view

    width: parent.width; 
    height: parent.height

    spacing: 10

    model: videos

    header: AudioInfoItem {
      visible: Boolean(videos_page.local_media_file)
      height: visible ? Theme.itemSizeMedium : 0
      track_data: videos_page.track_data
      album_data: videos_page.album_data
      local_media_file: videos_page.local_media_file
    }

    delegate: VideoInfoItem {
      model_data: modelData
      track_data: videos_page.track_data
      album_data: videos_page.album_data
    }

    ViewPlaceholder {
      enabled: !settings.lookup_video_yt
      text: "Disabled"
      hintText: "Media search disabled"
    }
  }
  
  BusyIndicator {
    size: BusyIndicatorSize.Large
    anchors.centerIn: list_view
    running: media_requested
  }

  Component.onCompleted: {
    local_media_file = python.get_local_media_first(track_data.idTrack)
  }

  Component.onDestruction: {
    
  }
}
