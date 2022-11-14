import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          
import QtMultimedia 5.6

Cover {
  id: cover_page

  transparent: true

  Label {
    visible: !track_label.visible
    anchors.centerIn: parent
    font.pixelSize: Theme.fontSizeLarge
    text: "Music Explorer"
  }

  CachedImage {
    id: background_image
    remote_source: main_handler.player_artwork || app.cover_image
    width: parent.width
    height: parent.height
    fillMode: Image.PreserveAspectCrop
    anchors {
      fill: parent
    }
  }

  Label {
    id: time_label
    visible: main_handler.audio_player.position > 0
    wrapMode: Text.WordWrap
    horizontalAlignment: Text.AlignHCenter
    font.pixelSize: Theme.fontSizeHuge
    text: main_handler.seconds_to_minutes_seconds(Math.round(main_handler.audio_player.position/1000))
    width: parent.width
    color: Theme.highlightColor
    opacity: main_handler.audio_player.playbackState == Audio.PlayingState ? 1.0 : Theme.opacityHigh
    anchors {
      top: parent.top
      topMargin: Theme.paddingMedium
      bottomMargin: Theme.paddingLarge
    }
  }

  Label {
    id: track_label
    visible: Boolean(main_handler.player_track_name)
    wrapMode: Text.WordWrap
    horizontalAlignment: Text.AlignHCenter
    font.pixelSize: Theme.fontSizeMedium
    text: main_handler.player_track_name
    width: parent.width
    anchors {
      top: time_label.bottom
    }
  }

  Label {
    id: album_label

    wrapMode: Text.WordWrap
    horizontalAlignment: Text.AlignHCenter
    font.pixelSize: Theme.fontSizeExtraSmall
    text: main_handler.player_album_name
    width: parent.width
    anchors {
      top: track_label.bottom
    }
  }

  Label {
    id: artist_label
    wrapMode: Text.WordWrap
    horizontalAlignment: Text.AlignHCenter
    font.pixelSize: Theme.fontSizeSmall
    text: main_handler.player_artist_name
    width: parent.width
    anchors {
      top: album_label.bottom
    }
  }

  CoverActionList {
    enabled: main_handler.playlist.itemCount > 0 && main_handler.audio_player.playbackState != Audio.PlayingState

    CoverAction {
      iconSource: "image://theme/icon-cover-play"
      onTriggered: main_handler.audio_player.play()
    }

    CoverAction {
      iconSource: "image://theme/icon-cover-next-song"
      onTriggered: main_handler.playlist.next()
    }
  }

  CoverActionList {
    enabled: main_handler.audio_player.playbackState == Audio.PlayingState

    CoverAction {
      iconSource: "image://theme/icon-cover-pause"
      onTriggered: main_handler.audio_player.pause()
    }

    CoverAction {
      iconSource: "image://theme/icon-cover-next-song"
      onTriggered: main_handler.playlist.next()
    }
  }

  Component.onCompleted: {

  }

  Component.onDestruction: {

  }
}
