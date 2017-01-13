#include "AudioPlayer.h"
#include "pins.h"

#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>
#include <Audio.h>

#include "Grinliz_Arduino_Util.h"

AudioPlaySdWav      playWav;
AudioMixer4         mixer;
AudioOutputAnalog   dac;

#if (SFX_FILTER == SFX_FILTER_NONE)
    AudioConnection     patchCord0(playWav, mixer);
    AudioConnection     patchCord2(mixer, 0, dac, 0);
#elif (SFX_FILTER == SFX_FILTER_LOWPASS)
    AudioFilterBiquad   biquad;
    AudioConnection     patchCord0(playWav, biquad);
    AudioConnection     patchCord1(biquad, mixer);
    AudioConnection     patchCord2(mixer, 0, dac, 0);
#else
    #error No SFX_FILTER defined.
#endif

AudioPlayer::AudioPlayer() {
    m_muted = false;
    m_shutdown = false;
    m_startPlayingTime = 0;
    m_volume = 1.0f;

    // Start disabled.
    digitalWrite(PIN_AMP_EN, LOW);
    pinMode(PIN_AMP_EN, OUTPUT);
    digitalWrite(PIN_AMP_EN, LOW);

#if (SFX_FILTER == SFX_FILTER_LOWPASS)
    biquad.setLowpass(0, 4000, 0.707);
#endif
}

void AudioPlayer::init() {
    // Audio connections require memory to work.  For more
    // detailed information, see the MemoryAndCpuUsage example
    AudioMemory(8);
    dac.analogReference(EXTERNAL); // much louder!
    delay(50);  //stabalize
}

void AudioPlayer::play(const char* filename)
{
    bool okay = playWav.play(filename);
    if (!okay) {
        ASSERT(okay);
        Log.p("Error playing:").p(filename).eol();
    }

    //Serial.print("AudioPlayer::play: "); Serial.println(filename);// Serial.print(" len(ms)="); Serial.println(playWav.lengthMillis());
    // remember, about a 5ms warmup for header to be loaded and start playing.
    m_startPlayingTime = millis();
}

void AudioPlayer::stop() {
    playWav.stop();
    // Cool the data xfer
    delay(10);
}

bool AudioPlayer::isPlaying() const {
    uint32_t currentTime = millis();
    uint32_t warmTime = m_startPlayingTime + 20u;  // PJRC uses a 5ms time. Can be generous; no reason to support sub-second samples.
    if (m_startPlayingTime && currentTime > warmTime) {
        return playWav.isPlaying();
    }
    return true;
}

void AudioPlayer::mute(bool m) {
    m_muted = m;

    if (m_muted && !m_shutdown) {
        Log.p("AudioPlayer: amp shutdown.").eol();
        digitalWrite(PIN_AMP_EN, LOW);
    }
    else if (!m_muted && m_shutdown) {
        Log.p(" AudioPlayer: amp enable.").eol();
        digitalWrite(PIN_AMP_EN, HIGH);
        delay(10);  // warm up the amp.
    }
    m_shutdown = m_muted;
}

void AudioPlayer::setVolume(float v) {
    m_volume = v;
    mixer.gain(0, m_volume);
}


uint32_t AudioPlayer::lengthMillis() const
{
    return playWav.lengthMillis();
}
