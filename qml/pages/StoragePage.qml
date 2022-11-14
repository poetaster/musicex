import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          
import QtMultimedia 5.6

Page {
  id: storage_page

  property bool data_requested: false
  property int artists_c
  property int albums_c
  property int tracks_c
  property int adb_size 
  property int videos_c
  property int images_c
  property int images_size
  property int media_c
  property int yt_size
  property int media_size
  property int media_fs_size
  property int media_fs_available  

  anchors.fill: parent

  Timer {
    id: data_load_timer
    interval: 500
    running: false
    repeat: false
    onTriggered: {
      load_stats()
    }
  }

  SilicaFlickable {
    id: flickable

    anchors.fill: parent

    PullDownMenu {
      MenuItem {
        text: "Rebuild local media cache"
        enabled: media_c > 0
        onClicked: {
          enabled = false
          python.rebuild_local_media_cache()
        }
      }

      MenuItem {
        text: "Clear cache"
        enabled: artists_c + albums_c + tracks_c + videos_c > 0
        onClicked: {
          Remorse.popupAction(storage_page, "Deleted all cached entries", function() {  
            data_requested = true
            python.clear_cache_adb()
            python.clear_cache_yt()
            load_stats()
          })
        }
      }

      MenuItem {
        text: "Delete all media"
        enabled: media_c > 0
        onClicked: {
          Remorse.popupAction(storage_page, "Deleted all media files", function() {  
            data_requested = true
            python.delete_local_media_files()
            load_stats()
          })
        }
      }
    }

    VerticalScrollDecorator { 
      flickable: flickable 
    }

    SectionHeader {
      id: header_1
      text: "Local cache"
    }

    Column {
      id: adb_cache_column
      width: parent.width

      anchors {
        left: parent.left
        top: header_1.bottom
        leftMargin: Theme.paddingLarge
        rightMargin: Theme.paddingLarge
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Artists"
        }
        Label {
          text: artists_c
        }
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Albums"
        }
        Label {
          text: albums_c
        }
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Tracks"
        }
        Label {
          text: tracks_c
        }
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Videos"
        }
        Label {
          text: videos_c
        }
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Cache size"
        }
        Label {
          text: Format.formatFileSize(adb_size + yt_size)
        }
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Images"
        }
        Label {
          text: images_c
        }
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Images storage used"
        }
        Label {
          text: Format.formatFileSize(images_size)
        }
      }
    }

    SectionHeader {
      id: header_2
      text: "Local media"
      anchors {
        top: adb_cache_column.bottom
      }
    }

    Column {
      id: medis_cache_column
      width: parent.width

      anchors {
        left: parent.left
        top: header_2.bottom
        leftMargin: Theme.paddingLarge
        rightMargin: Theme.paddingLarge
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Media files"
        }
        Label {
          text: media_c
        }
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Storage used"
        }
        Label {
          text: Format.formatFileSize(media_size)
        }
      }

/*
      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Storage size"
        }
        Label {
          text: Math.round(media_fs_size / 1048576) + " MB"
        }
      }

      Row {
        width: parent.width

        Label {
          width: parent.width / 2
          text: "Storage available"
        }
        Label {
          text: Math.round(media_fs_available / 1048576) + " MB"
        }
      }
*/
    }
  }

  BusyIndicator {
    size: BusyIndicatorSize.Large
    anchors.centerIn: storage_page
    running: data_requested
  }

  Component.onCompleted: {
    data_requested = true
    data_load_timer.start()
  }

  function load_stats() {
    data_requested = true

    const adb_cache_stats = python.get_cache_stats_adb();
    artists_c = adb_cache_stats.artists
    albums_c = adb_cache_stats.albums
    tracks_c = adb_cache_stats.tracks
    adb_size = adb_cache_stats.file_size
    images_c = adb_cache_stats.images
    images_size = adb_cache_stats.images_size
    const yt_cache_stats = python.get_cache_stats_yt();
    videos_c = yt_cache_stats.videos
    yt_size = yt_cache_stats.file_size
    media_c = yt_cache_stats.media_files
    media_size = yt_cache_stats.media_files_size
    media_fs_size = yt_cache_stats.fs_size
    media_fs_available = yt_cache_stats.fs_available

    data_requested = false
  }
}
