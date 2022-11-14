import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          

Item {
  id: item

  property bool isCurrentItem
  property alias flickable: flickable
  property var artist_data
  property var album_data

  anchors.fill: parent

  SilicaFlickable {
    id: flickable

    width: item.width
    height: item.height

    contentHeight: main_column.height + Theme.paddingLarge

    Column {
      id: main_column
      height: childrenRect.height
      width: parent.width

      spacing: 10
      
      anchors {
        top: parent.top
        left: parent.left
      }

      CachedImage {
        id: album_thumb
        width: parent.width
        height: width

        fillMode: Image.PreserveAspectFit
        remote_source: album_data.strAlbumThumbHQ || album_data.strAlbumThumb
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: album_data.strAlbumThumbBack
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: album_data.strAlbumCDart
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: album_data.strAlbumCDspine
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistLogo
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistThumb
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistCutout
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistClearart
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistBanner
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistFanart
        width: parent.width
      }
      
      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistFanart1
        width: parent.width
      }
      
      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistFanart2
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistFanart3
        width: parent.width
      }

      CachedImage {
        fillMode: Image.PreserveAspectFit
        remote_source: artist_data.strArtistFanart4
        width: parent.width
      }
    }
  }

  Component.onCompleted: {

  }

  Component.onDestruction: {

  }
}

