# -*- coding: utf-8 -*-
import json
import time
import os
import re
import glob
import urllib.request
import random
import pyotherside
import musicbrainz

class Audiodb:
  URL_ARTIST_BY_NAME="https://theaudiodb.com/api/v1/json/2/search.php?s={}"
  URL_ARTIST_BY_ID="https://theaudiodb.com/api/v1/json/2/artist.php?i={}"
  URL_ARTIST_BY_MBID="https://theaudiodb.com/api/v1/json/2139078587215309723505/artist-mb.php?i={}"
  URL_DISCOGRAPHY_BY_NAME="https://theaudiodb.com/api/v1/json/2/discography.php?s={}"
  URL_ALBUMS_BY_ARTIST_ID="https://theaudiodb.com/api/v1/json/2/album.php?i={}"
  URL_ALBUM_BY_ID="https://theaudiodb.com/api/v1/json/2/album.php?m={}"
  URL_TRACKS_BY_ALBUM_ID="https://theaudiodb.com/api/v1/json/2/track.php?m={}"
  URL_VIDEOS_BY_ARTIST_ID="https://theaudiodb.com/api/v1/json/2/mvid.php?i={}"
  URL_TRACK_BY_ID="https://theaudiodb.com/api/v1/json/2/track.php?h={}"
  URL_ALBUMS_TRENDING="https://theaudiodb.com/api/v1/json/2139078587215309723505/trending.php?country=us&format=albums"
  URL_TRACKS_LOVED="https://theaudiodb.com/api/v1/json/2139078587215309723505/mostloved.php?format=track"
  CACHE_FILE = "audiodb_cache.json"
  CACHE_EXPIRY = 604800 #seconds

  def __init__(self):
    print('Audiodb init')
    self.cache_directory = os.environ['HOME'] + "/.local/share/app.qml/musicex/"
    self.artwork_cache_directory = os.environ['HOME'] + "/.cache/app.qml/musicex/"
    self.cache = {}
    self.musicbrainz = musicbrainz.Musicbrainz()

  def format_error(self, err):
    return 'ERROR: %s' % err

  def ensure_cache(self):
    if not self.cache or len(self.cache) < 2:
      self.load_cache()

  def load_cache(self, force_load = False):
    if len(self.cache) > 8 and not force_load:
      return True

    try:
      with open(self.cache_directory + self.CACHE_FILE) as cache_file:
        self.cache = json.load(cache_file)
    except Exception as err:
      print('Audiodb load_cache - error: ', err)
      #pyotherside.send("error", "audiodb", "load_cache", self.format_error(err))

    if not self.cache:
      self.cache = {'created_at': int(time.time())}

    if not 'artists' in self.cache:
      self.cache['artists'] = {}

    if not 'artist_ids_by_name' in self.cache:
      self.cache['artist_ids_by_name'] = {}

    if not 'albums' in self.cache:
      self.cache['albums'] = {}

    if not 'album_ids_by_artist_id' in self.cache:
      self.cache['album_ids_by_artist_id'] = {}

    if not 'tracks' in self.cache:
      self.cache['tracks'] = {}

    if not 'track_ids_by_album_id' in self.cache:
      self.cache['track_ids_by_album_id'] = {}

    if not 'videos' in self.cache:
      self.cache['videos'] = {}

    if not 'video_ids_by_artist_id' in self.cache:
      self.cache['video_ids_by_artist_id'] = {}

    print('Audiodb load_cache - artists: ', len(self.cache['artists']), 'albums:', len(self.cache['albums']), 'tracks:', len(self.cache['tracks']), 'videos:', len(self.cache['videos']))

    return True

  def save_cache(self):
    if len(self.cache) < 2:
      return False

    try:
      os.makedirs(self.cache_directory)
    except FileExistsError:
      pass
    except Exception as err:
      print('Audiodb save_cache - error: ', err)
      pyotherside.send("error", "audiodb", "save_cache", self.format_error(err))
      return False

    self.cache['updated_at'] = int(time.time())
    try:
      with open(self.cache_directory + self.CACHE_FILE, 'w') as cache_file:
        json.dump(self.cache, cache_file, indent=2)
    except Exception as err:
      print('Audiodb save_cache - error: ', err)
      pyotherside.send("error", "audiodb", "save_cache", self.format_error(err))
      return False

  def cache_get(self, cache_key, cache_category):
    self.ensure_cache()
      
    cache_key_s = str(cache_key)

    if cache_key_s not in self.cache[cache_category]:
      print('Audiodb cache_get - no item - category:', cache_category, 'key:', cache_key_s)
      return None

    data = self.cache[cache_category][cache_key_s]
    if type(data) is dict and 'cache_created_at' in data and data['cache_created_at'] < int(time.time()) - self.CACHE_EXPIRY:
      print('Audiodb cache_get - expired item - category:', cache_category, 'key:', cache_key_s, 'created:', data['cache_created_at'], 'expired:', int(time.time()) - self.CACHE_EXPIRY)
      data['chache_expired'] = True
      return data

    print('Audiodb cache_get - item found - category:', cache_category, 'key:', cache_key_s)
    return data


  def cache_put(self, cache_key, cache_category, data):
    self.ensure_cache()
      
    cache_key_s = str(cache_key)
    if type(data) is dict:
      data['cache_created_at'] = int(time.time())
    self.cache[cache_category][cache_key_s] = data

  def cache_put_multi(self, cache_key_field, cache_category, data_d, data_category = None):
    entry_ids = []
    if not data_category:
      data_category = cache_category

    if not data_d or data_category not in data_d or not data_d[data_category]:
      return entry_ids
  
    for data in data_d[data_category]:
      self.cache_put(data[cache_key_field], cache_category, data)
      entry_ids.append(data[cache_key_field])

    return entry_ids

  def __url_get(self, url):
    print('url_get:', url)
    req = urllib.request.Request(
      url,
      headers={
        'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:100.0) Gecko/20100101 Firefox/100.0',
        'Content-Type': 'text/json; charset=UTF-8',
      }
    )

    try:
      result = urllib.request.urlopen(req).read()
    except Exception as err:
      print("### ERROR api request failed: %s" % err)
      return False

    try:
      return json.loads(result)

    except Exception as err:
      print("### ERROR converting result: %s" % err)
      return False

    return None


  def send_artist_details(self, artists):
    if not artists or len(artists) < 1:
      pyotherside.send("artists_details", {'artists': []})
    elif len(artists) > 1:
      for artist in artists:
        artist['object_type'] = 'artist'
      pyotherside.send("search_results", artists)
    else:
      pyotherside.send("artists_details", {'artists': artists})

  def search_artist_details(self, search_s):
    search_s = search_s.lower().strip()
    artists = []
    refresh_cache = False

    artist_ids = self.cache_get(search_s, 'artist_ids_by_name')
    if artist_ids:
      for artist_id in artist_ids:
        artist = self.cache_get(artist_id, 'artists')
        if artist:
          artists.append(artist)
        if 'chache_expired' in artist:
          refresh_cache = True

    if len(artists) > 0 and not refresh_cache:
      self.send_artist_details(artists)
      return True

    result = self.__url_get(self.URL_ARTIST_BY_NAME.format(search_s))

    if not result or not result['artists']:
      result = None
      artist_mbid = self.musicbrainz.search_artist_id(search_s)
      print("search_artist_details - retrying using mbid:", artist_mbid)
      if artist_mbid:
        result = self.__url_get(self.URL_ARTIST_BY_MBID.format(artist_mbid))

    if not result:
      self.send_artist_details(artists)
      return False

    self.send_artist_details(result['artists'])
    
    artist_ids = self.cache_put_multi('idArtist', 'artists', result)
    self.cache['artist_ids_by_name'][search_s] = artist_ids


  def search_items(self, search_s):
    results = []
    artists = self.musicbrainz.search_artists_score(search_s)
    albums = self.musicbrainz.search_albums_score(search_s)
    tracks = self.musicbrainz.search_tracks_score(search_s)

    if artists:
      results += artists
    if albums:
      results += albums
    if tracks:
      results += tracks

    pyotherside.send("search_results", results)

  def search_cache_details(self, search_s):
    search_s = search_s.lower().strip()
    search_results = []

    self.ensure_cache()

    for artist_id in self.cache['artists']:        
      if search_s in self.cache['artists'][artist_id]['strArtist'].lower():
        artist = self.cache['artists'][artist_id]
        artist['object_type'] = 'artist'
        search_results.append(artist)

    for album_id in self.cache['albums']:
      if search_s in self.cache['albums'][album_id]['strAlbum'].lower():
        album = self.cache['albums'][album_id]
        album['object_type'] = 'album'
        album['artist'] = self.cache_get(album['idArtist'], 'artists')
        search_results.append(album)

    for track_id in self.cache['tracks']:
      if search_s in self.cache['tracks'][track_id]['strTrack'].lower():
        track = self.cache['tracks'][track_id]
        track['object_type'] = 'track'
        track['artist'] = self.cache_get(track['idArtist'], 'artists')
        track['album'] = self.cache_get(track['idAlbum'], 'albums')
        search_results.append(track)

    return search_results


  def get_artist_details(self, artist_id):
    result = self.__url_get(self.URL_ARTIST_BY_ID.format(artist_id))
    pyotherside.send("artists_details", result)

  def get_random_artist_details(self):
    artist_ids = [126296, 146664, 146865, 112240, 111611, 111304, 146664, 148109, 114357, 150642, 154289, 111337, 114390, 160494, 165531, 115856]

    self.ensure_cache()

    for artist_id in self.cache['artists']:
      if artist_id in artist_ids:
        continue
      artist_ids.append(artist_id)

    artist_id = random.choice(artist_ids)

    artist = self.cache_get(artist_id, 'artists')
    if artist:
      pyotherside.send("artists_details", {'artists': [artist]})
      return True

    result = self.__url_get(self.URL_ARTIST_BY_ID.format(artist_id))
    pyotherside.send("artists_details", result)
    self.cache_put_multi('idArtist', 'artists', result)


  def get_top_album_by_track_id(self, track_id):
    track = self.cache_get(track_id, 'tracks')
    if not track:
      tracks = self.__url_get(self.URL_TRACK_BY_ID.format(track_id))
      track_ids = self.cache_put_multi('idTrack', 'tracks', tracks, 'track')

      if tracks and len(tracks['track']) > 0:
        track = tracks['track'][0]

    if not track or not 'idAlbum' in track or not track['idAlbum']:
      return None

    album = self.cache_get(track['idAlbum'], 'albums')
    if not album:
      albums = self.__url_get(self.URL_ALBUM_BY_ID.format(track['idAlbum']))
      if albums and len(albums['album']) > 0:
        album = albums['album'][0]

    if not album:
      return None

    return {'track': track, 'artist': None, 'album': album}



  def get_top_albums(self):
    top_tracks = [
      32730247,32724526,32845178,33787428,32864113,
      32730333,32726672,33011178,33766515,32865776,
      32735453,32731044,32905286,33598793,32866274,
      32780491,32752554,32862536,33659471,32845177,
      32749183,32770711,32862559,33647242,32845191,
      32802723,32732913,34846265,33650189,32814312,
      32726671,32796571,34695463,33908399,32823000,
      32941647,32796618,33973985,32862562,32826633,
      32964543,32801261,33855423,32882300,32826770,
      32723592,32787485,33803678,32848525,32826774,
    ]

    self.ensure_cache()

    album_ids = {}
    for track_id in self.cache['tracks']:
      track = self.cache['tracks'][track_id]
      if track['idAlbum'] in album_ids or int(track_id) in top_tracks:
        continue

      top_tracks.append(track_id)
      album_ids[track['idAlbum']] = True

    random.shuffle(top_tracks)
    del top_tracks[10:]
    
    album_ids = {}
    top_albums = []
    for track_id in top_tracks:
      album = self.get_top_album_by_track_id(track_id)
      if not album or album['album']['idAlbum'] in album_ids:
        continue

      album_ids[album['album']['idAlbum']] = True

      if 'strAlbumThumb' in album['album']:
        album['top_image'] = album['album']['strAlbumThumb']
      top_albums.append(album)

    pyotherside.send("top_albums", top_albums)

  def get_albums(self, artist_id):
    albums = []
    refresh_cache = False

    album_ids = self.cache_get(artist_id, 'album_ids_by_artist_id')
    if album_ids:
      for album_id in album_ids:
        album = self.cache_get(album_id, 'albums')
        if album:
          albums.append(album)
          if 'chache_expired' in album:
            refresh_cache = True

    if len(albums) > 0 and not refresh_cache:
      pyotherside.send("albums_details", {'album': albums})
      return True

    result = self.__url_get(self.URL_ALBUMS_BY_ARTIST_ID.format(artist_id))
    if not result:
      if len(albums) > 0:
        pyotherside.send("albums_details", {'album': albums})
        return True
      return False

    pyotherside.send("albums_details", result)
    album_ids = self.cache_put_multi('idAlbum', 'albums', result, 'album')
    self.cache['album_ids_by_artist_id'][str(artist_id)] = album_ids

  def get_tracks(self, album_id):
    tracks = []
    refresh_cache = False
    track_ids = self.cache_get(album_id, 'track_ids_by_album_id')
    if track_ids:
      for track_id in track_ids:
        track = self.cache_get(track_id, 'tracks')
        if track:
          tracks.append(track)
          if 'chache_expired' in track:
            refresh_cache = True

    if len(tracks) > 0 and not refresh_cache:
      pyotherside.send("tracks_details", {'track': tracks})
      return True

    result = self.__url_get(self.URL_TRACKS_BY_ALBUM_ID.format(album_id))
    if not result:
      if len(tracks) > 0:
        pyotherside.send("tracks_details", {'track': tracks})
        return True
      return False

    pyotherside.send("tracks_details", result)
    track_ids = self.cache_put_multi('idTrack', 'tracks', result, 'track')
    self.cache['track_ids_by_album_id'][str(album_id)] = track_ids

  def get_track(self, track_id):
    track = self.cache_get(track_id, 'tracks')
    if not track:
      return None
      
    track['album'] = None
    if track['idAlbum']:
      track['album'] = self.cache_get(track['idAlbum'], 'albums')
      
    return track

  def rebuild_cache_by_track_ids(self, track_ids):
    album_ids = []
    artist_ids = []
    percent = 0

    items = len(track_ids) * 3
    items_finished = 0

    for track_id in track_ids:
      items_finished += 1
      if int((float(items_finished) / float(items)) * float(100)) > percent:
        percent = int((float(items_finished) / float(items)) * float(100))
        pyotherside.send("cache_rebuild", {'status': 'progress', 'percent': percent})

      track = self.cache_get(track_id, 'tracks')
      if track:
        if 'idAlbum' in track and track['idAlbum']:
          album_ids.append(track['idAlbum'])
        if 'idArtist' in track and track['idArtist']:
          artist_ids.append(track['idArtist'])
        continue

      tracks = self.__url_get(self.URL_TRACK_BY_ID.format(track_id))
      track_ids = self.cache_put_multi('idTrack', 'tracks', tracks, 'track')

      if tracks and len(tracks['track']) > 0:
        track = tracks['track'][0]

      if not track or not 'idAlbum' in track or not track['idAlbum']:
        continue

      album_ids.append(track['idAlbum'])
      if 'idArtist' in track and track['idArtist']:
        artist_ids.append(track['idArtist'])

    items = len(track_ids) + len(set(album_ids)) + len(set(artist_ids))
    items_finished = len(track_ids)

    for album_id in set(album_ids):
      album = self.cache_get(album_id, 'albums')
      if not album:
        albums = self.__url_get(self.URL_ALBUM_BY_ID.format(album_id))
        if albums and len(albums['album']) > 0:
          album = albums['album'][0]
          if album:
            self.cache_put(album_id, 'albums', album)

      items_finished += 1
      if int((float(items_finished) / float(items)) * float(100)) > percent:
        percent = int((float(items_finished) / float(items)) * float(100))
        pyotherside.send("cache_rebuild", {'status': 'progress', 'percent': percent})

    for artist_id in set(artist_ids):
      artist = self.cache_get(artist_id, 'artists')
      if not artist:
        artists = self.__url_get(self.URL_ARTIST_BY_ID.format(artist_id))
        if artists and len(artists['artists']) > 0:
          artist = artists['artists'][0]
          if artist:
            self.cache_put(artist_id, 'artists', artist)

      items_finished += 1
      if int((float(items_finished) / float(items)) * float(100)) > percent:
        percent = int((float(items_finished) / float(items)) * float(100))
        pyotherside.send("cache_rebuild", {'status': 'progress', 'percent': percent})

    pyotherside.send("cache_rebuild", {'status': 'complete'})

  def get_top_albums_by_track_ids(self, track_ids):
    self.ensure_cache()

    random.shuffle(track_ids)
    album_ids = {}
    albums = []
    for track_id in track_ids:
      track = self.cache_get(track_id, 'tracks')
      if not track:
        continue

      if track['idAlbum'] in album_ids:
        continue

      album_ids[track['idAlbum']] = True

      album = self.cache_get(track['idAlbum'], 'albums')
      if not album:
        continue

      artist = self.cache_get(track['idArtist'], 'artists')
      albums.append({'track': track, 'artist': artist, 'album': album, 'top_image': album['strAlbumThumb']})

    pyotherside.send("top_albums", albums)

  def extract_video_id(self, video_url):
    result = re.search("((?<=(v|V)/)|(?<=be/)|(?<=(\?|\&)v=)|(?<=embed/))([\w-]+)", video_url)
    if not result:
      return None
    
    return result.group(4)

  def get_videos(self, artist_id):
    videos_by_artist_id = {}
    videos_by_album_id = {}
    videos_by_track_id = {}

    video_ids = self.cache_get(artist_id, 'video_ids_by_artist_id')
    if video_ids and len(video_ids) > 0:
      for video_id in video_ids:
        video = self.cache_get(video_id, 'videos')
        if not video:
          continue

        if not video['idArtist'] in videos_by_artist_id:
          videos_by_artist_id[video['idArtist']] = []

        if not video['idAlbum'] in videos_by_album_id:
          videos_by_album_id[video['idAlbum']] = []

        if not video['idTrack'] in videos_by_track_id:
          videos_by_track_id[video['idTrack']] = []

        videos_by_artist_id[video['idArtist']].append(video)
        videos_by_album_id[video['idAlbum']].append(video)
        videos_by_track_id[video['idTrack']].append(video)

      pyotherside.send("videos_details", {'artist_id': artist_id, 'by_artist': videos_by_artist_id, 'by_album': videos_by_album_id, 'by_track': videos_by_track_id})
      return True

    result = self.__url_get(self.URL_VIDEOS_BY_ARTIST_ID.format(artist_id))
    if not result or not 'mvids' in result or not result['mvids'] or len(result['mvids']) < 1:
      pyotherside.send("videos_details", {'artist_id': artist_id, 'by_artist': videos_by_artist_id, 'by_album': videos_by_album_id, 'by_track': videos_by_track_id})
      return None

    video_ids = []

    for video in result['mvids']:
      video_id = self.extract_video_id(video['strMusicVid'])
      if not video_id:
        continue

      video['video_id'] = video_id

      if not video['idArtist'] in videos_by_artist_id:
        videos_by_artist_id[video['idArtist']] = []

      if not video['idAlbum'] in videos_by_album_id:
        videos_by_album_id[video['idAlbum']] = []

      if not video['idTrack'] in videos_by_track_id:
        videos_by_track_id[video['idTrack']] = []

      videos_by_artist_id[video['idArtist']].append(video)
      videos_by_album_id[video['idAlbum']].append(video)
      videos_by_track_id[video['idTrack']].append(video)
      
      self.cache_put(video_id, 'videos', video)      
      video_ids.append(video_id)

    self.cache_put(artist_id, 'video_ids_by_artist_id', video_ids)
    pyotherside.send("videos_details", {'artist_id': artist_id, 'by_artist': videos_by_artist_id, 'by_album': videos_by_album_id, 'by_track': videos_by_track_id})
    return True

  def get_cache_stats(self):
    self.ensure_cache()

    file_size = None
    self.save_cache()

    try:
      file_size = os.path.getsize(self.cache_directory + self.CACHE_FILE)
    except Exception as err:
      print('Audiodb get_cache_stats - error: ', err)
      pyotherside.send("error", "audiodb", "get_cache_stats", self.format_error(err))

    image_files_c = 0
    image_files_size = 0
    for file in glob.glob(self.artwork_cache_directory + '*.*'):
      try:
        image_files_size += os.path.getsize(file)
        image_files_c += 1
      except Exception as err:
        print('Audiodb get_cache_stats - error: ', err)

    return {'artists': len(self.cache['artists']), 'albums': len(self.cache['albums']), 'tracks': len(self.cache['tracks']), 'file_size': file_size, 'images': image_files_c, 'images_size': image_files_size}

  def delete_cache_files(self):
    error = None
    
    for file in glob.glob(self.artwork_cache_directory + '*.*'):
      try:
        os.remove(file)
      except Exception as err:
        print('delete_local_media - error:', err)
        error = err

    if error:
      pyotherside.send("error", "audiodb", "delete_cache_files", self.format_error(error))

  def clear_cache(self):
    self.cache = {'created_at': int(time.time())}
    try:
      os.remove(self.cache_directory + self.CACHE_FILE)
    except Exception as err:
      print('delete_local_media - error:', err)
      pyotherside.send("error", "audiodb", "clear_cache", self.format_error(error))

    self.delete_cache_files()

audiodb_object = Audiodb()


