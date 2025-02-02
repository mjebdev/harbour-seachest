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
TARGET = harbour-seachest

CONFIG += sailfishapp

SOURCES += src/harbour-seachest.cpp

DISTFILES += qml/harbour-seachest.qml \
    qml/cover/CoverPage.qml \
    qml/pages/About.qml \
    qml/pages/Authorize.qml \
    qml/pages/Home.qml \
    qml/pages/Settings.qml \
    rpm/harbour-seachest.changes.in \
    rpm/harbour-seachest.changes.run.in \
    rpm/harbour-seachest.spec \
    rpm/harbour-seachest.yaml \
    translations/*.ts \
    harbour-seachest.desktop \
    translations/harbour-seachest-it.ts \
    translations/harbour-seachest-sv.ts

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
# TRANSLATIONS += translations/harbour-seachest-de.ts

HEADERS += \
    src/networkaccess.h
