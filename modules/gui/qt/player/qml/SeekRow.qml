/*****************************************************************************
 * Copyright (C) 2026 VLC authors and VideoLAN
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
import QtQuick.Layouts
import QtQuick.Templates as T

import VLC.MainInterface
import VLC.Player
import VLC.Style
import VLC.Util
import VLC.Widgets as Widgets

// The elapsed time, the seek bar and the duration on one line, as the design
// draws them: between the transport on the left and the volume and the rest of
// the buttons on the right, rather than on a line of their own above them.
RowLayout {
    id: root

    property real sliderHeight: VLCStyle.heightBar_xxsmall

    property bool showRemainingTime: true

    property alias slider: slider

    spacing: VLCStyle.margin_small

    readonly property ColorContext colorContext: ColorContext {
        id: theme
        colorSet: ColorContext.Window
    }

    TextMetrics {
        id: timeTextMetrics

        font.pixelSize: VLCStyle.fontSize_normal

        // the elapsed time and the duration are given the same width so the
        // bar between them does not shift as the digits change
        text: (Player.time.isSubHour() && Player.length.isSubHour()) ? "00--00"
                                                                     : "00--00--00"
    }

    T.Label {
        id: mediaTime

        Layout.preferredWidth: timeTextMetrics.width

        text: {
            const length = Player.length
            return Player.time.formatHMS(length.isSubSecond() ? VLCTick.SubSecondFormattedAsMS : 0)
        }

        color: theme.fg.secondary
        font: timeTextMetrics.font

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Accessible.ignored: true
    }

    SliderBar {
        id: slider

        barHeight: root.sliderHeight

        Accessible.role: Accessible.Slider
        Accessible.name: qsTr("Progress")
        AccessibleCompat.id: "progressSlider"

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        enabled: Player.playingState === Player.PLAYING_STATE_PLAYING
                 || Player.playingState === Player.PLAYING_STATE_PAUSED

        activeFocusOnTab: true

        Navigation.parentItem: root

        Keys.onPressed: (event) => {
            Navigation.defaultKeyAction(event)
        }
    }

    T.Label {
        id: mediaRemainingTime

        readonly property bool showRemainingTime: (MainCtx.showRemainingTime
                                                   && Player.remainingTime.valid())

        Layout.preferredWidth: timeTextMetrics.width

        text: showRemainingTime ? "-" + Player.remainingTime.formatHMS()
                                : Player.length.formatHMS()

        color: theme.fg.secondary
        font: timeTextMetrics.font

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        visible: root.showRemainingTime

        Accessible.ignored: true

        TapHandler {
            onTapped: (eventPoint, button) => {
                MainCtx.showRemainingTime = !MainCtx.showRemainingTime
            }
        }
    }
}
