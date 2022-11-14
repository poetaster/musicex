# -*- coding: utf-8 -*-
import os
import time
import json
import pyotherside

class Settings:
  SETTINGS_FILE = "settings.json"
  TRACK_VOLUME_FILE = "track_volume.json"

  def __init__(self):
    self.data_directory = os.environ['HOME'] + "/.local/share/app.qml/musicex/"
    print('Settings init - data directory: ', self.data_directory)

    try:
      os.makedirs(self.data_directory)
    except FileExistsError:
      pass
    except Exception as err:
      print('Settings init - error: ', err)
      pyotherside.send("error", "settings", "init", self.format_error(err))
      return False

  def format_error(self, err):
    return 'ERROR: %s' % err

  def load_settings(self):
    settings = {}
    try:
      with open(self.data_directory + self.SETTINGS_FILE) as settings_file:
        settings = json.load(settings_file)
    except Exception as err:
      print('Settings load_settings - error: ', err)
      pyotherside.send("error", "settings", "load_settings", self.format_error(err))
      settings = {'created_at': int(time.time())}

    return settings

  def save_settings(self, settings):
    try:
      with open(self.data_directory + self.SETTINGS_FILE, 'w') as settings_file:
        json.dump(settings, settings_file, indent=2)
    except Exception as err:
      print('Settings save_settings - error: ', err)
      pyotherside.send("error", "settings", "save_settings", self.format_error(err))
      return False

  def load_track_volumes(self):
    track_volumes = {}
    try:
      with open(self.data_directory + self.TRACK_VOLUME_FILE) as track_volumes_file:
        track_volumes = json.load(track_volumes_file)
    except Exception as err:
      print('Settings load_track_volumes - error: ', err)
      pyotherside.send("error", "settings", "load_track_volumes", self.format_error(err))

    return track_volumes

  def save_track_volumes(self, track_volumes):
    try:
      with open(self.data_directory + self.TRACK_VOLUME_FILE, 'w') as track_volumes_file:
        json.dump(track_volumes, track_volumes_file, indent=2)
    except Exception as err:
      print('Settings save_track_volumes - error: ', err)
      pyotherside.send("error", "settings", "save_track_volumes", self.format_error(err))
      return False

settings_object = Settings()
