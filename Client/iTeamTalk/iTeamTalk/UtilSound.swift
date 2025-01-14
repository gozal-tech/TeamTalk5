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

import Foundation
import AVFoundation

func refVolume(_ percent: Double) -> Int {
    //82.832*EXP(0.0508*x) - 50
    if percent == 0 {
        return 0
    }
    
    let d = 82.832 * exp(0.0508 * percent) - 50
    return Int(d)
}

func refVolumeToPercent(_ volume: Int) -> Int {
    if(volume == 0) {
        return 0
    }
    
    let d = (Double(volume) + 50.0) / 82.832
    let d1 = (log(d) / 0.0508) + 0.5
    return Int(d1)
}

enum Sounds : Int {
    case tx_ON = 1,
         tx_OFF = 2,
         chan_MSG = 3,
         broadcast_MSG = 4,
         user_MSG = 5,
         srv_LOST = 6,
         joined_CHAN = 7,
         left_CHAN = 8,
         voxtriggered_ON = 9,
         voxtriggered_OFF = 10,
         transmit_ON = 11,
         transmit_OFF = 12,
         logged_IN = 13,
         logged_OUT = 14
}

var player : AVAudioPlayer?

func getSoundFile(_ s: Sounds) -> String? {
    
    let settings = UserDefaults.standard
    
    switch s {
    case .tx_ON:
        if settings.object(forKey: PREF_SNDEVENT_VOICETX) == nil ||
           settings.bool(forKey: PREF_SNDEVENT_VOICETX) {
            return "on"
        }
    case .tx_OFF:
        if settings.object(forKey: PREF_SNDEVENT_VOICETX) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_VOICETX) {
                return "off"
        }
    case .chan_MSG:
        if settings.object(forKey: PREF_SNDEVENT_CHANMSG) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_CHANMSG) {
                return "channel_message"
        }
    case .user_MSG:
        if settings.object(forKey: PREF_SNDEVENT_USERMSG) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_USERMSG) {
                return "user_message"
        }
    case .broadcast_MSG:
        if settings.object(forKey: PREF_SNDEVENT_BCASTMSG) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_BCASTMSG) {
            return "broadcast_message"
        }
    case .srv_LOST:
        if settings.object(forKey: PREF_SNDEVENT_SERVERLOST) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_SERVERLOST) {
                return "serverlost"
        }
    case .joined_CHAN:
        if settings.object(forKey: PREF_SNDEVENT_JOINEDCHAN) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_JOINEDCHAN) {
                return "newuser"
        }
    case .left_CHAN:
        if settings.object(forKey: PREF_SNDEVENT_LEFTCHAN) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_LEFTCHAN) {
                return "removeuser"
        }
    case .voxtriggered_ON :
        if settings.object(forKey: PREF_SNDEVENT_VOXTRIGGER) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_VOXTRIGGER) {
            return "voiceact_on"
        }
    case .voxtriggered_OFF :
        if settings.object(forKey: PREF_SNDEVENT_VOXTRIGGER) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_VOXTRIGGER) {
            return "voiceact_off"
        }
    case .transmit_ON :
        if settings.object(forKey: PREF_SNDEVENT_TRANSMITREADY) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_TRANSMITREADY) {
            return "txqueue_start"
        }
    case .transmit_OFF :
        if settings.object(forKey: PREF_SNDEVENT_TRANSMITREADY) == nil ||
            settings.bool(forKey: PREF_SNDEVENT_TRANSMITREADY) {
            return "txqueue_stop"
        }
    case .logged_IN :
        if settings.object(forKey: PREF_SNDEVENT_LOGGEDIN) != nil &&
            settings.bool(forKey: PREF_SNDEVENT_LOGGEDIN) {
            return "logged_on"
        }
    case .logged_OUT :
        if settings.object(forKey: PREF_SNDEVENT_LOGGEDOUT) != nil &&
            settings.bool(forKey: PREF_SNDEVENT_LOGGEDOUT) {
            return "logged_off"
        }
    }

    return nil
}

func setupSoundDevices() {
    
    do {
        let session = AVAudioSession.sharedInstance()

        print("preset: " + session.mode.rawValue)
        
        let defaults = UserDefaults.standard
        let preprocess = defaults.object(forKey: PREF_VOICEPROCESSINGIO) != nil && defaults.bool(forKey: PREF_VOICEPROCESSINGIO)
        let speaker = defaults.object(forKey: PREF_SPEAKER_OUTPUT) != nil && defaults.bool(forKey: PREF_SPEAKER_OUTPUT)
        
        TT_CloseSoundInputDevice(ttInst)
        TT_CloseSoundOutputDevice(ttInst)
        
        let mode = preprocess ? AVAudioSession.Mode.voiceChat : AVAudioSession.Mode.default
        
        if #available(iOS 10.0, *) {
            if speaker {
                try session.setCategory(.playAndRecord, mode: mode, options: [.mixWithOthers, .defaultToSpeaker])
            }
            else {
                try session.setCategory(.playAndRecord, mode: mode, options: [.mixWithOthers, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
            }
        }
        else {
            let catoptions = speaker ? AVAudioSession.CategoryOptions.defaultToSpeaker : AVAudioSession.CategoryOptions.allowBluetooth
            try session.setMode(mode)
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: catoptions)
        }
        
        let sndid = speaker && preprocess ? TT_SOUNDDEVICE_ID_VOICEPREPROCESSINGIO : TT_SOUNDDEVICE_ID_REMOTEIO
        if TT_InitSoundInputDevice(ttInst, sndid) == FALSE {
            print("Failed to initialize sound input device: \(sndid)")
        }
        else {
            print("Using sound input device: \(sndid)")
        }
        if TT_InitSoundOutputDevice(ttInst, sndid) == FALSE {
            print("Failed to initialize sound output device: \(sndid)")
        }
        else {
            print("Using sound output device: \(sndid)")
        }
        print("postset. Mode \(session.mode.rawValue), category \(session.category.rawValue), options \(session.categoryOptions.rawValue)")
        
        print (session.currentRoute)

        // enable stereo on all data sources that support it
        if #available(iOS 14.0, *) {
            if let availableInputs = session.availableInputs {
                for i in availableInputs {
                    if let dataSources = i.dataSources {
                        for s in dataSources {
                            if s.supportedPolarPatterns != nil && s.supportedPolarPatterns!.contains(.stereo) {
                                try s.setPreferredPolarPattern(.stereo)
                                print("Setting \(s.dataSourceName) to stereo")
                            } else {
                                print("No stereo on \(s.dataSourceName)")
                            }
                        }
                    }
                }
            }
        }

    }
    catch {
        print("Failed to set mode")
    }
}

func playSound(_ s: Sounds) {
    
    let filename = getSoundFile(s)
    
    if filename == nil {
        return
    }
    
    if let resPath = Bundle.main.path(forResource: filename, ofType: "mp3") {
        
        let url = URL(fileURLWithPath: resPath)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player!.prepareToPlay()
            player!.play()
        }
        catch {
            print("Failed to play")
        }
    }
}

