import QtQuick 2.2
import Sailfish.Silica 1.0   

Item {
  id: item

  property var artist_data
  property var albums_data: []
  property int albums_count: 0
  property int display_index: 0
  
  width: parent.width
  height: childrenRect.height

  CachedImage {
    id: top_image
    remote_source: artist_data.strArtistWideThumb || artist_data.strArtistFanart || artist_data.strArtistThumb
    visible: source != ""
    width: parent.width
    height: visible ? 600 : 0
    fillMode: Image.PreserveAspectCrop
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
    }
  }

  GridView {
    id: albums_grid

    width: parent.width
    height: childrenRect.height //100 * Math.ceil(albums_data.length / 10)
    cellWidth: parent.width/10
    cellHeight: cellWidth

    anchors {
      top: top_image.bottom
    }
    enabled: false
    model: albums_data

    delegate: CachedImage {
      id: album_thumb
      height: 100
      width: height
      fillMode: Image.PreserveAspectCrop
      remote_source: modelData.strAlbumThumb
      preview: true
    }
  }

  MouseArea {
    width: parent.width
    anchors {
      top: top_image.top
      bottom: albums_grid.bottom
    }

    onClicked: {
      pageStack.push("AlbumsPage.qml", {'artist_data': artist_data, 'albums_data': albums_data})
    }
  }

  CachedImage {
    id: artist_thumb
    fillMode: Image.PreserveAspectFit
    remote_source: artist_data.strArtistThumb
    preview: true
    anchors {
      top: albums_grid.bottom
      right: parent.right
    }
  }

  Column {
    id: info_column

    anchors {
      top: albums_grid.bottom
      left: parent.left
      right: artist_thumb.left
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
    }

    Label { 
      text: artist_data.strArtist
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeLarge
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
    }

    Row {
      spacing: 10

      Label {
        visible: text != '0'
        text: Boolean(artist_data.intDiedYear) ? artist_data.intBornYear : (artist_data.intFormedYear || artist_data.intBornYear)
        font.pixelSize: Theme.fontSizeSmall
      }

      Label {
        visible: died_year_label.visible
        text: '-'
        font.pixelSize: Theme.fontSizeSmall
      }

      Label {
        id: died_year_label
        visible: Boolean(artist_data.intDiedYear)
        text: artist_data.intDiedYear
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    Label { 
      visible: Boolean(artist_data.strLabel)
      text: String(artist_data.strLabel)
      font.pixelSize: Theme.fontSizeSmall
    }

    Row {
      spacing: 10

      Label {
        id: style_label
        visible: Boolean(artist_data.strStyle)
        text: artist_data.strStyle 
        font.pixelSize: Theme.fontSizeSmall
      }

      Label {
        visible: genre_label.visible && style_label.visible
        text: '•'
        font.pixelSize: Theme.fontSizeSmall
      }

      Label { 
        id: genre_label
        visible: Boolean(artist_data.strGenre)
        text: artist_data.strGenre
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    Row {
      LinkedLabel {
        visible: Boolean(artist_data.strWebsite)
        text: '<a href="' + add_protocol(artist_data.strWebsite) + '">' + remove_protocol(artist_data.strWebsite) + '</a>'
        defaultLinkActions: true
        font.pixelSize: Theme.fontSizeSmall
      }
    }
  }

  Column {
    id: main_column
    anchors {
      top: info_column.height > artist_thumb.height ? info_column.bottom : artist_thumb.bottom
      left: parent.left
      right: parent.right
      topMargin: Theme.paddingLarge
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
    }

    Label { 
      text: artist_data.strBiographyEN
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
      anchors {
        left: parent.left
        right: parent.right
      }
    }
  }

  function add_protocol(url) {
    if (url.indexOf('https://') !== -1 || url.indexOf('http://') !== -1) return url;
    return 'http://' + url
  }

  function remove_protocol(url) {
    return url.replace(/^https?:\/\//, '')
  }

  function handle_albums(data) {
    for (var i = 0; i < data.length; i++) {
      if (!artist_data) continue;
      if (data[i].idArtist == artist_data.idArtist) {
        albums_data = data
        break
      }
    }
  }

  Component.onCompleted: {
    app.signal_albums.connect(handle_albums)
  }

  Component.onDestruction: {
    app.signal_albums.disconnect(handle_albums)
  }
}

