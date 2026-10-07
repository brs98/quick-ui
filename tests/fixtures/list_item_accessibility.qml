import QtQuick
import "../../registry/quickui" as UI

Item {
    width: 360; height: 240
    Column {
        UI.ListItem {width:320;text:"Selected contact";description:"Two unread messages";selected:true}
        UI.ListItem {width:320;text:"Cursor article";highlighted:true;focusPolicy:Qt.NoFocus}
        UI.ListItem {width:320;text:"Unavailable contact";enabled:false}
    }
}
