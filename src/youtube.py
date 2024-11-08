# -*- coding: utf-8 -*-
import os
import re
import glob
import time
import json
import pytubefix
import pyotherside

class Youtube:
  VIDEO_URL="https://www.youtube.com/watch?v={}"
  MEDIA_SEARCH_FORMAT="{} - {}"
  AUDIO_FILE_NAME = "track_{}_{}.opus"
  CACHE_FILE = "youtube_cache.json"
  CACHE_EXPIRY = 604800 #seconds

  def __init__(self):
    self.audio_download_path = os.environ['HOME'] + "/Music/music_explorer/"
    self.cache_directory = os.environ['HOME'] + "/.local/share/app.qml/musicex/"
    self.cache = {}

    try:
      os.mkdir(self.audio_download_path)
    except FileExistsError:
      pass
    except Exception as err:
      pyotherside.send("error", "youtube", "init", self.format_error(err))
      return

    try:
      open(self.audio_download_path + '.trackerignore', 'a').close()
    except OSError:
      pass

    print('Youtube init - download path: ', self.audio_download_path)

  def format_error(self, err):
    return 'ERROR: %s' % err

  def ensure_cache(self):
    if not self.cache or len(self.cache) < 2:
      self.load_cache()

  def load_cache(self, force_load = False):
    if len(self.cache) > 2 and not force_load:
      return True

    try:
      with open(self.cache_directory + self.CACHE_FILE) as cache_file:
        self.cache = json.load(cache_file)
    except Exception as err:
      print('Youtube load_cache - error: ', err)
      #pyotherside.send("error", "youtube", "load_cache", self.format_error(err))

    if not self.cache:
      self.cache = {'created_at': int(time.time())}

    if not 'videos' in self.cache:
      self.cache['videos'] = {}

    if not 'video_ids_by_track_id' in self.cache:
      self.cache['video_ids_by_track_id'] = {}

    return True

  def save_cache(self):
    if len(self.cache) < 2:
      return False

    try:
      os.makedirs(self.cache_directory)
    except FileExistsError:
      pass
    except Exception as err:
      print('Youtube save_cache - error: ', err)
      pyotherside.send("error", "youtube", "save_cache", self.format_error(err))
      return False

    self.cache['updated_at'] = int(time.time())
    try:
      with open(self.cache_directory + self.CACHE_FILE, 'w') as cache_file:
        json.dump(self.cache, cache_file, indent=2)
    except Exception as err:
      print('Youtube save_cache - error: ', err)
      pyotherside.send("error", "youtube", "save_cache", self.format_error(err))
      return False

    print('Youtube save_cache - file: ', self.cache_directory + self.CACHE_FILE)

  def cache_get(self, cache_key, cache_category):
    self.ensure_cache()
      
    cache_key_s = str(cache_key)

    if cache_key_s not in self.cache[cache_category]:
      print('Youtube cache_get - no item - category:', cache_category, 'key:', cache_key_s)
      return None

    data = self.cache[cache_category][cache_key_s]
    if type(data) is dict and 'cache_created_at'in data and data['cache_created_at'] < int(time.time()) - self.CACHE_EXPIRY:
      print('Youtube cache_get - expired item - category:', cache_category, 'key:', cache_key_s, 'created:', data['cache_created_at'], 'expired:', int(time.time()) - self.CACHE_EXPIRY)
      data['chache_expired'] = True
      return data
      
    print('Youtube cache_get - item found - category:', cache_category, 'key:', cache_key_s)
    return data


  def cache_put(self, cache_key, cache_category, data):
    self.ensure_cache()
      
    cache_key_s = str(cache_key)
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

  def get_local_media(self, track_id = '*', video_id = '*'):
    media_files = []
    for file in glob.glob(self.audio_download_path + self.AUDIO_FILE_NAME.format(track_id, video_id)):
      media_files.append(file)
  
    return media_files

  def get_local_media_first(self, track_id = '*', video_id = '*'):
    for file in glob.glob(self.audio_download_path + self.AUDIO_FILE_NAME.format(track_id, video_id)):
      return file

    return None

  def has_local_media(self, track_id = '*', video_id = '*'):
    media_files = glob.glob(self.audio_download_path + self.AUDIO_FILE_NAME.format(track_id, video_id))
    return len(media_files) > 0

  def delete_local_media(self, track_id, video_id = '*'):
    success = False

    for media_file in glob.glob(self.audio_download_path + self.AUDIO_FILE_NAME.format(track_id, video_id)):
      try:
        os.remove(media_file)
        success = True
      except Exception as err:
        print('delete_local_media - error:', err)
        pyotherside.send("error", "youtube", "delete_local_media", self.format_error(err))

    return success

  def get_media_folder_items(self, folder_path, file_types = ('*.mp3', '*.opus')):
    media_files = []
    for file_type in file_types:
      for file in glob.glob("%s/%s" % (folder_path, file_type)):
        media_files.append(file)

    media_files.sort()
    return media_files

  def check_title(self, title, artist, track):
    for word in re.sub('\([^\)]*\)', '', track).strip().split():
      if not word in title:
        return False
    
    for word in re.sub('\([^\)]*\)', '', artist).strip().split():
      if not word in title:
        return False

    return True

  def search_media(self, artist, track, track_id):
    videos_cached = []
    videos = []
    refresh_cache = False

    video_ids = self.cache_get(track_id, 'video_ids_by_track_id')
    if video_ids:
      for video_id in video_ids:
        video = self.cache_get(video_id, 'videos')
        if video:
          videos_cached.append(video)
          if 'chache_expired' in video:
            refresh_cache = True

    if len(videos_cached) > 0 and not refresh_cache:
      data = {'track_id': track_id, 'videos': videos_cached, 'partial': False}
      pyotherside.send("videos_list", data)
      return True

    data = {'track_id': track_id, 'videos': videos, 'partial': True}
    so = pytubefix.Search(self.MEDIA_SEARCH_FORMAT.format(artist, track))
    try:
      for yo in so.results:
        if not self.check_title(yo.title.lower(), artist.lower(), track.lower()):
          continue

        try:
          print('VIDEO primary:', yo.title, ' / ', yo.length, ' / ', yo.thumbnail_url, ' / ', yo.vid_info['videoDetails']['videoId'], ' / ', yo.views)
          videos.append({'video_id': yo.vid_info['videoDetails']['videoId'], 'title': yo.title, 'length': yo.length, 'views': yo.views, 'thumbnail_url': yo.thumbnail_url})
        except Exception as err:
          print('VIDEO primary error - ignoring video: ', err)
          continue

        pyotherside.send("videos_list", data)
    except Exception as err:
      print('Youtube search_media - error: ', err)
      pyotherside.send("error", "youtube", "search_media", self.format_error(err))
      pyotherside.send("videos_list", {'track_id': track_id, 'videos': videos_cached, 'partial': False})
      return False
      
    if len(videos) < 2:
      try:
        for yo in so.results:
          try:
            print('VIDEO secondary:', yo.title, ' / ', yo.length, ' / ', yo.thumbnail_url, ' / ', yo.vid_info['videoDetails']['videoId'], ' / ', yo.views)
            videos.append({'video_id': yo.vid_info['videoDetails']['videoId'], 'title': yo.title, 'length': yo.length, 'views': yo.views, 'thumbnail_url': yo.thumbnail_url})
          except Exception as err:
            print('VIDEO secondary error - ignoring video: ', err)
            continue

          pyotherside.send("videos_list", data)
      except Exception as err:
        print('Youtube search_media - error: ', err)
        pyotherside.send("error", "youtube", "search_media", self.format_error(err))
        pyotherside.send("videos_list", {'track_id': track_id, 'videos': videos_cached, 'partial': False})
        return False

    if len(videos) < 1:
      data = {'track_id': track_id, 'videos': videos_cached, 'partial': False}
      pyotherside.send("videos_list", data)
      return len(videos_cached) > 0

    data = {'track_id': track_id, 'videos': videos, 'partial': False}
    pyotherside.send("videos_list", data)
    video_ids = self.cache_put_multi('video_id', 'videos', data)
    self.cache['video_ids_by_track_id'][str(track_id)] = video_ids
    return len(videos) > 0
    
  def get_audio_stream(self, track_id, video_id):
    yo = pytubefix.YouTube(self.VIDEO_URL.format(video_id), on_progress_callback=self.handle_progress, on_complete_callback=self.handle_complete)
    if not yo:
      pyotherside.send("error", "youtube", "get_audio_stream", 'Media not found')
      return None

    file_name = self.AUDIO_FILE_NAME.format(track_id, video_id)
    
    try:
      pyotherside.send("media_download", {'status': 'start', 'file_path': self.audio_download_path, 'file_name': file_name, 'thumbnail_url': yo.thumbnail_url, 'stream': None})
    except Exception as err:
      pyotherside.send("error", "youtube", "media_download", self.format_error(err))
      return

    stream = None
    for st in yo.streams.filter(only_audio=True):
      codecs = st.parse_codecs()
      print('stream - audio:', st.includes_audio_track, ', size: ', st.filesize, ', codecs: ', codecs, 'default file:', st.default_filename)
      if 'opus' in codecs:
        if not stream or stream.filesize < st.filesize:
          stream = st
    
    if not stream:
      pyotherside.send("error", "youtube", "get_audio_stream", 'No suitable audio streams found')
      pyotherside.send("media_download", {'status': 'fail', 'reason': 'No suitable audio streams found', 'file_path': self.audio_download_path, 'file_name': file_name, 'stream': None})
      return None

    self.audio_download_last_file_name = file_name    
    stream.download(self.audio_download_path, file_name)

  def find_download_media(self, artist, track, track_id, length_ms):
    length = None
    if length_ms:
      length = round(int(length_ms) / 1000.0)

    print('find_download_media:', artist, track, track_id, length)

    so = pytubefix.Search(self.MEDIA_SEARCH_FORMAT.format(artist, track))
    print('find_download_media - results:', len(so.results))
    index = 0

    video = None
    video_score = 0
    
    for yo in so.results:
      if not self.check_title(yo.title.lower(), artist.lower(), track.lower()):
        continue

      score = 0

      try:
        if length:
          if (yo.length > length + 30 or yo.length < length - 10):
            continue
        elif yo.length > 2000:
          continue

        if length:
          if yo.length == length:
            score += 100
          elif yo.length == length + 1 or  yo.length == length - 1:
            score += 90

        title_lower = yo.title.lower()
        if "official lyrics video" in title_lower:
          score += 100
        elif "official audio" in title_lower:
          score += 100
        elif "official music video" in title_lower:
          score += 90
        elif "official hd video" in title_lower:
          score += 90
        elif "(audio)" in title_lower:
          score += 80
        elif "(lyrics)" in title_lower:
          score += 50

        if "remix" in title_lower and "remix" not in track.lower():
          score += -80
        
        if "live" in title_lower and "live" not in track.lower():
          score += -50

      except Exception as err:
        print('find_download_media error - ignoring video: ', err)
        continue

      if score > video_score:
        video = yo
        video_score = score

      print('find_download_media - title:', yo.title, 'duration:', yo.length, 'views:', yo.views, 'match score:', score)

      index += 1
      if (video_score > 50 and index > 10) or (video_score > 100 and index > 3) or (video_score > 150):
        break

    if not video or video_score < 50:
      print('find_download_media - no video found - highest score:', video_score)
      pyotherside.send("media_download", {'status': 'fail', 'reason': 'No suitable media found', 'track_id': track_id, 'file_path': None, 'file_name': None, 'stream': None})
      return None
    
    print('find_download_media - media found - title:', video.title, 'duration:', video.length, 'views:', video.views, 'highest score:', video_score)
    
    return self.get_audio_stream(track_id, video.vid_info['videoDetails']['videoId'])

  def handle_progress(self, stream, file_handler, bytes_remaining):
    percent = int((float(stream.filesize - bytes_remaining) / float(stream.filesize)) * float(100))
    print('Youtube download progress: ', percent, '%, remaining:', bytes_remaining, 'of', stream.filesize)
    pyotherside.send("media_download", {'status': 'progress', 'bytes_remaining': bytes_remaining, 'file_size': stream.filesize, 'percent': percent, 'file_name': self.audio_download_last_file_name, 'stream': stream})

  def handle_complete(self, stream, file_path):
    print('Youtube download complete: ', file_path)
    pyotherside.send("media_download", {'status': 'complete', 'file_path': self.audio_download_path, 'file_name': file_path, 'stream': stream})

  def save_playlist(self, file_name, playlist_items):
    print('save_playlist:', file_name, 'items:', len(playlist_items))

    try:
      with open(file_name, 'w') as f:
        f.write("[playlist]\n")
        f.write("X-GNOME-Title=Music Explorer\n")
        for index, item in enumerate(playlist_items):
          index += 1
          f.write("File%d=%s\n" % (index, item['media_url']))
          f.write("Title%d=%s\n" % (index, item['track']))
          if item['duration']:
            f.write("Length%d=%s\n" % (index, round(item['duration'] / 1000)))
        
        f.write("NumberOfEntries=%d\n" % len(playlist_items))
        f.write("Version=2\n\n")
    except Exception as err:
      print('Youtube save_playlist - error: ', err)
      pyotherside.send("error", "youtube", "save_playlist", self.format_error(err))
      return False

  def get_cache_stats(self):
    self.ensure_cache()

    file_size = None
    self.save_cache()

    try:
      file_size = os.path.getsize(self.cache_directory + self.CACHE_FILE)
    except Exception as err:
      print('Audiodb get_cache_stats - error: ', err)
      pyotherside.send("error", "youtube", "get_cache_stats", self.format_error(err))

    media_files_size = 0
    media_files = self.get_local_media()
    for media_file in media_files:
      try:
        media_files_size += os.path.getsize(media_file)
      except Exception as err:
        print('Audiodb get_cache_stats - error: ', err)

    fs = os.statvfs(self.audio_download_path)

    return {'videos': len(self.cache['videos']), 'file_size': file_size, 'media_files': len(media_files), 'media_files_size': media_files_size, 'fs_size': fs.f_frsize * fs.f_blocks, 'fs_available': fs.f_frsize * fs.f_bavail}

  def clear_cache(self):
    self.cache = {'created_at': int(time.time())}
    try:
      os.remove(self.cache_directory + self.CACHE_FILE)
    except Exception as err:
      print('delete_local_media - error:', err)
      pyotherside.send("error", "youtube", "clear_cache", self.format_error(error))

  def delete_local_media_files(self, track_id = '*', video_id = '*'):
    error = None
    
    for file in glob.glob(self.audio_download_path + self.AUDIO_FILE_NAME.format(track_id, video_id)):
      try:
        os.remove(file)
      except Exception as err:
        print('delete_local_media - error:', err)
        error = err

    if error:
      pyotherside.send("error", "youtube", "delete_local_media_files", self.format_error(error))

youtube_object = Youtube()
