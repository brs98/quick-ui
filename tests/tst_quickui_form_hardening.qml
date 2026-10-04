import QtQuick
import QtTest
import "../registry/quickui" as UI
import "../stories/primitives" as Stories

Item {
    width: 700; height: 600
    Component { id: fieldFactory; UI.TextField { x: 20; y: 20; width: 250 } }
    Component { id: switchFactory; UI.Switch { x: 20; y: 80; text: "Notifications"; checked: true } }
    Component { id: checkFactory; UI.CheckBox { x: 20; y: 160; text: "Notifications"; checked: true } }
    Component { id: selectFactory; UI.Select { x: 20; y: 250; model: [{label:"Alpha", available:true}, {label:"Beta", available:false}, {label:"Bravo", available:true}, {label:"Delta", available:false}]; textRole:"label" } }
    Component { id: tipFactory; UI.ToolTip { text: "A long explanation that wraps to remain inside a narrow popup." } }
    Component {
        id: ownedSelectFactory
        UI.Select {
            x:20; y:250
            property int ownerIndex: 0
            property bool acceptRequests: true
            model: [{label:"Alpha",available:true},{label:"Beta",available:false},{label:"Bravo",available:true}]
            textRole:"label"; enabledRole:"available"
            currentIndex: ownerIndex
            onActivated: index => { if (acceptRequests) ownerIndex=index; }
        }
    }
    Component { id: fieldStory; Stories.TextFieldStory {} }
    Component { id: checkboxStory; Stories.CheckBoxStory {} }
    Component { id: modelFactory; ListModel {} }
    SignalSpy { id: accepted; signalName: "accepted" }
    SignalSpy { id: activation; signalName: "activated" }
    TestCase {
        name: "QuickUIFormHardening"
        when: windowShown
        function init() { failOnWarning(/.*/); activation.clear(); accepted.clear(); }
        function cleanup() { activation.target = null; accepted.target = null; }
        function make(factory) { const item=createTemporaryObject(factory,parent); verify(item); item.theme.motionDuration=0; return item; }
        function test_fieldInvalidAndSelection() {
            const field=make(fieldFactory);
            verify("invalid" in field);
            field.invalid=true;
            compare(field.background.border.color,field.theme.destructive);
            field.forceActiveFocus(Qt.TabFocusReason);
            compare(field.background.border.color,field.theme.destructive);
            field.theme.selection="#123456"; field.theme.selectionForeground="#abcdef";
            compare(field.selectionColor,"#123456"); compare(field.selectedTextColor,"#abcdef");
            field.text="abc"; field.selectAll(); compare(field.selectedText,"abc");
        }
        function test_toggleFocusSizeDescription() {
            for (const factory of [switchFactory,checkFactory]) {
                const control=make(factory);
                verify("size" in control); verify("description" in control);
                control.forceActiveFocus(Qt.TabFocusReason);
                const ring=findChild(control,"focusRing"); verify(ring); verify(ring.visible);
                verify(ring.width>control.indicator.width); verify(ring.height>control.indicator.height);
                compare(ring.border.color,control.theme.focus);
                const regular=control.implicitHeight;
                control.size="sm"; verify(control.implicitHeight<regular);
                control.size="lg"; verify(control.implicitHeight>regular);
                control.width=230; control.multiline=true;
                control.description="This description wraps over multiple lines when space is constrained.";
                compare(control.Accessible.description,control.description);
                tryVerify(()=>control.implicitHeight>control.theme.heightFor("lg"));
                control.checked=false; verify(ring.visible);
                control.invalid=true; compare(control.indicator.border.color,control.theme.destructive);
            }
        }
        function test_selectAvailabilityKeyboardAndTypeahead() {
            const select=make(selectFactory); verify("enabledRole" in select);
            select.enabledRole="available"; activation.target=select;
            select.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Down); compare(select.currentIndex,2); compare(activation.count,1);
            keyClick(Qt.Key_End); compare(select.currentIndex,2);
            keyClick(Qt.Key_Home); compare(select.currentIndex,0);
            keyClick(Qt.Key_B); compare(select.currentIndex,2);
            keyClick(Qt.Key_Up,Qt.ControlModifier); compare(select.currentIndex,0);
            keyClick(Qt.Key_Down,Qt.ControlModifier); compare(select.currentIndex,2);
            keyClick(Qt.Key_Down,Qt.AltModifier); tryCompare(select.popup,"visible",true); compare(select.currentIndex,2);
            keyClick(Qt.Key_Up,Qt.AltModifier); tryCompare(select.popup,"visible",false);
            keyClick(Qt.Key_Space); tryCompare(select.popup,"visible",true);
            keyClick(Qt.Key_Up); compare(select.highlightedIndex,0);
            keyClick(Qt.Key_Down); compare(select.highlightedIndex,2);
            keyClick(Qt.Key_Return); tryCompare(select.popup,"visible",false); compare(select.currentIndex,2);
        }
        function test_selectPlaceholderInvalidAndPointer() {
            const select=make(selectFactory); verify("placeholderText" in select);
            select.placeholderText="Choose an output"; select.currentIndex=-1;
            compare(select.contentItem.placeholderText,"Choose an output");
            select.invalid=true; compare(select.background.border.color,select.theme.destructive);
            select.enabledRole="available"; select.currentIndex=0;
            select.theme.popup="#123456"; select.theme.popupForeground="#abcdef";
            select.theme.selection="#334455"; select.theme.selectionForeground="#ddeeff";
            select.popup.open(); tryCompare(select.popup,"visible",true);
            const list=select.popup.contentItem; tryVerify(()=>list.itemAtIndex(1)!==null);
            const disabled=list.itemAtIndex(1); compare(disabled.enabled,false);
            mouseClick(disabled,disabled.width/2,disabled.height/2); compare(select.currentIndex,0); verify(select.popup.visible);
            compare(select.popup.background.color,"#123456");
            const selected=list.itemAtIndex(0); verify(findChild(selected,"selectedIndicator").visible);
            compare(selected.background.color,"#334455"); compare(selected.contentItem.color,"#ddeeff");
            select.popup.close();
        }
        function test_selectAllDisabledAndLiveListModel() {
            const select=make(selectFactory);
            const model=createTemporaryObject(modelFactory,parent);
            model.append({label:"Alpha",available:false}); model.append({label:"Bravo",available:false});
            select.model=model; select.enabledRole="available"; select.currentIndex=-1;
            activation.target=select; select.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Down); keyClick(Qt.Key_B); compare(select.currentIndex,-1); compare(activation.count,0);
            model.setProperty(1,"available",true);
            keyClick(Qt.Key_Down); compare(select.currentIndex,1); compare(activation.count,1);
            select.popup.open(); tryCompare(select.popup,"visible",true);
            const list=select.popup.contentItem; tryVerify(()=>list.itemAtIndex(1)!==null);
            model.setProperty(1,"available",false); compare(list.itemAtIndex(1).enabled,false);
            keyClick(Qt.Key_Return); compare(activation.count,1); verify(select.popup.visible);
            select.popup.close();
        }
        function test_selectEditableAndUnavailableAcceptance() {
            const select=make(selectFactory); select.editable=true; select.enabledRole="available";
            accepted.target=select; select.contentItem.forceActiveFocus(Qt.TabFocusReason);
            select.contentItem.selectAll(); keyClick(Qt.Key_B);
            compare(select.editText.toLowerCase(),"beta");
            keyClick(Qt.Key_Return); compare(accepted.count,0); compare(select.currentIndex,0);
            select.contentItem.selectAll(); keyClick(Qt.Key_B); keyClick(Qt.Key_R);
            compare(select.editText.toLowerCase(),"bravo");
            keyClick(Qt.Key_Return); compare(accepted.count,1); compare(select.currentIndex,2);
            keyClick(Qt.Key_Up); compare(select.currentIndex,0);
            select.popup.open(); tryCompare(select.popup,"visible",true);
            select.contentItem.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Down); compare(select.highlightedIndex,2);
            keyClick(Qt.Key_Return); compare(select.currentIndex,2); tryCompare(select.popup,"visible",false);
            select.contentItem.forceActiveFocus(Qt.TabFocusReason);
            select.contentItem.selectAll(); keyClick(Qt.Key_Z);
            keyClick(Qt.Key_Return); compare(accepted.count,2); // native custom-value acceptance
        }
        function test_selectKeepsOwnerBindings() {
            const select=make(ownedSelectFactory);
            select.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Down); compare(select.currentIndex,2); compare(select.ownerIndex,2);
            select.ownerIndex=0; compare(select.currentIndex,0);
            select.acceptRequests=false;
            keyClick(Qt.Key_Down); compare(select.currentIndex,0);
            select.popup.open(); tryCompare(select.popup,"visible",true);
            keyClick(Qt.Key_Down); compare(select.highlightedIndex,2);
            keyClick(Qt.Key_Return); compare(select.currentIndex,0); compare(select.ownerIndex,0);
            select.acceptRequests=true;
            keyClick(Qt.Key_B); compare(select.currentIndex,2); compare(select.ownerIndex,2);
            select.ownerIndex=0; compare(select.currentIndex,0);
        }
        function test_selectWheelSkipsUnavailable() {
            const select=make(selectFactory); select.enabledRole="available"; select.wheelEnabled=true;
            mouseWheel(select,select.width/2,select.height/2,0,-120);
            compare(select.currentIndex,2);
            mouseWheel(select,select.width/2,select.height/2,0,120);
            compare(select.currentIndex,0);
        }
        function test_fieldStoryNativeValidation() {
            const story=createTemporaryObject(fieldStory,parent,{args:{numeric:true}});
            verify(story); const field=story.children[0];
            accepted.target=field; field.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_A); compare(field.text,"");
            keyClick(Qt.Key_4); keyClick(Qt.Key_2); compare(field.text,"42"); verify(field.acceptableInput);
            keyClick(Qt.Key_Return); compare(accepted.count,1);
            story.localText="101"; verify(!field.acceptableInput); compare(field.invalid,false);
            keyClick(Qt.Key_Return); compare(accepted.count,1);
            story.args={numeric:true,text:"0"}; compare(field.text,"0"); verify(field.acceptableInput);
        }
        function test_checkboxStoryTristateAndSelectAllReset() {
            const story=createTemporaryObject(checkboxStory,parent,{args:{tristate:true,partial:true}});
            verify(story); const box=story.children[0]; compare(box.checkState,Qt.PartiallyChecked);
            box.forceActiveFocus(Qt.TabFocusReason); keyClick(Qt.Key_Space); compare(box.checkState,Qt.Checked);
            keyClick(Qt.Key_Space); compare(box.checkState,Qt.Unchecked);
            story.args={selectAll:true}; compare(box.checkState,Qt.PartiallyChecked);
            keyClick(Qt.Key_Space); compare(box.checkState,Qt.Checked);
            compare(JSON.stringify(story.selections),"[true,true]");
            keyClick(Qt.Key_Space); compare(box.checkState,Qt.Unchecked);
            compare(JSON.stringify(story.selections),"[false,false]");
            story.args={selectAll:true,description:"Group"}; compare(box.checkState,Qt.PartiallyChecked);
        }
        function test_tooltipWidthPlacementNativeSemantics() {
            const tip=make(tipFactory); verify("maximumWidth" in tip);
            tip.parent=parent; tip.maximumWidth=160;
            tip.open(); tryCompare(tip,"visible",true);
            verify(tip.width<=160); verify(tip.height>tip.font.pixelSize+2*tip.padding);
            compare(tip.contentItem.text,tip.text);
            tip.close();
        }
    }
}
