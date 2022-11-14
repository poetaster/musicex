# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-musicex

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-musicex.qml \
    qml/*.qml \
    qml/pages/*.qml \
    src/*.py \
    src/pytube/*.py \
    src/pytube/contrib/*.py \
    rpm/*.spec \
    translations/*.ts \
    harbour-musicex.desktop


# Python Data
src.files = src/*
src.path = /usr/share/$${TARGET}/src

# image files
#img.files = img/*
#img.path = /usr/share/$${TARGET}/img

#db.files = route.db
#db.path = /usr/share/$${TARGET}/

INSTALLS += src img 

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
#TRANSLATIONS += translations/harbour-musicex-de.ts
