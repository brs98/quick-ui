import QtQuick
import "../../registry/quickui" as UI

Item {
    width: 600; height: 640
    UI.RangeSlider {
        y: 20; width: 280
        from: 0; to: 100; first.value: 20; second.value: 80
        firstAccessibleName: "Lower limit"
        secondAccessibleName: "Upper limit"
    }
    UI.LevelMeter { y: 80; value: 2; Accessible.name: "Clamped level" }
    UI.LevelMeter { y: 110; value: NaN; Accessible.name: "Invalid level" }
    UI.DeviceItem { y: 140; text: "Speakers"; current: true }
    UI.AudioMixer {
        id: mixer
        y: 220; width: 380; height: 400
        panelNavigation: true
        hasOutput: true; outputVolume: 0.64
        Component.onCompleted: { reset(); setCursor("output", -1); }
    }
}
