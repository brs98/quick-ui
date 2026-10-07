import QtQuick
import QtTest
import "../app" as App
import "../registry/quickui" as UI

Item {
    id: fixture
    width: 1100; height: 1500
    UI.Theme { id: tokens; motionDuration: 0 }
    Component { id: factory; App.PresetGallery { theme: tokens; width: 760 } }
    Component { id: hostFactory; Item { width: 760; height: preview.implicitHeight; property alias gallery: preview; App.PresetGallery { id: preview; width: parent.width; theme: tokens } } }
    TestCase {
        name: "PresetGallery"
        when: windowShown
        function init() { failOnWarning(/.*/); tokens.dark = true; tokens.fontScale = 1; tokens.density = "default"; tokens.radius = 8; }
        function make() { const gallery = createTemporaryObject(factory, fixture); verify(gallery); verify(waitForRendering(gallery)); return gallery; }
        function control(gallery, name) { const item = findChild(gallery, "gallery" + name); verify(item !== null, name); return item; }
        function test_sharedThemeAndLiveUpdates() {
            const gallery = make();
            const names = ["FormCard","NameField","NameInput","TypeField","TypeSelect","Notifications","Sync","Save","Unavailable","WorkspaceCard","ActiveBadge","CountBadge","StudioRow","ArchiveRow","MenuTrigger","DialogTrigger","AudioCard","Volume","Menu","Duplicate","Dialog"];
            names.forEach(name => compare(control(gallery,name).theme,tokens));
            tokens.dark = false; tokens.fontScale = 1.5; tokens.density = "comfortable"; tokens.radius = 0;
            wait(30);
            compare(control(gallery,"NameInput").font.pixelSize,tokens.fontSize);
            compare(control(gallery,"NameInput").Accessible.name,"Workspace name");
            compare(control(gallery,"TypeSelect").Accessible.name,"Workspace type");
            compare(control(gallery,"NameInput").width,control(gallery,"NameField").width);
            compare(control(gallery,"StudioRow").background.radius,0);
            compare(control(gallery,"AudioCard").background.color,tokens.card);
            compare(control(gallery,"Volume").slider.theme,tokens);
            compare(control(gallery,"Dialog").confirmButton.theme,tokens);
        }
        function test_nativeLocalInteractionsAndReset() {
            const gallery = make();
            const name = control(gallery,"NameInput");
            name.text = "My preview"; mouseClick(control(gallery,"Save"));
            compare(gallery.savedName,"My preview");
            name.text = " "; verify(!control(gallery,"Save").enabled);
            mouseClick(control(gallery,"Unavailable")); compare(gallery.savedName,"My preview");
            mouseClick(control(gallery,"Notifications")); verify(!gallery.notifications);
            control(gallery,"Sync").forceActiveFocus(); keyClick(Qt.Key_Space); verify(gallery.syncEnabled);
            const select=control(gallery,"TypeSelect"); select.forceActiveFocus(); keyClick(Qt.Key_Down); compare(select.currentIndex,1);
            mouseClick(control(gallery,"ArchiveRow")); compare(gallery.selectedWorkspace,1);
            const volume=control(gallery,"Volume"); volume.slider.forceActiveFocus(); keyClick(Qt.Key_Right); verify(gallery.outputVolume>0.65);
            mouseClick(volume.muteButton); verify(gallery.outputMuted);
            gallery.resetPreview();
            compare(gallery.savedName,"Studio workspace"); compare(name.text,gallery.savedName);
            verify(gallery.notifications); verify(!gallery.syncEnabled); compare(select.currentIndex,0);
            compare(gallery.selectedWorkspace,0); compare(gallery.outputVolume,0.65); verify(!gallery.outputMuted);
        }
        function test_responsiveGeometry_data() { return [{tag:"narrow",width:320,scale:1},{tag:"largeText",width:360,scale:2},{tag:"desktop",width:900,scale:1.5}]; }
        function test_responsiveGeometry(data) {
            const gallery=make(); gallery.width=data.width; tokens.fontScale=data.scale; tokens.density="comfortable";
            wait(50);
            compare(gallery.twoColumns,data.width>=680);
            const first=control(gallery,"FormCard"), next=control(gallery,"WorkspaceCard");
            const mapped=next.mapToItem(gallery,0,0);
            if(gallery.twoColumns) verify(mapped.x>first.x+first.width); else verify(mapped.y>=first.height);
            for (const name of ["FormCard","WorkspaceCard","AudioCard","NameInput","TypeSelect","Volume","StudioRow","ArchiveRow"]) {
                const item=control(gallery,name), pos=item.mapToItem(gallery,0,0);
                verify(item.width>0,name); verify(pos.x>=-0.5,name); verify(pos.x+item.width<=gallery.width+0.5,name);
                verify(pos.y+item.height<=gallery.implicitHeight+0.5,name);
            }
        }
        function test_ancestorHiddenClosesPopup() {
            const host=createTemporaryObject(hostFactory,fixture); verify(host); verify(waitForRendering(host));
            const gallery=host.gallery, dialog=control(gallery,"Dialog"), menu=control(gallery,"Menu");
            mouseClick(control(gallery,"DialogTrigger")); tryCompare(dialog,"opened",true);
            host.visible=false; tryCompare(dialog,"visible",false);
            host.visible=true; mouseClick(control(gallery,"MenuTrigger")); tryCompare(menu,"opened",true);
            host.visible=false; tryCompare(menu,"visible",false);
        }
        function test_popupActionsAndHiddenCleanup() {
            const gallery=make(); const menu=control(gallery,"Menu"), dialog=control(gallery,"Dialog");
            mouseClick(control(gallery,"MenuTrigger")); tryCompare(menu,"opened",true);
            mouseClick(control(gallery,"Duplicate")); verify(gallery.feedback.indexOf("Duplicate")>=0); tryCompare(menu,"visible",false);
            mouseClick(control(gallery,"DialogTrigger")); tryCompare(dialog,"opened",true); verify(dialog.cancelButton.activeFocus);
            keyClick(Qt.Key_Return); tryCompare(dialog,"visible",false); compare(gallery.feedback,"Workspace kept.");
            mouseClick(control(gallery,"DialogTrigger")); tryCompare(dialog,"opened",true); mouseClick(dialog.confirmButton); compare(gallery.feedback,"Removal requested in this preview.");
            mouseClick(control(gallery,"MenuTrigger")); tryCompare(menu,"opened",true); gallery.visible=false; tryCompare(menu,"visible",false);
            gallery.visible=true; mouseClick(control(gallery,"DialogTrigger")); tryCompare(dialog,"opened",true); gallery.visible=false; tryCompare(dialog,"visible",false);
            gallery.visible=true; const select=control(gallery,"TypeSelect"); select.popup.open(); tryCompare(select.popup,"visible",true); gallery.visible=false; tryCompare(select.popup,"visible",false);
        }
    }
}
