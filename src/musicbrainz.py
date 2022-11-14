# -*- coding: utf-8 -*-
import json
import time
import os
import re
import glob
import urllib.request
import urllib.parse
import random
#import pyotherside

class Musicbrainz:
  URL_ARTISTS_BY_NAME="https://musicbrainz.emby.tv/ws/2/artist/?fmt=json&query={}"
  URL_ALBUM_BY_NAME="https://musicbrainz.emby.tv/ws/2/release-group/?fmt=json&query={}"
  URL_TRACK_BY_NAME="https://musicbrainz.emby.tv/ws/2/recording/?fmt=json&query={}"

  ARTIST_MIN_SCORE = 79
  ALBUM_MIN_SCORE = 79
  TRACK_MIN_SCORE = 79
  CACHE_FILE = "musicbrainz_cache.json"
  CACHE_EXPIRY = 604800 #seconds

  def __init__(self):
    print('Musicbrainz init')

  def format_error(self, err):
    return 'ERROR: %s' % err

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


  def search_artists_by_name(self, search_s):
    result = self.__url_get(self.URL_ARTISTS_BY_NAME.format(urllib.parse.quote_plus(search_s)))
    if not result:
      return None

    if not 'artists' in result:
      return None

    return result['artists']


  def search_artist_first(self, search_s):
    result = self.search_artists_by_name(search_s)
    if not result:
      return None

    for artist in result:
      if artist['score'] == 100:
        return artist

    return None

  def search_artists_score(self, search_s, min_score = None):
    if min_score == None:
      min_score = self.ARTIST_MIN_SCORE

    artists = []
    result = self.search_artists_by_name(search_s)
    if not result:
      return None

    for artist in result:
      if artist['score'] < min_score:
        continue

      artists.append({'object_type': 'artist', 'idArtist': None, 'mbid': artist['id'], 'strArtist': artist['name'], 'score':  artist['score']})

    return artists

  def search_albums_score(self, search_s, min_score = None):
    if min_score == None:
      min_score = self.ALBUM_MIN_SCORE

    albums = []
    albums_map = {}

    result = self.__url_get(self.URL_ALBUM_BY_NAME.format(urllib.parse.quote_plus(search_s)))
    if not result:
      return None

    if not 'release-groups' in result:
      return None

    for album in result['release-groups']:
      if album['score'] < min_score:
        continue

      artist_name = None
      artist_id = None

      try:
        artist_name = album['artist-credit'][0]['name']
      except Exception as err:
        print("### search_albums_score ERROR artist_name: %s" % err)

      try:
        artist_id = album['artist-credit'][0]['artist']['id']
      except Exception as err:
        print("### search_albums_score ERROR artist_id: %s" % err)

      map_key = "%s_%s" % (artist_id, album['title'])

      if map_key in albums_map:
        continue

      print('Album:', album['title'], 'id:', album['id'], 'score:', album['score'], 'artist:', artist_name, 'id:', artist_id)
      albums.append({'object_type': 'album', 'idArtist': None, 'idAlbum': None, 'mbid': album['id'], 'strArtist': artist_name, 'strAlbum': album['title'], 'score':  album['score']})
      albums_map[map_key] = True

    return albums


  def search_tracks_score(self, search_s, min_score = None):
    if min_score == None:
      min_score = self.TRACK_MIN_SCORE

    tracks = []
    tracks_map = {}

    result = self.__url_get(self.URL_TRACK_BY_NAME.format(urllib.parse.quote_plus(search_s)))
    if not result:
      return None

    if not 'recordings' in result:
      return None

    for track in result['recordings']:
      if track['score'] < min_score:
        continue

      artist_name = None
      artist_id = None

      album_name = None
      album_id = None

      try:
        artist_name = track['artist-credit'][0]['name']
      except Exception as err:
        print("### search_tracks_score ERROR artist_name: %s" % err)

      try:
        artist_id = track['artist-credit'][0]['artist']['id']
      except Exception as err:
        print("### search_tracks_score ERROR artist_id: %s" % err)

      try:
        album_name = track['releases'][0]['release-group']['title']
      except Exception as err:
        print("### search_tracks_score ERROR album_name: %s" % err)
        print(track)

      try:
        album_id = track['releases'][0]['release-group']['id']
      except Exception as err:
        print("### search_tracks_score ERROR album_id: %s" % err)

      map_key = "%s_%s" % (artist_id, track['title'])

      if map_key in tracks_map:
        continue

      print('Track:', track['title'], 'id:', track['id'], 'score:', track['score'], 'artist:', artist_name, 'id:', artist_id)
      tracks.append({'object_type': 'track', 'idArtist': None, 'idAlbum': None, 'mbid': track['id'], 'strArtist': artist_name, 'strAlbum': album_name, 'strTrack': track['title'], 'score':  track['score']})
      tracks_map[map_key] = True

    return tracks

  def search_artist_id(self, search_s):
    artist = self.search_artist_first(search_s)
    if not artist:
      return None
      
    print('Name:', artist['name'], 'score:', artist['score'], 'id:', artist['id'])
    return artist['id']

  def search_artists(self, search_s):
    artist = self.search_artist_first(search_s)
    if not artist:
      return None
      
    print('Name:', artist['name'], 'score:', artist['score'], 'id:', artist['id'])
    return artist['id']

musicbrainz_object = Musicbrainz()
