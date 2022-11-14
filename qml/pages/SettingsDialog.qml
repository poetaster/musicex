import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Dialog {
  id: settings_dialog

  RemorseItem { id: remorse_item }

  SilicaFlickable {
    anchors.fill: parent

    contentHeight: main_column.height

    VerticalScrollDecorator {}

    Column {
      id: main_column

      width: parent.width
      
      anchors {
        left: parent.left
        top: parent.top
      }

      DialogHeader {

      }

      SectionHeader {
        text: "Settings"
      }

      TextSwitch {
        id: lookup_lyrics_switch
        checked: settings.lookup_lyrics
        text: "Fetch lyrics"
        description: "Display lyrics if available."
      }

      TextSwitch {
        id: lookup_video_yt_switch
        checked: settings.lookup_video_yt
        text: "Search for media"
        description: "Search and display media for individual song/track."
      }

      ComboBox {
        id: initial_display_switch
        width: parent.width
        label: "Start page items"
        currentIndex: settings.initial_items_display

        menu: ContextMenu {
          MenuItem { text: "None" }
          MenuItem { text: "Random artist" }
          MenuItem { text: "Random tracks" }
          MenuItem { text: "Downloaded albums" }
        }
      }
    }
  }

  onOpened: {
   
  }

  onAccepted: {
    settings.lookup_lyrics = lookup_lyrics_switch.checked
    settings.lookup_video_yt = lookup_video_yt_switch.checked
    settings.initial_items_display = initial_display_switch.currentIndex
  }

  onRejected: {

  }

  onDone: {

  }

  onStatusChanged: {

  }
}
