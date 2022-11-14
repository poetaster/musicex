import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow {
  id: app

  property var video_by_track: {'_null': null}
  property var lyrics: {'_null': null}
  property var videos_list: {'_null': null}
  property var track_volumes: {'_null': null}
  //property var local_media: {'_null': null}
  property string cover_image: ''

  signal signal_error(string module_id, string method_id, string description)
  signal signal_settings(var settings)
  signal signal_artists(var artists)
  signal signal_top_albums(var top_albums)
  signal signal_albums(var albums)
  signal signal_tracks(var tracks)
  signal signal_videos(var videos)
  signal signal_lyrics(var lyrics)
  signal signal_videos_list(var videos)
  signal signal_media_download(var media)
  signal signal_search_results(var search_results)
  signal signal_cache_rebuild(var cache_status)

  Settings {
    id: settings
  }

  NotificationsHandler {
    id: notifications_handler
  }

  MainHandler {
    id: main_handler
  }

  PythonHandler {
    id: python
  }

  initialPage: Component { 
    id: initial_page

    MainPage {
      id: main_page
    }
  }

  cover: Component {
    CoverPage {
      id: cover_page
    }
  }

  Component.onCompleted: {
    Qt.application.name = "musicex";
    Qt.application.organization = "app.qml";
  }
}
