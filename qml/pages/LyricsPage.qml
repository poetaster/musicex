import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          

Item {
  id: lyrics_page

  property var artist_data
  property var album_data
  property var track_data
  property alias flickable: flickable
  property bool lyrics_requested
  property var verses: []
  anchors.fill: parent

  SilicaFlickable {
    id: flickable

    anchors.fill: parent

    VerticalScrollDecorator { 
      flickable: flickable 
    }

    ViewPlaceholder {
      enabled: !settings.lookup_lyrics
      text: "Disabled"
      hintText: "Lyrics disabled"
    }

    contentHeight: lyrics_column.height

    Column {
      id: lyrics_column

      width: parent.width; 
      //height: lyrics_label.height

      anchors {
        topMargin: Theme.paddingLarge
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
        bottomMargin: Theme.paddingLarge
      }

      Repeater {
        model: verses
        delegate: ListItem {
          contentHeight: lyrics_label.height + Theme.paddingLarge
          
          menu: ContextMenu {
            id: context_menu
            MenuItem {
              text: "Copy text"
              onClicked: {
                Clipboard.text = modelData
              }
            }
          }

          Label {
            id: lyrics_label
            text: modelData 
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall

            anchors {
              left: parent.left
              right: parent.right
              leftMargin: Theme.paddingMedium
              rightMargin: Theme.paddingMedium
              bottomMargin: Theme.paddingLarge
            }
          }
        }

      }
    }
  }

  BusyIndicator {
    size: BusyIndicatorSize.Large
    anchors.centerIn: flickable
    running: lyrics_requested
  }

  Component.onCompleted: {
    app.signal_lyrics.connect(handle_lyrics)
    load_lyrics()
  }

  Component.onDestruction: {
    app.signal_lyrics.disconnect(handle_lyrics)
  }

  function load_lyrics() {
    if (!app.lyrics[track_data.idTrack]) return;
    verses = app.lyrics[track_data.idTrack].split('\n\n');
  }

  function handle_lyrics(lyrics) {
    load_lyrics()
  }
}
