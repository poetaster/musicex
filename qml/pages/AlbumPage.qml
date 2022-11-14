import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          
import Sailfish.Silica.private 1.0  

Page {
  id: album_page

  property var artist_data
  property var album_data
  property var tracks: []

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
      text: album_data.strArtist 
      font.pixelSize: Theme.fontSizeSmall
      truncationMode: TruncationMode.Fade
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
    }

    Label { 
      id: album_name_label
      width: parent.width
      text: album_data.strAlbum
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeLarge
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
    }
    
    Label { 
      text: album_data.intYearReleased 
      font.pixelSize: Theme.fontSizeSmall
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

    model: [info_tab, tracks_tab, artwork_tab]
    
    Component {
      id: info_tab
      
      TabItem {
        //flickable: album_page.flickable
        AlbumInfoPage {
          id: info_page
          height: album_page.height
          width: album_page.width
          
          artist_data: album_page.artist_data
          album_data: album_page.album_data
        }
      }
    }

    Component {
      id: tracks_tab
      TabItem {
        //flickable: album_page.flickable
        TracksPage {
          id: tracks_page
          height: album_page.height
          width: album_page.width
          
          artist_data: album_page.artist_data
          album_data: album_page.album_data
        }
      }
    }

    Component {
      id: artwork_tab
      TabItem {
        //flickable: album_page.flickable
        AlbumArtworkPage {
          id: artwork_page
          height: album_page.height
          width: album_page.width
          
          artist_data: album_page.artist_data
          album_data: album_page.album_data
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
      title: "Tracks"
    }

    ListElement {
      title: "Artwork"
    }
  }

   
  Component.onCompleted: {
    app.signal_tracks.connect(handle_tracks)
    python.get_tracks(album_data.idAlbum)
  }

  Component.onDestruction: {
    app.signal_tracks.disconnect(handle_tracks)
  }

  function handle_tracks(data) {
    tracks = data
  }
}
