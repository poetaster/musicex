import QtQuick 2.0
import io.thp.pyotherside 1.5

Python {
  id: python

  Component.onCompleted: {
    setHandler('artists_details', artists_details);
    setHandler('top_albums', top_albums);
    setHandler('albums_details', albums_details);
    setHandler('tracks_details', tracks_details);
    setHandler('videos_details', videos_details);
    setHandler('lyrics_details', lyrics_details);
    setHandler('videos_list', videos_list);
    setHandler('media_download', media_download);
    setHandler('search_results', search_results);
    setHandler('cache_rebuild', cache_rebuild);
    setHandler('error', error_handler);

    addImportPath(Qt.resolvedUrl('../../src'));
    importModule('audiodb', function () {});
    importModule('lyricsmania', function () {});
    importModule('youtube', function () {});
    importModule('settings', function () {
      app.track_volumes = call_sync('settings.settings_object.load_track_volumes', [])
      const settings = call_sync('settings.settings_object.load_track_volumes', [])
      app.signal_settings(settings)
    });
  }

  Component.onDestruction: {
    save_cache()
    save_settings()
  }

  onError: {
    console.log('ERROR - unhandled error received:', traceback);
  }

  onReceived: {
    console.log('ERROR - unhandled data received:', data);  
  }

  function error_handler(module_id, method_id, description) {
    console.log('Module ERROR - source:', module_id, method_id, 'error:', description);
    app.signal_error(module_id, method_id, description);
  }

  function search_artist_details(search_s) {
    call('audiodb.audiodb_object.search_artist_details', [encodeURIComponent(search_s)])
    //call('audiodb.audiodb_object.search_items', [search_s])
  }

  function search_cache_details(search_s) {
    return call_sync('audiodb.audiodb_object.search_cache_details', [search_s])
  }

  function get_artist_details(artist_id) {
    call('audiodb.audiodb_object.get_artist_details', [artist_id])
  }

  function get_random_artist_details() {
    call('audiodb.audiodb_object.get_random_artist_details', [])
  }

  function get_top_albums() {
    call('audiodb.audiodb_object.get_top_albums', [])
  }

  function get_top_albums_by_track_ids(track_ids) {
    call('audiodb.audiodb_object.get_top_albums_by_track_ids', [track_ids])
  }
  
  function get_albums(artist_id) {
    call('audiodb.audiodb_object.get_albums', [artist_id])
  }

  function get_tracks(album_id) {
    call('audiodb.audiodb_object.get_tracks', [album_id])
  }

  function get_track_cache(track_id) {
    return call_sync('audiodb.audiodb_object.get_track', [track_id])
  }

  function get_videos(artist_id) {
    call('audiodb.audiodb_object.get_videos', [artist_id])
  }

  function get_lyrics(artist_name, track_name, track_id) {
    call('lyricsmania.lyricsmania_object.get_lyrics', [artist_name, track_name, track_id])
  }

  function search_media_yt(artist_name, track_name, track_id) {
    call('youtube.youtube_object.search_media', [artist_name, track_name, track_id])
  }

  function get_audio_stream_yt(track_id, video_id) {
    call('youtube.youtube_object.get_audio_stream', [track_id, video_id])
  }

  function find_download_media_yt(artist_name, track_name, track_id, length) {
    call('youtube.youtube_object.find_download_media', [artist_name, track_name, track_id, length])
  }

  function get_local_media(track_id, video_id) {
    var params = []
    if (track_id) {
      params.push(track_id)
      if (video_id) params.push(video_id)
    }
    return call_sync('youtube.youtube_object.get_local_media', params);
  }

  function get_local_media_first(track_id, video_id) {
    var params = [track_id]
    if (video_id) params.push(video_id)
    return call_sync('youtube.youtube_object.get_local_media_first', params);
  }

  function has_local_media(track_id, video_id) {
    var params = [track_id]
    if (video_id) params.push(video_id)

    return call_sync('youtube.youtube_object.has_local_media', params);
  }

  function delete_local_media(track_id, video_id) {
    if (video_id) return call_sync('youtube.youtube_object.delete_local_media', [track_id, video_id]);
    return call_sync('youtube.youtube_object.delete_local_media', [track_id]);
  }

  function get_media_folder_items(folder_path) {
    return call_sync('youtube.youtube_object.get_media_folder_items', [folder_path]);
  }

  function get_cache_stats_adb(track_id) {
    return call_sync('audiodb.audiodb_object.get_cache_stats', [])
  }

  function clear_cache_adb() {
    return call_sync('audiodb.audiodb_object.clear_cache', [])
  }


  function get_cache_stats_yt(track_id) {
    return call_sync('youtube.youtube_object.get_cache_stats', [])
  }

  function clear_cache_yt() {
    return call_sync('youtube.youtube_object.clear_cache', [])
  }

  function delete_local_media_files() {
    return call_sync('youtube.youtube_object.delete_local_media_files', [])
  }

  function rebuild_local_media_cache() {
    const local_files = call_sync('youtube.youtube_object.get_local_media', [])
    if (!local_files.length) return;

    console.log('rebuild_local_media_cache:', local_files.length);
    
    var track_ids = []
    for (var i = 0; i < local_files.length; i++) {
      const track_id = main_handler.media_file_to_track(local_files[i])
      track_ids.push(track_id);
      //if (i > 10) break;
    }

    call('audiodb.audiodb_object.rebuild_cache_by_track_ids', [track_ids]);
  }

  function save_cache() {
    console.log('save_cache')
    call_sync('audiodb.audiodb_object.save_cache', [])
    call_sync('youtube.youtube_object.save_cache', [])
    call_sync('lyricsmania.lyricsmania_object.save_cache', [])
  }

  function save_settings() {
    call_sync('settings.settings_object.save_track_volumes', [app.track_volumes])
  }

  function save_playlist(file_name, playlist_items) {
    return call_sync('youtube.youtube_object.save_playlist', [file_name, playlist_items])
  }

  //python signal handlers
  function artists_details(details) {
    app.signal_artists(details.artists)
  }

  function top_albums(details) {
    if (!details) return;
    app.signal_top_albums(details)
  }

  function albums_details(details) {
    if (!details) {
      return
    }

    details.album.sort(function(a, b) {
      return a.intYearReleased - b.intYearReleased;
    });

    app.signal_albums(details.album)
  }

  function tracks_details(details) {
    details.track.sort(function(a, b) {
      const a_disc = a.intCD || 1
      const b_disc = b.intCD || 1

      if (a_disc === b_disc) return a.intTrackNumber - b.intTrackNumber;
      return a_disc - b_disc;
    });

    for (var i = 0; i < details.track.length; i++) {
      details.track[i].local_media_file = get_local_media_first(details.track[i].idTrack)
    }

    app.signal_tracks(details.track)
  }

  function videos_details(details) {
    if (!details) {
      return
    }

    app.signal_videos(details)

    if (details.artist_id && details.by_artist[details.artist_id]) {
      for (var i = 0; i < details.by_artist[details.artist_id].length; i++) {
        var video = details.by_artist[details.artist_id][i]
        app.video_by_track[video.idTrack] = video
        console.log('videos_details - track_id:',  video.idTrack, 'track:', video.strTrack, 'video_id:', video.video_id)
      }
    }
  }

  function lyrics_details(details) {
    if (!details || !details.track_id) {
      return
    }
  
    app.lyrics[details.track_id] = details.lyrics
    app.signal_lyrics(details)
  }

  function videos_list(details) {
    if (!details || !details.videos) {
      return
    }
    app.signal_videos_list(details)
  }

  function media_download(details) {
    console.log('media_download - status:', details.status);
    app.signal_media_download(details)

    if (details.status == 'complete') {
      main_handler.add_playlist_item(details.file_name)
    }
  }

  function cache_rebuild(details) {
    console.log('cache_rebuild - percent:', details.percent);
    app.signal_cache_rebuild(details)
  }

  function search_results(details) {
    console.log('search_results - status:', search_results.length);
    app.signal_search_results(details)
  }
}

