/*****************************************************************************
 * Copyright (C) 2019 VLC authors and VideoLAN
 *
 * Authors: Benjamin Arnaud <bunjee@omega.gg>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

import QtQuick
import QtQuick.Templates as T


import VLC.MainInterface
import VLC.Style

T.Switch {
    id: root

    // Style

    property int animationDuration: VLCStyle.duration_long

    // The box keeps its colour in both states. What changes is the caption
    // block sitting beside the handle: tinted with the accent and reading ON,
    // or dim and reading OFF.
    property color color: theme.bg.primary

    property color colorHandle: (checked) ? theme.fg.secondary
                                          : theme.fg.primary

    property color colorCaption: (checked) ? theme.bg.secondary
                                           : theme.border

    property color colorCaptionText: (checked) ? theme.accent
                                               : theme.indicator

    // Private

    property bool _update: true

    // Settings

    width : VLCStyle.checkButton_width
    height: VLCStyle.checkButton_height

    T.ToolTip.visible: (T.ToolTip.text && (hovered || visualFocus))

    T.ToolTip.text: text

    T.ToolTip.delay: VLCStyle.delayToolTipAppear

    // Keys

    Keys.priority: Keys.AfterItem

    Keys.onPressed: (event) => Navigation.defaultKeyAction(event)

    // Accessible

    Accessible.onPressAction: control.clicked()
    Accessible.onToggleAction: control.toggle()

    // Events

    onWidthChanged: {
        animation.stop()

        if (checked)
            handle.x = handle.drag.maximumX
        else
            handle.x = handle.drag.minimumX
    }

    onCheckedChanged: {
        if (_update === false)
            return

        const from = handle.x
        let to

        if (checked)
            to = handle.drag.maximumX
        else
            to = handle.drag.minimumX

        _animate(from, to)
    }

    // Functions

    // Private

    function _applyX(x) {
        const from = handle.x
        let to

        _update = false

        if (x < width / 2) {
            to = handle.drag.minimumX

            checked = false
        } else {
            to = handle.drag.maximumX

            checked = true
        }

        _update = true

        _animate(from, to)
    }

    function _animate(from, to) {
        if (from === to)
            return

        animation.from = from
        animation.to   = to

        animation.restart()
    }

    // Animations

    NumberAnimation {
        id: animation

        target: handle

        property: "x"

        duration: VLCStyle.duration_short

        easing.type: Easing.OutQuad
    }

    // Children

    readonly property ColorContext colorContext: ColorContext {
        id: theme
        colorSet: ColorContext.Switch

        enabled: root.enabled
        focused: root.visualFocus
        hovered: root.hovered
        pressed: root.down
    }

    background: AnimatedBackground {
        enabled: theme.initialized
        border.color: root.visualFocus ? theme.visualFocus : Qt.alpha(theme.visualFocus, 0.0)
    }

    indicator: Rectangle {
        anchors.fill: parent

        radius: VLCStyle.checkButton_radius

        color: root.color

        Rectangle {
            id: caption

            width: VLCStyle.checkButton_caption_width
            height: VLCStyle.checkButton_handle_size

            // the caption takes the side the handle has left
            x: (root.checked) ? VLCStyle.checkButton_margins
                              : root.width - VLCStyle.checkButton_margins - width

            anchors.verticalCenter: parent.verticalCenter

            radius: VLCStyle.checkButton_handle_radius

            color: root.colorCaption

            Behavior on x {
                NumberAnimation {
                    duration: VLCStyle.duration_short

                    easing.type: Easing.OutQuad
                }
            }

            T.Label {
                anchors.centerIn: parent

                text: (root.checked) ? qsTr("ON") : qsTr("OFF")

                color: root.colorCaptionText

                font.pixelSize: VLCStyle.fontSize_small
            }
        }

        MouseArea {
            id: handle

            width : VLCStyle.checkButton_handle_size
            height: VLCStyle.checkButton_handle_size

            anchors.verticalCenter: parent.verticalCenter

            drag.target: handle
            drag.axis  : Drag.XAxis

            drag.minimumX: VLCStyle.checkButton_margins
            drag.maximumX: parent.width - VLCStyle.checkButton_margins - width

            onClicked: root.toggle()

            // NOTE: We update the position when the drag has ended.
            drag.onActiveChanged: if (drag.active === false) root._applyX(x + width / 2)

            Rectangle {
                anchors.fill: parent

                radius: VLCStyle.checkButton_handle_radius

                color: root.colorHandle
            }
        }
    }
}
