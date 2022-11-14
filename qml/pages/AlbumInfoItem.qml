import QtQuick 2.2
import Sailfish.Silica 1.0   

Item {
  property var model_data

  width: parent.width
  height: Theme.itemSizeLarge

  CachedImage {
    id: album_thumb
    height: parent.height
    width: height
    fillMode: Image.PreserveAspectCrop
    remote_source: model_data.strAlbumThumb
    preview: true
  }

  Column {
    id: main_column
    anchors {
      top: parent.top
      left: album_thumb.right
      right: parent.right
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
    }

    Label {
      width: parent.width
      text: model_data.strAlbum
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeMedium
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
    }

    Label { 
      text: model_data.intYearReleased 
      font.pixelSize: Theme.fontSizeSmall
    }
    
    Label { 
      text: model_data.strReleaseFormat
      font.pixelSize: Theme.fontSizeExtraSmall
    }
  }

  Icon {
    visible: false
    source: "image://theme/icon-m-speaker"
    height: 100
    width: height

    anchors {
      bottom: parent.bottom
      right: parent.right
    }
  }
}
