# -*- coding: utf-8 -*-
import json
import time
import os
import urllib.request
import urllib
import re
import sys
import traceback
import pyotherside

class Lyricsmania:
  URL_LYRICS="https://www.lyricsmania.com/{}_lyrics_{}.html"
  URL_LYRICS_ALT="https://api.lyrics.ovh/v1/{}/{}"
  CACHE_FILE = "lyricsmania_cache.json"
  CACHE_EXPIRY = 604800 #seconds

  def __init__(self):
    print('Lyricsmania init')
    self.cache_directory = os.environ['HOME'] + "/.local/share/app.qml/musicex/"
    self.cache = {}

  def load_cache(self, force_load = False):
    if len(self.cache) > 0 and not force_load:
      return True

    try:
      with open(self.cache_directory + self.CACHE_FILE) as cache_file:
        self.cache = json.load(cache_file)
    except Exception as err:
      print('Lyricsmania load_cache - error: ', err)
      pyotherside.send("error", "lyricsmania", "load_cache", err)

    if not self.cache:
      self.cache = {'created_at': int(time.time())}

    if not 'tracks' in self.cache:
      self.cache['tracks'] = {}

    print('Lyricsmania load_cache - lyric tracks: ', len(self.cache['tracks']))

    return True

  def save_cache(self):
    print('Lyricsmania save_cache - data: ', len(self.cache))
    if len(self.cache) < 2:
      return False

    try:
      os.makedirs(self.cache_directory)
    except FileExistsError:
      pass
    except Exception as err:
      print('Lyricsmania save_cache - error: ', err)
      pyotherside.send("error", "lyricsmania", "save_cache", err)
      return False

    self.cache['updated_at'] = int(time.time())
    try:
      with open(self.cache_directory + self.CACHE_FILE, 'w') as cache_file:
        json.dump(self.cache, cache_file, indent=2)
    except Exception as err:
      print('Lyricsmania save_cache - error: ', err)
      pyotherside.send("error", "lyricsmania", "save_cache", err)
      return False

  def cache_get(self, cache_key, cache_category):
    if len(self.cache) < 1:
      self.load_cache()
      
    cache_key_s = str(cache_key)

    if cache_key_s not in self.cache[cache_category]:
      print('Lyricsmania cache_get - no item - category:', cache_category, 'key:', cache_key_s)
      return None

    data = self.cache[cache_category][cache_key_s]
    if type(data) is dict and 'cache_created_at'in data and data['cache_created_at'] < int(time.time()) - self.CACHE_EXPIRY:
      print('Lyricsmania cache_get - expired item - category:', cache_category, 'key:', cache_key_s, 'created:', data['cache_created_at'], 'expired:', int(time.time()) - self.CACHE_EXPIRY)
      return None
      
    print('Lyricsmania cache_get - item found - category:', cache_category, 'key:', cache_key_s)
    return data

  def cache_put(self, cache_key, cache_category, data):
    if len(self.cache) < 1:
      self.load_cache()
      
    cache_key_s = str(cache_key)
    data['cache_created_at'] = int(time.time())
    self.cache[cache_category][cache_key_s] = data

  def __url_get(self, url):
    req = urllib.request.Request(
      url,
      headers={
        'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:100.0) Gecko/20100101 Firefox/100.0',
        'Content-Type': 'text/json; charset=UTF-8',
      }
    )
    
    print(url)

    try:
      return urllib.request.urlopen(req).read()
    except Exception as err:
      print("### ERROR api request failed: %s" % err)
      return False

    return False

  def get_lyrics_element(self, data):
    try:
      from_index = data.find(b'<div class="lyrics-body">')
      to_index = data.find(b'<div class="credits">')
      if from_index < 1:
        from_index = 0
      if to_index < 0:
        to_index = data.find(b'<div class="clear spacer-10">')
      if to_index < 0:
        return None

      data = data[from_index+25:to_index-7].replace(b'\r', b'\n')

      print('get_lyrics_element - initial element: ', from_index+25, ' - ', to_index-7, ', length: ', len(data))
    
      from_index = data.find(b'div>')
      if from_index > 0:
        data = data[from_index+4:]
        print('get_lyrics_element - adapted element: ', from_index+4, ', length: ', len(data))

      return re.sub('<[^div>]*>', '', data.decode("utf-8"))

    except Exception as err:
      print("ERROR lyrics element conversion: ", err)
      traceback.print_exc(file=sys.stdout)
      return None

  def download_lyrics(self, track_c, artist_c):
    result = self.__url_get(self.URL_LYRICS.format(track_c, artist_c))
    if not result:
      return None

    try:
      return self.get_lyrics_element(result)
    except Exception as err:
      print("ERROR lyrics conversion: ", err)
      return None

  def download_lyrics_alternate(self, track, artist):
    result = self.__url_get(self.URL_LYRICS_ALT.format(urllib.parse.quote_plus(artist), urllib.parse.quote_plus(track)))
    if not result:
      return None

    try:
      lyrics_a = json.loads(result)
    except Exception as err:
      print("ERROR lyrics conversion: ", err)
      return None


    if 'lyrics' not in lyrics_a:
      return None

    return lyrics_a['lyrics']

  def not_lyrics(self, lyrics):
    if not lyrics:
      return True

    if len(lyrics) < 20:
      return True

    if lyrics.find('<div') > -1 or lyrics.find('<\div') > -1 or lyrics.find('<a href') > -1 :
      print('not_lyrics - html elements found:', lyrics.find('<div'), lyrics.find('<\div'), lyrics.find('<a href'))
      return True

    return False

  def get_lyrics(self, artist, track, track_id):
    lyrics_record = self.cache_get(track_id, 'tracks')

    if lyrics_record:
      pyotherside.send("lyrics_details", lyrics_record)
      return

    artist_s = re.sub('\([^\)]*\)', '', artist).strip()
    track_s = re.sub('\([^\)]*\)', '', track).strip()
    artist_c = re.sub('[^a-z0-9_]+', '', artist_s.lower().replace(' ', '_').replace('ä', 'a').replace('ö', 'o').replace('ü', 'u').replace('ß', 's')) 
    track_c = re.sub('[^a-z0-9_]+', '', track_s.lower().replace(' ', '_').replace('ä', 'a').replace('ö', 'o').replace('ü', 'u').replace('ß', 's'))
    
    lyrics = self.download_lyrics(track_c, artist_c)
    if self.not_lyrics(lyrics) and artist_c.startswith('the_'):
      lyrics = self.download_lyrics(track_c, artist_c[4:])

    if self.not_lyrics(lyrics):
      lyrics = self.download_lyrics_alternate(track, artist)

    if self.not_lyrics(lyrics):
      pyotherside.send("lyrics_details", {'track_id': track_id, 'lyrics': None})
      return False

    lyrics_record = {'track_id': track_id, 'lyrics': lyrics}
    pyotherside.send("lyrics_details", lyrics_record)
    self.cache_put(track_id, 'tracks', lyrics_record)


lyricsmania_object = Lyricsmania()
