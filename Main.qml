import QtQuick 2.15
import QtQuick.Effects
import SddmComponents 2.0

Rectangle {
    id: root

    readonly property real uiScale: Math.max(0.01, Math.min(width / 1920, height / 1080))
    readonly property var defaultColors: ({
        "textPrimary": "#fff7fc",
        "textSecondary": "#e5d5e8",
        "textTertiary": "#e2d7e7",
        "accent": "#e0c7de",
        "accentStrong": "#d2afcb",
        "ink": "#2b1e33",
        "error": "#ffd1d9",
        "field": "#48304f",
        "fieldHover": "#523c5b",
        "selected": "#644a6d",
        "menu": "#e61f1526",
        "borderSubtle": "#45eadcf0",
        "borderStrong": "#78eadcf0",
        "borderFaint": "#40eadcf0",
        "focusBorder": "#d8cbd9",
        "divider": "#33eadcf0",
        "glassTint": "#2d1e35",
        "scrim": "#080b15"
    })
    readonly property string fontFamily: config.fontFamily ? config.fontFamily : "Noto Sans CJK SC"
    readonly property color textPrimary: config.textColor ? config.textColor : defaultColors.textPrimary
    readonly property color textSecondary: config.mutedColor ? config.mutedColor : defaultColors.textSecondary
    readonly property color textTertiary: config.tertiaryColor ? config.tertiaryColor : defaultColors.textTertiary
    readonly property color fallbackAccentColor: config.accentColor ? config.accentColor : defaultColors.accent
    readonly property color fallbackAccentStrongColor: config.accentSoftColor ? config.accentSoftColor : defaultColors.accentStrong
    readonly property color inkColor: config.panelColor ? config.panelColor : defaultColors.ink
    readonly property color errorColor: config.errorColor ? config.errorColor : defaultColors.error
    readonly property color fallbackFieldColor: config.fieldColor ? config.fieldColor : defaultColors.field
    readonly property color fallbackFieldHoverColor: config.fieldHoverColor ? config.fieldHoverColor : defaultColors.fieldHover
    readonly property color fallbackSelectedColor: config.selectedColor ? config.selectedColor : defaultColors.selected
    readonly property color fallbackMenuColor: config.menuColor ? config.menuColor : defaultColors.menu
    readonly property color fallbackBorderSubtleColor: config.borderColor ? config.borderColor : defaultColors.borderSubtle
    readonly property color fallbackBorderStrongColor: config.borderStrongColor ? config.borderStrongColor : defaultColors.borderStrong
    readonly property color fallbackBorderFaintColor: config.borderFaintColor ? config.borderFaintColor : defaultColors.borderFaint
    readonly property color fallbackFocusBorderColor: config.focusBorderColor ? config.focusBorderColor : defaultColors.focusBorder
    readonly property color fallbackDividerColor: config.dividerColor ? config.dividerColor : defaultColors.divider
    readonly property color fallbackGlassTintColor: config.glassTintColor ? config.glassTintColor : defaultColors.glassTint
    readonly property string backgroundSource: config.background ? Qt.resolvedUrl(config.background) : Qt.resolvedUrl("assets/wallpaper.webp")
    readonly property bool capsLockOn: typeof keyboard !== "undefined" ? keyboard.capsLock : false
    readonly property int railDesignWidth: 608
    readonly property int avatarFrameSize: 128
    readonly property int avatarImageSize: 112
    readonly property int avatarImageRadius: 56
    readonly property int avatarRingWidth: 6
    readonly property int avatarShadowOffset: 5
    readonly property int avatarInitialPixelSize: 20
    readonly property real railWidth: Math.min(width, railDesignWidth * uiScale)
    readonly property bool autoColors: config.autoColors !== false && config.autoColors !== "false"
    readonly property bool autoSurfaceColors: config.autoSurfaceColors !== false && config.autoSurfaceColors !== "false"
    readonly property color accentColor: sampledPaletteReady ? sampledAccentColor : fallbackAccentColor
    readonly property color accentStrongColor: sampledPaletteReady ? sampledAccentStrongColor : fallbackAccentStrongColor
    readonly property color glassTintColor: sampledPaletteReady ? sampledGlassTintColor : fallbackGlassTintColor
    readonly property bool dynamicSurfaceColors: sampledPaletteReady && autoSurfaceColors
    readonly property real themedSurfaceSaturation: clampValue(glassTintColor.hslSaturation * 0.85, 0.18, 0.28)
    property color fieldColor: fallbackFieldColor
    property color fieldHoverColor: fallbackFieldHoverColor
    property color selectedColor: fallbackSelectedColor
    property color menuColor: fallbackMenuColor
    property color borderSubtleColor: fallbackBorderSubtleColor
    property color borderStrongColor: fallbackBorderStrongColor
    property color borderFaintColor: fallbackBorderFaintColor
    property color focusBorderColor: fallbackFocusBorderColor
    property color dividerColor: fallbackDividerColor
    property color scrimColor: defaultColors.scrim
    property color sampledAccentColor: defaultColors.accent
    property color sampledAccentStrongColor: defaultColors.accentStrong
    property color sampledGlassTintColor: defaultColors.glassTint
    property bool sampledPaletteReady: false
    property bool paletteSamplingDone: false
    property bool previewMode: false
    property int currentUserIndex: -1
    property string currentUserName: ""
    property string currentUserDisplayName: ""
    property string currentUserAvatar: ""
    property bool currentUserNeedsPassword: true
    property int sessionIndex: -1
    property string sessionName: ""
    property bool showPassword: false
    property bool loginPending: false
    property bool statusIsError: false
    property string statusMessage: ""
    property string activeMenu: ""
    property string pendingPowerAction: ""
    property date now: new Date()
    readonly property var powerActions: [{
        "action": "suspend",
        "label": "睡眠",
        "icon": Qt.resolvedUrl("assets/icons/sleep.svg"),
        "description": "后台任务可能会暂停。"
    }, {
        "action": "reboot",
        "label": "重启",
        "icon": Qt.resolvedUrl("assets/icons/restart.svg"),
        "description": "未保存的工作可能会受到影响。"
    }, {
        "action": "powerOff",
        "label": "关机",
        "icon": Qt.resolvedUrl("assets/icons/power.svg"),
        "description": "未保存的工作可能会受到影响。"
    }]

    component ThemedIcon: Item {
        id: themedIcon

        property url source
        property color tintColor: root.textSecondary

        Image {
            id: sourceImage

            anchors.fill: parent
            source: themedIcon.source
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: sourceImage.status !== Image.Ready || GraphicsInfo.api === GraphicsInfo.Software
        }

        MultiEffect {
            anchors.fill: parent
            source: sourceImage
            visible: sourceImage.status === Image.Ready && GraphicsInfo.api !== GraphicsInfo.Software
            colorization: 1
            colorizationColor: themedIcon.tintColor
            autoPaddingEnabled: false
        }

    }

    function userIconSource(path) {
        if (path.indexOf("://") >= 0 || path.charAt(0) === "/")
            return path;

        return Qt.resolvedUrl(path);
    }

    function clampValue(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function themeHsla(lightness, alpha, saturation) {
        return Qt.hsla(accentColor.hslHue, saturation, lightness, alpha);
    }

    function themeRgba(alpha) {
        return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, alpha);
    }

    function updateThemeColors() {
        // config is static for the greeter lifetime; wallpaper-derived changes refresh via explicit signals below.
        if (dynamicSurfaceColors) {
            fieldColor = themeHsla(0.25, 1, themedSurfaceSaturation);
            fieldHoverColor = themeHsla(0.3, 1, themedSurfaceSaturation);
            selectedColor = themeHsla(0.34, 1, themedSurfaceSaturation);
            menuColor = themeHsla(0.125, 0.94, Math.min(themedSurfaceSaturation, 0.22));
            borderSubtleColor = themeRgba(0.28);
            borderStrongColor = themeRgba(0.52);
            borderFaintColor = themeRgba(0.18);
            focusBorderColor = accentStrongColor;
            dividerColor = themeRgba(0.22);
            scrimColor = themeHsla(0.04, 1, themedSurfaceSaturation * 0.7);
        } else {
            fieldColor = fallbackFieldColor;
            fieldHoverColor = fallbackFieldHoverColor;
            selectedColor = fallbackSelectedColor;
            menuColor = fallbackMenuColor;
            borderSubtleColor = fallbackBorderSubtleColor;
            borderStrongColor = fallbackBorderStrongColor;
            borderFaintColor = fallbackBorderFaintColor;
            focusBorderColor = fallbackFocusBorderColor;
            dividerColor = fallbackDividerColor;
            scrimColor = defaultColors.scrim;
        }
    }

    function timeGreeting() {
        var hour = now.getHours();
        if (hour >= 5 && hour < 11)
            return "早上好";

        if (hour >= 11 && hour < 13)
            return "中午好";

        if (hour >= 13 && hour < 18)
            return "下午好";

        if (hour >= 18 && hour < 23)
            return "晚上好";

        return "夜深了";
    }

    function sampleWallpaperPalette(data) {
        if (!autoColors || paletteSamplingDone || !data || data.length === 0)
            return ;

        paletteSamplingDone = true;
        var binCount = 18;
        var hueX = [];
        var hueY = [];
        var weights = [];
        var saturations = [];
        for (var bin = 0; bin < binCount; ++bin) {
            hueX.push(0);
            hueY.push(0);
            weights.push(0);
            saturations.push(0);
        }
        var totalWeight = 0;
        for (var index = 0; index < data.length; index += 4) {
            if (data[index + 3] < 128)
                continue;

            var red = data[index] / 255;
            var green = data[index + 1] / 255;
            var blue = data[index + 2] / 255;
            var maximum = Math.max(red, green, blue);
            var minimum = Math.min(red, green, blue);
            var delta = maximum - minimum;
            var lightness = (maximum + minimum) / 2;
            if (lightness < 0.06 || lightness > 0.95 || delta < 0.01)
                continue;

            var saturation = delta / (1 - Math.abs(2 * lightness - 1));
            if (saturation < 0.08)
                continue;

            var hue;
            if (maximum === red)
                hue = ((green - blue) / delta) % 6;
            else if (maximum === green)
                hue = (blue - red) / delta + 2;
            else
                hue = (red - green) / delta + 4;
            hue = ((hue / 6) + 1) % 1;
            var hueBin = Math.floor(hue * binCount) % binCount;
            var weight = 0.05 + saturation * saturation;
            var angle = hue * Math.PI * 2;
            hueX[hueBin] += Math.cos(angle) * weight;
            hueY[hueBin] += Math.sin(angle) * weight;
            weights[hueBin] += weight;
            saturations[hueBin] += saturation * weight;
            totalWeight += weight;
        }
        if (totalWeight < 1)
            return ;

        var dominantBin = 0;
        for (var candidate = 1; candidate < binCount; ++candidate) {
            if (weights[candidate] > weights[dominantBin])
                dominantBin = candidate;

        }
        if (weights[dominantBin] <= 0)
            return ;

        var hue = Math.atan2(hueY[dominantBin], hueX[dominantBin]) / (Math.PI * 2);
        hue = (hue + 1) % 1;
        var saturation = saturations[dominantBin] / weights[dominantBin];
        var accentSaturation = clampValue(Math.max(0.28, saturation * 1.35), 0.28, 0.5);
        var darkSaturation = clampValue(Math.max(0.2, saturation * 0.72), 0.2, 0.36);
        sampledAccentColor = Qt.hsla(hue, accentSaturation, 0.8, 1);
        sampledAccentStrongColor = Qt.hsla(hue, accentSaturation + 0.04, 0.7, 1);
        sampledGlassTintColor = Qt.hsla(hue, darkSaturation, 0.15, 1);
        sampledPaletteReady = true;
    }

    function refreshUsers() {
        var count = userModel.count;
        if (count <= 0) {
            currentUserIndex = -1;
            currentUserName = "";
            currentUserDisplayName = "登录";
            currentUserAvatar = "";
            currentUserNeedsPassword = true;
            return ;
        }
        var index = userModel.lastIndex;
        if (index < 0 || index >= count)
            index = 0;

        currentUserIndex = index;
        var item = userMetaRepeater.itemAt(index);
        if (item) {
            currentUserName = item.accountName;
            currentUserDisplayName = item.accountDisplayName;
            currentUserAvatar = item.accountIcon;
            currentUserNeedsPassword = item.needsPassword;
        } else {
            currentUserName = userModel.lastUser;
            currentUserDisplayName = userModel.lastUser;
            currentUserAvatar = "";
            currentUserNeedsPassword = true;
        }
    }

    function selectUser(index) {
        var item = userMetaRepeater.itemAt(index);
        if (!item)
            return ;

        currentUserIndex = index;
        currentUserName = item.accountName;
        currentUserDisplayName = item.accountDisplayName;
        currentUserAvatar = item.accountIcon;
        currentUserNeedsPassword = item.needsPassword;
        passwordField.text = "";
        statusMessage = "";
        closeMenus();
        if (currentUserNeedsPassword)
            passwordField.forceActiveFocus();
        else
            loginButton.forceActiveFocus();
    }

    function refreshSessions() {
        var count = sessionModel.count;
        if (count <= 0) {
            sessionIndex = -1;
            sessionName = "";
            return ;
        }
        var index = sessionModel.lastIndex;
        if (index < 0 || index >= count)
            index = 0;

        sessionIndex = index;
        var item = sessionMetaRepeater.itemAt(index);
        sessionName = item ? item.sessionLabel : "";
    }

    function selectSession(index, name) {
        sessionIndex = index;
        sessionName = name;
        closeMenus();
        sessionTrigger.forceActiveFocus();
    }

    function focusEntry() {
        if (currentUserIndex < 0)
            usernameField.forceActiveFocus();
        else if (currentUserNeedsPassword)
            passwordField.forceActiveFocus();
        else
            loginButton.forceActiveFocus();
    }

    function submitLogin() {
        if (loginPending)
            return ;

        closeMenus();
        var account = currentUserIndex >= 0 ? currentUserName : usernameField.text.trim();
        if (account === "") {
            statusIsError = true;
            statusMessage = "请输入用户名。";
            usernameField.forceActiveFocus();
            return ;
        }
        if ((currentUserIndex < 0 || currentUserNeedsPassword) && passwordField.text === "") {
            statusIsError = true;
            statusMessage = "请输入密码。";
            passwordField.forceActiveFocus();
            return ;
        }
        loginPending = true;
        statusIsError = false;
        statusMessage = "正在登录…";
        loginButton.forceActiveFocus();
        sddm.login(account, passwordField.text, sessionIndex);
    }

    function openMenu(name) {
        if (name === "user" && userModel.count <= 0)
            return ;

        if (name === "session" && sessionModel.count <= 0)
            return ;

        activeMenu = name;
        Qt.callLater(function() {
            if (root.activeMenu === "user") {
                userMenuList.currentIndex = Math.max(0, root.currentUserIndex);
                userMenuList.positionViewAtIndex(userMenuList.currentIndex, ListView.Contain);
                userMenuList.forceActiveFocus();
            } else if (root.activeMenu === "session") {
                sessionMenuList.currentIndex = Math.max(0, root.sessionIndex);
                sessionMenuList.positionViewAtIndex(sessionMenuList.currentIndex, ListView.Contain);
                sessionMenuList.forceActiveFocus();
            }
        });
    }

    function closeMenus() {
        activeMenu = "";
    }

    function powerActionEnabled(action) {
        if (typeof sddm === "undefined" || sddm === null)
            return false;

        if (action === "suspend")
            return sddm.canSuspend;

        if (action === "reboot")
            return sddm.canReboot;

        if (action === "powerOff")
            return sddm.canPowerOff;

        return false;
    }

    function powerActionTitle() {
        if (pendingPowerAction === "suspend")
            return "进入睡眠？";

        if (pendingPowerAction === "reboot")
            return "重启设备？";

        if (pendingPowerAction === "powerOff")
            return "关闭设备？";

        return "确认操作";
    }

    function requestPowerAction(action) {
        if (!powerActionEnabled(action))
            return ;

        closeMenus();
        pendingPowerAction = action;
        Qt.callLater(function() {
            cancelPowerButton.forceActiveFocus();
        });
    }

    function executePowerAction() {
        var action = pendingPowerAction;
        pendingPowerAction = "";
        if (action === "suspend" && sddm.canSuspend)
            sddm.suspend();
        else if (action === "reboot" && sddm.canReboot)
            sddm.reboot();
        else if (action === "powerOff" && sddm.canPowerOff)
            sddm.powerOff();
    }

    function initialize() {
        refreshUsers();
        refreshSessions();
        Qt.callLater(root.refreshUsers);
        Qt.callLater(root.refreshSessions);
        Qt.callLater(root.focusEntry);
    }

    width: Screen.width
    height: Screen.height
    color: previewMode ? "transparent" : "#1c1423"
    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Component.onCompleted: updateThemeColors()
    onAccentColorChanged: updateThemeColors()
    onAccentStrongColorChanged: updateThemeColors()
    onThemedSurfaceSaturationChanged: updateThemeColors()
    onDynamicSurfaceColorsChanged: updateThemeColors()

    Rectangle {
        anchors.fill: parent
        visible: !root.previewMode

        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#1c1423"
            }

            GradientStop {
                position: 0.52
                color: "#403049"
            }

            GradientStop {
                position: 1
                color: "#1c1423"
            }

        }

    }

    Image {
        id: wallpaperImage

        anchors.fill: parent
        source: root.backgroundSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        visible: status === Image.Ready && !root.previewMode
        onStatusChanged: {
            if (status === Image.Ready) {
                blurSource.scheduleUpdate();
                Qt.callLater(function() {
                    paletteCanvas.requestPaint();
                });
            }
        }
        onSourceChanged: {
            sampledPaletteReady = false;
            paletteSamplingDone = false;
            blurSource.scheduleUpdate();
            paletteCanvas.paletteSourceLoaded = false;
            paletteCanvas.requestPaint();
        }
    }

    Canvas {
        id: paletteCanvas

        property bool paletteSourceLoaded: false

        width: 64
        height: 36
        opacity: 0.001
        renderTarget: Canvas.Image
        visible: root.autoColors && !root.paletteSamplingDone
        onImageLoaded: {
            paletteSourceLoaded = true;
            requestPaint();
        }
        onPaint: {
            if (root.paletteSamplingDone || !root.autoColors)
                return ;

            var context = getContext("2d");
            context.imageSmoothingEnabled = true;
            context.clearRect(0, 0, width, height);
            context.drawImage(root.backgroundSource, 0, 0, width, height);
            if (!paletteSourceLoaded)
                return ;

            try {
                var paletteData = context.getImageData(0, 0, width, height).data;
                root.sampleWallpaperPalette(paletteData);
            } catch (error) {
                console.warn("Wallpaper palette sampling failed:", error);
                root.paletteSamplingDone = true;
                root.sampledPaletteReady = false;
            }
        }
    }

    ShaderEffectSource {
        id: blurSource

        width: root.railWidth
        height: root.height
        sourceItem: wallpaperImage
        sourceRect: Qt.rect(0, 0, width, height)
        textureSize: Qt.size(Math.max(1, Math.ceil(width / 2)), Math.max(1, Math.ceil(height / 2)))
        live: false
        visible: false
        onWidthChanged: scheduleUpdate()
        onHeightChanged: scheduleUpdate()

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

    }

    MultiEffect {
        width: root.railWidth
        height: root.height
        source: blurSource
        blurEnabled: true
        blur: 1
        blurMax: 64
        autoPaddingEnabled: false
        visible: !root.previewMode && GraphicsInfo.api !== GraphicsInfo.Software

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

    }

    Rectangle {
        width: root.railWidth
        color: root.glassTintColor
        opacity: 0.32
        visible: !root.previewMode

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

    }

    Repeater {
        id: userMetaRepeater

        model: userModel
        onCountChanged: Qt.callLater(root.refreshUsers)

        Item {
            property string accountName: model.name
            property string accountDisplayName: model.realName ? model.realName : model.name
            property string accountIcon: model.icon ? model.icon : ""
            property bool needsPassword: model.needsPassword === undefined ? true : model.needsPassword

            width: 0
            height: 0
            visible: false
        }

    }

    Repeater {
        id: sessionMetaRepeater

        model: sessionModel
        onCountChanged: Qt.callLater(root.refreshSessions)

        Item {
            property string sessionLabel: model.name

            width: 0
            height: 0
            visible: false
        }

    }

    Item {
        id: canvas

        objectName: "layoutCanvas"
        width: root.width / root.uiScale
        height: root.height / root.uiScale
        scale: root.uiScale
        transformOrigin: Item.TopLeft

        anchors {
            left: parent.left
            top: parent.top
        }

        Item {
            id: loginContent

            objectName: "loginContent"
            x: 96
            width: 416
            height: loginStack.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            Column {
                id: loginStack

                width: parent.width
                spacing: 24

                Column {
                    width: parent.width
                    spacing: 24

                    Item {
                        id: avatarBlock

                        width: root.avatarFrameSize
                        height: root.avatarFrameSize
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            width: root.avatarFrameSize
                            height: root.avatarFrameSize
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: root.avatarShadowOffset
                            radius: root.avatarFrameSize / 2
                            color: "#000000"
                            opacity: 0.18
                        }

                        Rectangle {
                            width: root.avatarFrameSize
                            height: root.avatarFrameSize
                            anchors.centerIn: parent
                            radius: root.avatarFrameSize / 2
                            color: "#000000"
                            border.color: root.accentColor
                            border.width: root.avatarRingWidth
                        }

                        Rectangle {
                            id: avatarMask

                            width: root.avatarImageSize
                            height: root.avatarImageSize
                            anchors.centerIn: parent
                            radius: root.avatarImageRadius
                            color: "#ffffff"
                            visible: false
                            layer.enabled: true
                        }

                        Image {
                            id: avatarImage

                            width: root.avatarImageSize
                            height: root.avatarImageSize
                            anchors.centerIn: parent
                            visible: false
                            source: root.currentUserAvatar === "" ? "" : root.userIconSource(root.currentUserAvatar)
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: root.avatarImageSize
                            sourceSize.height: root.avatarImageSize
                            asynchronous: true
                            cache: true
                            smooth: true
                        }

                        MultiEffect {
                            id: avatarEffect

                            width: root.avatarImageSize
                            height: root.avatarImageSize
                            anchors.centerIn: parent
                            source: avatarImage
                            maskEnabled: true
                            maskSource: avatarMask
                            autoPaddingEnabled: false
                            visible: !root.previewMode && GraphicsInfo.api !== GraphicsInfo.Software && avatarImage.status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !avatarEffect.visible
                            text: root.currentUserDisplayName.length > 0 ? root.currentUserDisplayName.charAt(0).toUpperCase() : "?"
                            color: root.accentColor
                            font.family: root.fontFamily
                            font.pixelSize: root.avatarInitialPixelSize
                            font.weight: Font.Medium
                        }

                    }

                    Column {
                        width: parent.width
                        spacing: 12

                        Item {
                            width: parent.width
                            height: userName.implicitHeight

                            Text {
                                width: parent.width
                                text: userName.text
                                color: "#000000"
                                opacity: 0.58
                                Accessible.ignored: true
                                font: userName.font
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight

                                transform: Translate {
                                    y: 2
                                }

                            }

                            Text {
                                id: userName

                                width: parent.width
                                text: root.currentUserDisplayName
                                color: root.textPrimary
                                font.family: root.fontFamily
                                font.pixelSize: 20
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }

                        }

                        Rectangle {
                            width: 312
                            height: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: root.borderStrongColor
                        }

                        Item {
                            width: parent.width
                            height: greeting.implicitHeight

                            Text {
                                width: parent.width
                                text: greeting.text
                                color: "#000000"
                                opacity: 0.58
                                Accessible.ignored: true
                                font: greeting.font
                                horizontalAlignment: Text.AlignHCenter

                                transform: Translate {
                                    y: 2
                                }

                            }

                            Text {
                                id: greeting

                                width: parent.width
                                text: root.timeGreeting()
                                color: root.textPrimary
                                font.family: root.fontFamily
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                            }

                        }

                    }

                }

                Column {
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        id: usernameBox

                        width: 312
                        height: 44
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.currentUserIndex < 0
                        radius: 22
                        color: root.fieldColor
                        border.width: 1
                        border.color: usernameField.activeFocus ? root.focusBorderColor : root.borderSubtleColor

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            visible: usernameField.text.length === 0
                            text: "用户名"
                            color: root.textTertiary
                            font.family: root.fontFamily
                            font.pixelSize: 14
                        }

                        TextInput {
                            id: usernameField

                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.textPrimary
                            selectionColor: root.accentColor
                            selectedTextColor: root.inkColor
                            Accessible.name: "用户名"
                            Accessible.role: Accessible.EditableText
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            selectByMouse: true
                            clip: true
                            KeyNavigation.tab: passwordField
                            onAccepted: passwordField.forceActiveFocus()

                            anchors {
                                left: parent.left
                                leftMargin: 16
                                right: parent.right
                                rightMargin: 16
                            }

                        }

                    }

                    Rectangle {
                        id: passwordBox

                        objectName: "passwordBox"
                        width: 312
                        height: 44
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.currentUserIndex < 0 || root.currentUserNeedsPassword
                        radius: 22
                        color: root.fieldColor
                        border.width: 1
                        border.color: passwordField.activeFocus || revealButton.activeFocus ? root.focusBorderColor : root.borderSubtleColor

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            visible: passwordField.text.length === 0
                            text: "密码"
                            color: root.textTertiary
                            font.family: root.fontFamily
                            font.pixelSize: 14
                        }

                        TextInput {
                            id: passwordField

                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.textPrimary
                            selectionColor: root.accentColor
                            selectedTextColor: root.inkColor
                            Accessible.name: "密码"
                            Accessible.role: Accessible.EditableText
                            echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                            passwordCharacter: "●"
                            inputMethodHints: root.showPassword ? Qt.ImhNone : Qt.ImhHiddenText | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            selectByMouse: true
                            clip: true
                            KeyNavigation.tab: revealButton
                            onAccepted: root.submitLogin()
                            Keys.onEscapePressed: {
                                text = "";
                                root.statusMessage = "";
                                event.accepted = true;
                            }

                            anchors {
                                left: parent.left
                                leftMargin: 16
                                right: revealButton.left
                                rightMargin: 8
                            }

                        }

                        Item {
                            id: revealButton

                            width: 32
                            height: 32
                            activeFocusOnTab: true
                            Accessible.name: root.showPassword ? "隐藏密码" : "显示密码"
                            Accessible.role: Accessible.Button
                            Keys.onSpacePressed: {
                                root.showPassword = !root.showPassword;
                                passwordField.forceActiveFocus();
                            }
                            Keys.onReturnPressed: {
                                root.showPassword = !root.showPassword;
                                passwordField.forceActiveFocus();
                            }
                            Keys.onEnterPressed: {
                                root.showPassword = !root.showPassword;
                                passwordField.forceActiveFocus();
                            }
                            KeyNavigation.tab: loginButton
                            KeyNavigation.backtab: passwordField

                            anchors {
                                right: parent.right
                                rightMargin: 6
                                verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 16
                                color: revealMouse.containsMouse ? root.fieldHoverColor : "transparent"
                                border.width: revealButton.activeFocus ? 1 : 0
                                border.color: root.accentColor
                            }

                            ThemedIcon {
                                anchors.centerIn: parent
                                width: 20
                                height: 20
                                source: root.showPassword ? Qt.resolvedUrl("assets/icons/eye.svg") : Qt.resolvedUrl("assets/icons/eye-off.svg")
                                tintColor: root.textSecondary
                            }

                            MouseArea {
                                id: revealMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    revealButton.forceActiveFocus();
                                    root.showPassword = !root.showPassword;
                                    passwordField.forceActiveFocus();
                                }
                            }

                        }

                    }

                    Rectangle {
                        id: loginButton

                        width: 312
                        height: 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 20
                        color: loginMouse.containsMouse ? root.accentStrongColor : root.accentColor
                        opacity: root.loginPending ? 0.65 : 1
                        border.width: activeFocus ? 1 : 0
                        border.color: root.textPrimary
                        activeFocusOnTab: true
                        Accessible.name: "登录"
                        Accessible.role: Accessible.Button
                        Keys.onSpacePressed: root.submitLogin()
                        Keys.onReturnPressed: root.submitLogin()
                        Keys.onEnterPressed: root.submitLogin()
                        KeyNavigation.backtab: root.currentUserIndex < 0 || root.currentUserNeedsPassword ? revealButton : null

                        Text {
                            anchors.centerIn: parent
                            text: root.loginPending ? "正在登录…" : "登录"
                            color: root.inkColor
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: loginMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                loginButton.forceActiveFocus();
                                root.submitLogin();
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }

                        }

                    }

                    Text {
                        width: parent.width
                        height: Math.max(24, contentHeight)
                        text: root.statusMessage !== "" ? root.statusMessage : root.capsLockOn ? "大写锁定已开启" : ""
                        color: root.statusIsError ? root.errorColor : root.capsLockOn ? root.accentStrongColor : root.textSecondary
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        Accessible.name: text
                    }

                }

                Row {
                    id: actionRow

                    x: (parent.width - width) / 2
                    width: 312
                    spacing: 12

                    Repeater {
                        model: root.powerActions

                        Item {
                            id: actionButton

                            property bool hovered: actionMouse.containsMouse && enabled

                            width: (actionRow.width - actionRow.spacing * 2) / 3
                            height: 78
                            activeFocusOnTab: true
                            enabled: root.powerActionEnabled(modelData.action)
                            opacity: enabled ? 1 : 0.42
                            Accessible.name: modelData.label
                            Accessible.role: Accessible.Button
                            Keys.onSpacePressed: root.requestPowerAction(modelData.action)
                            Keys.onReturnPressed: root.requestPowerAction(modelData.action)
                            Keys.onEnterPressed: root.requestPowerAction(modelData.action)

                            Rectangle {
                                width: 48
                                height: 48
                                anchors.horizontalCenter: parent.horizontalCenter
                                radius: 24
                                color: actionButton.hovered || actionButton.activeFocus ? root.fieldHoverColor : root.fieldColor
                                border.width: 1
                                border.color: actionButton.hovered || actionButton.activeFocus ? root.borderStrongColor : root.borderSubtleColor

                                ThemedIcon {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    source: modelData.icon
                                    tintColor: root.textSecondary
                                }

                            }

                            Text {
                                text: modelData.label
                                color: actionButton.hovered || actionButton.activeFocus ? root.textPrimary : root.textSecondary
                                font.family: root.fontFamily
                                font.pixelSize: 12

                                anchors {
                                    top: parent.top
                                    topMargin: 56
                                    horizontalCenter: parent.horizontalCenter
                                }

                            }

                            MouseArea {
                                id: actionMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: actionButton.enabled
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    actionButton.forceActiveFocus();
                                    root.requestPowerAction(modelData.action);
                                }
                            }

                        }

                    }

                }

            }

        }

        Rectangle {
            id: footerDivider

            width: parent.width
            height: 1
            y: parent.height - 64
            color: root.dividerColor
        }

        Item {
            id: footerControls

            objectName: "footerControls"
            x: 16
            y: parent.height - 64
            width: 560
            height: 64

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16

                Rectangle {
                    id: userTrigger

                    width: userTriggerContent.implicitWidth + 24
                    height: 32
                    radius: 16
                    color: userTriggerMouse.containsMouse || root.activeMenu === "user" ? root.selectedColor : root.fieldHoverColor
                    border.width: activeFocus ? 1 : 1
                    border.color: activeFocus || userTriggerMouse.containsMouse || root.activeMenu === "user" ? root.borderStrongColor : root.borderFaintColor
                    activeFocusOnTab: true
                    Accessible.name: "切换用户"
                    Accessible.role: Accessible.Button
                    Keys.onSpacePressed: root.openMenu("user")
                    Keys.onReturnPressed: root.openMenu("user")
                    Keys.onEnterPressed: root.openMenu("user")
                    KeyNavigation.tab: sessionTrigger
                    KeyNavigation.backtab: loginButton

                    Row {
                        id: userTriggerContent

                        anchors.centerIn: parent
                        spacing: 8

                        ThemedIcon {
                            width: 16
                            height: 16
                            source: Qt.resolvedUrl("assets/icons/user-switch.svg")
                            tintColor: root.textSecondary
                        }

                        Text {
                            text: "切换用户"
                            color: root.activeMenu === "user" ? root.textPrimary : root.textSecondary
                            font.family: root.fontFamily
                            font.pixelSize: 12
                        }

                    }

                    MouseArea {
                        id: userTriggerMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            userTrigger.forceActiveFocus();
                            if (root.activeMenu === "user")
                                root.closeMenus();
                            else
                                root.openMenu("user");
                        }
                    }

                }

                Rectangle {
                    id: sessionTrigger

                    width: sessionTriggerContent.implicitWidth + 24
                    height: 32
                    radius: 16
                    color: sessionTriggerMouse.containsMouse || root.activeMenu === "session" ? root.selectedColor : root.fieldHoverColor
                    border.width: activeFocus ? 1 : 1
                    border.color: activeFocus || sessionTriggerMouse.containsMouse || root.activeMenu === "session" ? root.borderStrongColor : root.borderFaintColor
                    activeFocusOnTab: true
                    Accessible.name: "会话：" + root.sessionName
                    Accessible.role: Accessible.Button
                    Keys.onSpacePressed: root.openMenu("session")
                    Keys.onReturnPressed: root.openMenu("session")
                    Keys.onEnterPressed: root.openMenu("session")
                    KeyNavigation.backtab: userTrigger

                    Row {
                        id: sessionTriggerContent

                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: root.sessionName !== "" ? root.sessionName : "选择会话"
                            color: root.activeMenu === "session" ? root.textPrimary : root.textSecondary
                            font.family: root.fontFamily
                            font.pixelSize: 12
                        }

                        ThemedIcon {
                            width: 12
                            height: 12
                            source: Qt.resolvedUrl("assets/icons/chevron-down.svg")
                            tintColor: root.textSecondary
                            rotation: root.activeMenu === "session" ? 180 : 0

                            transform: Translate {
                                y: 2
                            }

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 220
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                    }

                    MouseArea {
                        id: sessionTriggerMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            sessionTrigger.forceActiveFocus();
                            if (root.activeMenu === "session")
                                root.closeMenus();
                            else
                                root.openMenu("session");
                        }
                    }

                }

            }

        }

        Text {
            text: Qt.formatTime(root.now, "HH:mm")
            color: "#000000"
            opacity: 0.58
            Accessible.ignored: true
            font.family: root.fontFamily
            font.pixelSize: 72
            font.weight: Font.Normal

            anchors {
                right: parent.right
                rightMargin: 96
                bottom: footerDivider.top
                bottomMargin: 11
            }

            transform: Translate {
                y: 2
            }

        }

        Text {
            id: clockText

            objectName: "clockText"
            text: Qt.formatTime(root.now, "HH:mm")
            color: root.textSecondary
            font.family: root.fontFamily
            font.pixelSize: 72
            font.weight: Font.Normal

            anchors {
                right: parent.right
                rightMargin: 96
                bottom: footerDivider.top
                bottomMargin: 12
            }

        }

        Text {
            text: Qt.formatDate(root.now, Qt.DefaultLocaleLongDate)
            color: "#000000"
            opacity: 0.58
            Accessible.ignored: true
            font.family: root.fontFamily
            font.pixelSize: 20
            font.weight: Font.Medium

            anchors {
                right: parent.right
                rightMargin: 96
                verticalCenter: footerControls.verticalCenter
            }

            transform: Translate {
                y: 2
            }

        }

        Text {
            text: Qt.formatDate(root.now, Qt.DefaultLocaleLongDate)
            color: root.textSecondary
            font.family: root.fontFamily
            font.pixelSize: 20
            font.weight: Font.Medium

            anchors {
                right: parent.right
                rightMargin: 96
                verticalCenter: footerControls.verticalCenter
            }

        }

        MouseArea {
            anchors.fill: parent
            visible: root.activeMenu !== ""
            enabled: visible
            z: 20
            onClicked: root.closeMenus()
        }

        Rectangle {
            id: userMenu

            x: 16
            y: footerDivider.y - height - 8 + (root.activeMenu === "user" ? 0 : 8)
            width: 272
            height: Math.min(userModel.count, 6) * 48 + 16
            z: 21
            radius: 16
            color: root.menuColor
            border.width: 1
            border.color: root.borderSubtleColor
            opacity: root.activeMenu === "user" ? 1 : 0
            visible: opacity > 0.01
            enabled: root.activeMenu === "user"
            scale: root.activeMenu === "user" ? 1 : 0.98
            transformOrigin: Item.BottomLeft

            ListView {
                id: userMenuList

                anchors.fill: parent
                anchors.margins: 8
                clip: true
                model: userModel
                currentIndex: Math.max(0, root.currentUserIndex)
                boundsBehavior: Flickable.StopAtBounds
                focus: root.activeMenu === "user"
                Keys.onUpPressed: {
                    decrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onDownPressed: {
                    incrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onReturnPressed: root.selectUser(currentIndex)
                Keys.onEnterPressed: root.selectUser(currentIndex)
                Keys.onEscapePressed: {
                    root.closeMenus();
                    userTrigger.forceActiveFocus();
                }
                Keys.onTabPressed: {
                    root.closeMenus();
                    sessionTrigger.forceActiveFocus();
                }
                Keys.onBacktabPressed: {
                    root.closeMenus();
                    userTrigger.forceActiveFocus();
                    event.accepted = true;
                }

                delegate: Rectangle {
                    property string accountName: model.name
                    property string accountDisplayName: model.realName ? model.realName : model.name

                    width: ListView.view.width
                    height: 48
                    radius: 12
                    color: ListView.isCurrentItem ? root.selectedColor : userItemMouse.containsMouse ? root.fieldHoverColor : "transparent"
                    Accessible.name: accountDisplayName
                    Accessible.role: Accessible.Button
                    Accessible.checkable: true
                    Accessible.checked: root.currentUserIndex === index

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: root.fieldHoverColor

                        anchors {
                            left: parent.left
                            leftMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.accountDisplayName.length > 0 ? parent.parent.accountDisplayName.charAt(0).toUpperCase() : "?"
                            color: root.accentColor
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }

                    }

                    Text {
                        text: parent.accountDisplayName
                        color: ListView.isCurrentItem ? root.textPrimary : root.textSecondary
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        elide: Text.ElideRight

                        anchors {
                            left: parent.left
                            leftMargin: 52
                            right: checkIcon.left
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                    }

                    ThemedIcon {
                        id: checkIcon

                        width: 20
                        height: 20
                        source: Qt.resolvedUrl("assets/icons/check.svg")
                        tintColor: root.accentColor
                        visible: root.currentUserIndex === index

                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                    }

                    MouseArea {
                        id: userItemMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectUser(index)
                    }

                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on y {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

        }

        Rectangle {
            id: sessionMenu

            x: footerControls.x + userTrigger.width + 16
            y: footerDivider.y - height - 8 + (root.activeMenu === "session" ? 0 : 8)
            width: 272
            height: Math.min(sessionModel.count, 4) * 48 + 16
            z: 21
            radius: 16
            color: root.menuColor
            border.width: 1
            border.color: root.borderSubtleColor
            opacity: root.activeMenu === "session" ? 1 : 0
            visible: opacity > 0.01
            enabled: root.activeMenu === "session"
            scale: root.activeMenu === "session" ? 1 : 0.98
            transformOrigin: Item.BottomLeft

            ListView {
                id: sessionMenuList

                anchors.fill: parent
                anchors.margins: 8
                clip: true
                model: sessionModel
                currentIndex: Math.max(0, root.sessionIndex)
                boundsBehavior: Flickable.StopAtBounds
                focus: root.activeMenu === "session"
                Keys.onUpPressed: {
                    decrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onDownPressed: {
                    incrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onReturnPressed: {
                    if (currentItem)
                        root.selectSession(currentIndex, currentItem.sessionLabel);

                }
                Keys.onEnterPressed: {
                    if (currentItem)
                        root.selectSession(currentIndex, currentItem.sessionLabel);

                }
                Keys.onEscapePressed: {
                    root.closeMenus();
                    sessionTrigger.forceActiveFocus();
                }
                Keys.onTabPressed: {
                    root.closeMenus();
                    userTrigger.forceActiveFocus();
                }
                Keys.onBacktabPressed: {
                    root.closeMenus();
                    sessionTrigger.forceActiveFocus();
                    event.accepted = true;
                }

                delegate: Rectangle {
                    property string sessionLabel: model.name

                    width: ListView.view.width
                    height: 48
                    radius: 12
                    color: ListView.isCurrentItem ? root.selectedColor : sessionItemMouse.containsMouse ? root.fieldHoverColor : "transparent"
                    Accessible.name: sessionLabel
                    Accessible.role: Accessible.Button
                    Accessible.checkable: true
                    Accessible.checked: root.sessionIndex === index

                    Text {
                        text: parent.sessionLabel
                        color: ListView.isCurrentItem ? root.textPrimary : root.textSecondary
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        elide: Text.ElideRight

                        anchors {
                            left: parent.left
                            leftMargin: 12
                            right: sessionCheck.left
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                    }

                    ThemedIcon {
                        id: sessionCheck

                        width: 20
                        height: 20
                        source: Qt.resolvedUrl("assets/icons/check.svg")
                        tintColor: root.accentColor
                        visible: root.sessionIndex === index

                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                    }

                    MouseArea {
                        id: sessionItemMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectSession(index, parent.sessionLabel)
                    }

                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on y {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

        }

        Rectangle {
            anchors.fill: parent
            z: 30
            color: root.scrimColor
            opacity: 0.72
            visible: root.pendingPowerAction !== ""

            MouseArea {
                anchors.fill: parent
                onClicked: root.pendingPowerAction = ""
            }

        }

        Rectangle {
            id: powerPanel

            width: 384
            height: 258
            anchors.centerIn: parent
            z: 31
            radius: 16
            color: root.menuColor
            border.width: 1
            border.color: root.borderStrongColor
            visible: root.pendingPowerAction !== ""
            opacity: visible ? 1 : 0
            scale: visible ? 1 : 0.98
            Keys.onEscapePressed: root.pendingPowerAction = ""

            MouseArea {
                anchors.fill: parent
            }

            Text {
                x: 32
                y: 32
                width: parent.width - 64
                text: root.powerActionTitle()
                color: root.textPrimary
                font.family: root.fontFamily
                font.pixelSize: 20
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
            }

            Text {
                x: 32
                y: 76
                width: parent.width - 64
                text: {
                    for (var i = 0; i < root.powerActions.length; ++i) {
                        if (root.powerActions[i].action === root.pendingPowerAction)
                            return root.powerActions[i].description;

                    }
                    return "";
                }
                color: root.textSecondary
                font.family: root.fontFamily
                font.pixelSize: 14
                lineHeight: 1.5
                wrapMode: Text.WordWrap
            }

            Row {
                x: 32
                y: 174
                spacing: 12

                Rectangle {
                    id: cancelPowerButton

                    width: 112
                    height: 40
                    radius: 20
                    color: cancelMouse.containsMouse ? root.selectedColor : root.fieldHoverColor
                    border.width: activeFocus ? 1 : 0
                    border.color: root.accentColor
                    activeFocusOnTab: true
                    Accessible.name: "取消"
                    Accessible.role: Accessible.Button
                    KeyNavigation.tab: confirmPowerButton
                    KeyNavigation.backtab: confirmPowerButton
                    Keys.onEscapePressed: root.pendingPowerAction = ""
                    Keys.onSpacePressed: root.pendingPowerAction = ""
                    Keys.onReturnPressed: root.pendingPowerAction = ""
                    Keys.onEnterPressed: root.pendingPowerAction = ""

                    Text {
                        anchors.centerIn: parent
                        text: "取消"
                        color: root.textPrimary
                        font.family: root.fontFamily
                        font.pixelSize: 14
                    }

                    MouseArea {
                        id: cancelMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.pendingPowerAction = ""
                    }

                }

                Rectangle {
                    id: confirmPowerButton

                    width: 128
                    height: 40
                    radius: 20
                    color: confirmMouse.containsMouse ? root.accentStrongColor : root.accentColor
                    border.width: activeFocus ? 1 : 0
                    border.color: root.textPrimary
                    activeFocusOnTab: true
                    Accessible.name: "继续"
                    Accessible.role: Accessible.Button
                    KeyNavigation.tab: cancelPowerButton
                    KeyNavigation.backtab: cancelPowerButton
                    Keys.onSpacePressed: root.executePowerAction()
                    Keys.onReturnPressed: root.executePowerAction()
                    Keys.onEnterPressed: root.executePowerAction()

                    Text {
                        anchors.centerIn: parent
                        text: "继续"
                        color: root.inkColor
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: confirmMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.executePowerAction()
                    }

                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Timer {
        interval: 80
        running: true
        repeat: false
        onTriggered: root.initialize()
    }

    Connections {
        function onLoginSucceeded() {
            root.loginPending = false;
            root.statusIsError = false;
            root.statusMessage = "登录成功。";
        }

        function onLoginFailed() {
            root.loginPending = false;
            root.statusIsError = true;
            root.statusMessage = "登录失败，请检查密码后重试。";
            passwordField.text = "";
            passwordField.forceActiveFocus();
        }

        function onInformationMessage(message) {
            root.loginPending = false;
            root.statusIsError = true;
            root.statusMessage = message;
        }

        target: sddm
    }

}
