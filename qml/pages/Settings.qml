import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

ConfigurationGroup {
  id: settings
  path: '/apps/app.qml/musicex/'

  property alias lookup_lyrics: cv_lookup_lyrics.value
  property alias lookup_video_yt: cv_lookup_video_yt.value
  property alias initial_items_display: cv_initial_items_display.value

  ConfigurationValue{
    id: cv_lookup_lyrics
    key: "/lookup_lyrics"
    defaultValue: true
  }

  ConfigurationValue{
    id: cv_lookup_video_yt
    key: "/lookup_video_yt"
    defaultValue: true
  }

  ConfigurationValue{
    id: cv_initial_items_display
    key: "/initial_items_display"
    defaultValue: 2
  }
}
