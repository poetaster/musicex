import QtQuick 2.2
import Sailfish.Silica 1.0   

Component {
  Item {
    id: item

    property var search_result_data
    property int display_index: 0
   
    width: parent.width
    height: childrenRect.height > Theme.itemSizeLarge ? childrenRect.height : Theme.itemSizeLarge

    Icon {
      source: {
        if (search_result_data.object_type == 'artist') return "image://theme/icon-m-media-artists"
        if (search_result_data.object_type == 'album') return "image://theme/icon-m-media-albums"
        return "image://theme/icon-m-media-songs"
      }
      anchors {
        verticalCenter: parent.verticalCenter
        leftMargin: Theme.paddingLarge
      }
    }

    CachedImage {
      id: image_thumb
      height: Theme.itemSizeMedium
      width: height
      fillMode: Image.PreserveAspectCrop
      remote_source: {
        if (search_result_data.object_type == 'artist') return search_result_data.strArtistThumb
        if (search_result_data.object_type == 'album') {
          if (search_result_data.strAlbumThumb) return search_result_data.strAlbumThumb
          else if (search_result_data.artist && search_result_data.artist.strArtistThumb) return search_result_data.artist.strArtistThumb
        }
        if (search_result_data.object_type == 'track') {
          if (search_result_data.strTrackThumb) return search_result_data.strTrackThumb
          else if (search_result_data.album && search_result_data.album.strAlbumThumb) return search_result_data.album.strAlbumThumb
          else if (search_result_data.artist && search_result_data.artist.strArtistThumb) return search_result_data.artist.strArtistThumb
        }
        return ''
      }
      preview: true
      anchors {
        verticalCenter: parent.verticalCenter
      }
    }

    Label {
      width: parent.width
      text: search_result_data.object_type
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
      anchors {
        bottom: image_thumb.bottom
        left: image_thumb.left
        leftMargin: Theme.paddingSmall
        bottomMargin: Theme.paddingSmall
      }
    }

    Column {
      id: main_column
      anchors {
        left: image_thumb.right
        right: parent.right
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
      }
      
      Label {
        width: parent.width
        text: search_result_data.strArtist
        wrapMode: Text.WordWrap
        font.pixelSize: search_result_data.object_type == 'artist' ? Theme.fontSizeMedium : Theme.fontSizeSmall
        color: search_result_data.object_type == 'artist' ? Theme.highlightColor : Theme.primaryColor
      }
      
      Row {
        visible: search_result_data.object_type == 'artist'

        Label {
          visible: text != '0'
          text: Boolean(search_result_data.intDiedYear) ? search_result_data.intBornYear : (search_result_data.intFormedYear || search_result_data.intBornYear)
          font.pixelSize: Theme.fontSizeExtraSmall
        }

        Label {
          visible: died_year_label.visible
          text: '-'
          font.pixelSize: Theme.fontSizeExtraSmall
        }

        Label {
          id: died_year_label
          visible: Boolean(search_result_data.intDiedYear)
          text: String(search_result_data.intDiedYear)
          font.pixelSize: Theme.fontSizeExtraSmall
        }
      }

      Label {
        width: parent.width
        visible: Boolean(search_result_data.strAlbum)
        text: String(search_result_data.strAlbum)
        wrapMode: Text.WordWrap
        font.pixelSize: search_result_data.object_type == 'album' ? Theme.fontSizeMedium : Theme.fontSizeSmall
        color: search_result_data.object_type == 'album' ? Theme.highlightColor : Theme.primaryColor
      }

      Label {
        width: parent.width
        visible: Boolean(search_result_data.strTrack)
        text: String(search_result_data.strTrack)
        wrapMode: Text.WordWrap
        font.pixelSize: search_result_data.object_type == 'track' ? Theme.fontSizeMedium : Theme.fontSizeSmall
        color: search_result_data.object_type == 'track' ? Theme.highlightColor : Theme.primaryColor
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        if (search_result_data.object_type == 'artist') pageStack.push("ArtistPage.qml", {'artist_data': search_result_data})
        else if (search_result_data.object_type == 'album') pageStack.push("AlbumPage.qml", {'album_data': search_result_data, 'artist_data': search_result_data.artist})
        else if (search_result_data.object_type == 'track') pageStack.push("TrackPage.qml", {'track_data': search_result_data, 'album_data': search_result_data.album, 'artist_data': search_result_data.artist})
      }
    }

    Component.onCompleted: {

    }

    Component.onDestruction: {

    }
  }
}
