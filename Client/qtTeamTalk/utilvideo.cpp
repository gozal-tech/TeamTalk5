/*
 * Copyright (c) 2005-2018, BearWare.dk
 * 
 * Contact Information:
 *
 * Bjoern D. Rasmussen
 * Kirketoften 5
 * DK-8260 Viby J
 * Denmark
 * Email: contact@bearware.dk
 * Phone: +45 20 20 54 59
 * Web: http://www.bearware.dk
 *
 * This source code is part of the TeamTalk SDK owned by
 * BearWare.dk. Use of this file, or its compiled unit, requires a
 * TeamTalk SDK License Key issued by BearWare.dk.
 *
 * The TeamTalk SDK License Agreement along with its Terms and
 * Conditions are outlined in the file License.txt included with the
 * TeamTalk SDK distribution.
 *
 */

#include "utilvideo.h"
#include "settings.h"

extern QSettings* ttSettings;
extern TTInstance* ttInst;

bool getVideoCaptureCodec(VideoCodec& vidcodec)
{
    Codec codec = (Codec)ttSettings->value(SETTINGS_VIDCAP_CODEC,
        SETTINGS_VIDCAP_CODEC_DEFAULT).toInt();
    vidcodec.nCodec = codec;

    switch (vidcodec.nCodec)
    {
    case WEBM_VP8_CODEC:
        vidcodec.webm_vp8.nRcTargetBitrate = ttSettings->value(SETTINGS_VIDCAP_WEBMVP8_BITRATE,
            SETTINGS_VIDCAP_WEBMVP8_BITRATE_DEFAULT).toInt();
        vidcodec.webm_vp8.nEncodeDeadline = DEFAULT_WEBMVP8_DEADLINE;
        break;
    case SPEEX_CODEC:
    case SPEEX_VBR_CODEC:
    case OPUS_CODEC:
    case NO_CODEC:
        break;
    }
    return codec != NO_CODEC;
}

void initDefaultVideoFormat(VideoFormat& vidfmt)
{
    vidfmt.nWidth = DEFAULT_VIDEO_WIDTH;
    vidfmt.nHeight = DEFAULT_VIDEO_HEIGHT;
    vidfmt.nFPS_Numerator = DEFAULT_VIDEO_FPS;
    vidfmt.nFPS_Denominator = 1;
    vidfmt.picFourCC = DEFAULT_VIDEO_FOURCC;
}

bool initVideoCaptureFromSettings()
{
    QString devid = ttSettings->value(SETTINGS_VIDCAP_DEVICEID).toString();

    QStringList fps = ttSettings->value(SETTINGS_VIDCAP_FPS, SETTINGS_VIDCAP_FPS_DEFAULT).toString().split("/");
    QStringList res = ttSettings->value(SETTINGS_VIDCAP_RESOLUTION, SETTINGS_VIDCAP_RESOLUTION_DEFAULT).toString().split("x");
    FourCC fourcc = (FourCC)ttSettings->value(SETTINGS_VIDCAP_FOURCC, SETTINGS_VIDCAP_FOURCC_DEFAULT).toInt();

    if (fps.size() == 2 && res.size() == 2)
    {
        VideoFormat format;

        format.nFPS_Numerator = fps[0].toInt();
        format.nFPS_Denominator = fps[1].toInt();
        format.nWidth = res[0].toInt();
        format.nHeight = res[1].toInt();
        format.picFourCC = fourcc;

        return initVideoCapture(devid, format);
    }
    return false;
}

bool initVideoCapture(const QString& devid, const VideoFormat& fmt)
{
    QString use_devid = devid;
    if (use_devid.isEmpty())
    {
        int count = 1;
        QVector<VideoCaptureDevice> devs(1);
        TT_GetVideoCaptureDevices(&devs[0], &count);
        if (count)
            use_devid = _Q(devs[0].szDeviceID);
    }

    return TT_InitVideoCaptureDevice(ttInst, _W(use_devid), &fmt);
}

bool isValid(const VideoFormat& fmt)
{
    return fmt.nWidth > 0 && fmt.nHeight > 0 && fmt.nFPS_Numerator > 0 &&
        fmt.nFPS_Denominator > 0 && fmt.picFourCC != FOURCC_NONE;
}

void saveVideoFormat(const VideoFormat& vidfmt)
{
    QString resolution, fps;
    resolution = QString("%1x%2").arg(vidfmt.nWidth).arg(vidfmt.nHeight);
    fps = QString("%1/%2").arg(vidfmt.nFPS_Numerator).arg(vidfmt.nFPS_Denominator);

    ttSettings->setValue(SETTINGS_VIDCAP_RESOLUTION, resolution);
    ttSettings->setValue(SETTINGS_VIDCAP_FPS, fps);
    ttSettings->setValue(SETTINGS_VIDCAP_FOURCC, (int)vidfmt.picFourCC);
}

bool loadVideoFormat(VideoFormat& vidfmt)
{
    QStringList fps_tokens = ttSettings->value(SETTINGS_VIDCAP_FPS, "0/0").toString().split("/");
    QStringList res_tokens = ttSettings->value(SETTINGS_VIDCAP_RESOLUTION, "0x0").toString().split("x");
    if (fps_tokens.size() == 2 && res_tokens.size() == 2 &&
        fps_tokens[0].toInt() && fps_tokens[1].toInt() &&
        res_tokens[0].toInt() && res_tokens[1].toInt())
    {
        vidfmt.nFPS_Numerator = fps_tokens[0].toInt();
        vidfmt.nFPS_Denominator = fps_tokens[1].toInt();
        vidfmt.nWidth = res_tokens[0].toInt();
        vidfmt.nHeight = res_tokens[1].toInt();
        vidfmt.picFourCC = (FourCC)ttSettings->value(SETTINGS_VIDCAP_FOURCC, 0).toInt();
        return true;
    }
    return false;
}
