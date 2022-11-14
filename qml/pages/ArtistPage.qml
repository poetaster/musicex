import QtQuick 2.2
import Sailfish.Silica 1.0                                                                                          
import Sailfish.Silica.private 1.0  

Page {
  id: artist_page

  property var artist_data

  SilicaFlickable {
    id: flickable
    
    anchors.fill: parent
    
    contentHeight: artist_item.height

    VerticalScrollDecorator { 
      flickable: flickable 
    }

    ArtistInfoFullItem {
      id: artist_item
      artist_data: artist_page.artist_data
    }
  }

  Component.onCompleted: {
    python.get_albums(artist_data.idArtist)
  }

  Component.onDestruction: {

  }
}
