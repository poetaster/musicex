import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: main_page

  property var artists: []
  property bool data_requested: false

  SilicaListView {
    id: list_view

    width: parent.width; 
    height: parent.height
    
    //currentIndex: -1

    model: ListModel { 
      id: list_model
    }

    spacing: 10

    PullDownMenu {
      MenuItem {
        text: "Storage"
        onClicked: pageStack.push("StoragePage.qml", {})
      }

      MenuItem {
        text: "Settings"
        onClicked: pageStack.push("SettingsDialog.qml", {})
      }

      MenuItem {
        //visible: main_handler.player_available
        text: "Player"
        onClicked: {
          pageStack.push("PlayerPage.qml", {})
        }
      }
    }

    header: SearchField {
      id: search_field
      enabled: !data_requested
      width: parent.width
      placeholderText: "Search artist"

      onTextChanged: {
        placeholder.text = ''
        if (search_field.text.length > 1) handle_search_results(python.search_cache_details(search_field.text))
        else if (search_field.text.length < 1) request_default_data()
      }

      Keys.onReturnPressed: {
        data_requested = true
        
        python.search_artist_details(search_field.text)
        search_field.focus = true
      }
    }

    delegate: Loader {
      id: loader

      sourceComponent: {
        if (object_type == 'artist') return artist_info_item;
        if (object_type == 'top_album') return top_album_item;
        if (object_type == 'search_result') return search_result_item;
        else return search_result_item
      }

      onLoaded: {
        loader.item.width = parent.width
        if (object_type == 'artist') {
          loader.item.artist_data = model_data
          loader.item.display_index = index
          python.get_albums(model_data.idArtist)
        } else if (object_type == 'top_album') {
          loader.item.top_album_data = model_data
          loader.item.display_index = index
        } else if (object_type == 'search_result') {
          loader.item.search_result_data = model_data
          loader.item.display_index = index
        } else {

        }
      }
    }
    
    ArtistInfoFullComponent {
      id: artist_info_item
    }
    TopAlbumItem {
      id: top_album_item
    }
    SearchResultItem {
      id: search_result_item
    }
  }

  BusyIndicator {
    size: BusyIndicatorSize.Large
    anchors.centerIn: list_view
    running: data_requested
  }

  ViewPlaceholder {
    id: placeholder
    enabled: list_model.count < 1
    text: ''
    hintText: "Press ⏎ to search"
  }
   
  Component.onCompleted: {
    app.signal_settings.connect(handle_settings)
    app.signal_artists.connect(handle_artists)
    app.signal_top_albums.connect(handle_top_albums)
    app.signal_search_results.connect(handle_search_results)
  }

  Component.onDestruction: {
    app.signal_settings.disconnect(handle_settings)
    app.signal_artists.disconnect(handle_artists)
    app.signal_top_albums.disconnect(handle_top_albums)
    app.signal_search_results.disconnect(handle_search_results)
  }

  function request_default_data() {
    if (settings.initial_items_display == 1) {
      data_requested = true
      python.get_random_artist_details()
    } else if (settings.initial_items_display == 2) {
      data_requested = true
      python.get_top_albums()
    } else if (settings.initial_items_display == 3) {
      data_requested = true

      var track_ids = []
      const local_media = python.get_local_media()
      for (var i = 0; i < local_media.length; i++) {
        console.log('handle_settings - local_media:', local_media[i])
        const track_id = main_handler.media_file_to_track(local_media[i])
        if (!track_id) continue;
        track_ids.push(track_id)
      }
      if (track_ids.length) python.get_top_albums_by_track_ids(track_ids)
      else data_requested = false
    }
  }

  function handle_artists(data) {
    data_requested = false
    list_model.clear()

    if (!data || data.length < 1) {
      placeholder.text = 'No results'
      return
    }

    for (var i = 0; i < data.length; i++) {
      if (i == 0) app.cover_image = String(data[i].strArtistThumb || data[i].strArtistFanart)
      list_model.append({'object_type': 'artist', model_data: data[i]})
    }
    list_view.currentIndex = 0
    
  }

  function handle_top_albums(data) {
    data_requested = false
    
    data.sort(function(a, b) {
      if (a.album.strAlbum < b.album.strAlbum) { return -1; }
      if (a.album.strAlbum > b.album.strAlbum) { return 1; }
      return 0;
    });

    list_model.clear()
    for (var i = 0; i < data.length; i++) {
      if (app.cover_image.length < 1) app.cover_image = data[i].top_image
      list_model.append({'object_type': 'top_album', model_data: data[i]})
    }
    list_view.currentIndex = 0
  }

  function handle_search_results(data) {
    data_requested = false
    
    console.log('handle_search_results:', data.length)
    list_view.currentIndex = -1
    list_model.clear()
    for (var i = 0; i < data.length; i++) {
      list_model.append({'object_type': 'search_result', model_data: data[i]})
    }
  }

  function handle_settings(data) {
    request_default_data()
  }


}
