import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          
import Sailfish.Silica.private 1.0  

Page {
  id: track_page

  property var artist_data
  property var album_data
  property var track_data
  property var videos: []
  property string lyrics: ''
  property bool media_requested: false
  property bool lyrics_requested: false

  CachedImage {
    id: album_thumb
    height: 220
    width: height
    fillMode: Image.PreserveAspectCrop
    remote_source: album_data.strAlbumThumb
    preview: true
    anchors {
      top: parent.top
      right: parent.right
    }
  }

  Column {
    id: title_column
    height: 220

    anchors {
      left: parent.left
      right: album_thumb.left
      leftMargin: Theme.paddingLarge
      rightMargin: Theme.paddingMedium
    }

    Label { 
      width: parent.width
      text: track_data.strArtist 
      font.pixelSize: Theme.fontSizeSmall
      truncationMode: TruncationMode.Fade
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
    }

    Label { 
      id: album_name_label
      width: parent.width
      text: track_data.strAlbum
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeSmall
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
    }
    
    Label { 
      id: track_name_label
      width: parent.width
      text: track_data.strTrack
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeLarge
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
    }
  }

  TabView {
    id: tabs

    anchors {
      top: album_thumb.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
    }

    currentIndex: 0

    header: TabBar {
      model: tab_model
    }

    model: [info_tab, lyrics_tab, videos_tab]
    
    Component {
      id: info_tab
      
      TabItem {
        //flickable: info_page.flickable
        TrackInfoPage {
          id: info_page
          height: track_page.height
          width: track_page.width
          
          artist_data: track_page.artist_data
          album_data: track_page.album_data
          track_data: track_page.track_data
        }
      }
    }

    Component {
      id: lyrics_tab

      TabItem {
        flickable: lyrics_page.flickable
        visible: Boolean(app.lyrics[track_data.idTrack])

        LyricsPage {
          id: lyrics_page
          height: track_page.height
          width: track_page.width
          
          artist_data: track_page.artist_data
          album_data: track_page.album_data
          track_data: track_page.track_data
          lyrics_requested: track_page.lyrics_requested
        }
      }
    }

    Component {
      id: videos_tab

      TabItem {
        visible: true

        VideosPage {
          id: videos_page
          height: track_page.height
          width: track_page.width
          
          artist_data: track_page.artist_data
          album_data: track_page.album_data
          track_data: track_page.track_data
          videos: track_page.videos
          media_requested: track_page.media_requested
        }
      }
    }
  }

  ListModel {
    id: tab_model

    ListElement {
      title: "Info"
    }
    
    ListElement {
      title: "Lyrics"
    }

    ListElement {
      title: "Media"
    }

  }

   
  Component.onCompleted: {
    app.signal_videos_list.connect(handle_videos_list)
    app.signal_lyrics.connect(handle_lyrics)

    if (settings.lookup_lyrics && !app.lyrics[track_data.idTrack] && track_data.strTrack.length && track_data.strArtist.length) {
      lyrics_requested = true;
      python.get_lyrics(track_data.strArtist, track_data.strTrack, track_data.idTrack)
    }

    if (app.videos_list[track_data.idTrack]) videos = app.videos_list[track_data.idTrack]
    else if (settings.lookup_video_yt) {
      media_requested = true
      python.search_media_yt(track_data.strArtist, track_data.strTrack, track_data.idTrack)
    }
  }

  Component.onDestruction: {
    app.signal_videos_list.disconnect(handle_videos_list)
    app.signal_lyrics.disconnect(handle_lyrics)
  }


  function handle_videos_list(details) {
    if (track_data.idTrack != details.track_id) {
      app.videos_list[details.track_id] = details.videos
      return;
    }
    
    media_requested = false
    app.videos_list[details.track_id] = details.videos
    videos = details.videos
  }

  function handle_lyrics(details) {
    lyrics_requested = false
  }
}
