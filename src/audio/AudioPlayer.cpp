#include "AudioPlayer.h"
#include "pins.h"

#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>
#include <Audio.h>

//#define SINE_WAVE_TEST

AudioSynthWaveformSine sineWav;
AudioPlaySdWav      playWav;

AudioMixer4         mixer;
AudioOutputAnalog   dac;
#ifdef SINE_WAVE_TEST
AudioConnection     patchCord1(sineWav, mixer);
#else
AudioConnection     patchCord1(playWav, mixer);
#endif
AudioConnection     patchCord2(mixer, 0, dac, 0);

AudioPlayer::AudioPlayer() {
  m_startPlayingTime = 0;
  m_muted = false;
  m_shutdown = false;
  m_volume = 1;
  pinMode(PIN_AMP_SHUTDOWN, INPUT);
}

void AudioPlayer::init() {
  // Audio connections require memory to work.  For more
  // detailed information, see the MemoryAndCpuUsage example
  AudioMemory(8);

  SPI.setMOSI(PIN_SDCARD_MOSI);
  SPI.setSCK(PIN_SDCARD_SCK);
  if (!(SD.begin(PIN_SDCARD_CS))) {
    // stop here, but print a message repetitively
    while (1) {
      Serial.println("Unable to access the SD card");
      delay(500);
    }
  }
#ifdef SINE_WAVE_TEST
  sineWav.amplitude(1.0);
  sineWav.frequency(440);
#endif
}

void AudioPlayer::play(const char* filename) 
{
  playWav.play(filename);
  
  Serial.print("AudioPlayer::play: "); Serial.println(filename);// Serial.print(" len(ms)="); Serial.println(playWav.lengthMillis());
  // remember, about a 5ms warmup for header to be loaded and start playing.
  m_startPlayingTime = millis();
}

void AudioPlayer::stop() {
#ifndef SINE_WAVE_TEST
  playWav.stop();
#endif
}

bool AudioPlayer::isPlaying() const {
  uint32_t currentTime = millis();
  uint32_t warmTime = m_startPlayingTime + 20u;  // PJRC uses a 5ms time. Can be generous; no reason to support sub-second samples.
  if (m_startPlayingTime && currentTime > warmTime) {
#ifdef SINE_WAVE_TEST
  return true;
#else
    return playWav.isPlaying();
#endif
  }
  return true;
}

void AudioPlayer::setShutdown() {
  bool shouldBeShutdown = m_muted;

  if (shouldBeShutdown && !m_shutdown) {
    digitalWrite(PIN_AMP_SHUTDOWN, LOW);
    pinMode(PIN_AMP_SHUTDOWN, OUTPUT);
  }
  else if (!shouldBeShutdown && m_shutdown) {
    pinMode(PIN_AMP_SHUTDOWN, INPUT);
  }
  m_shutdown = shouldBeShutdown;
}

void AudioPlayer::mute(bool m) {
  m_muted = m;
  setShutdown();
}

void AudioPlayer::setVolume(float v) {
  m_volume = v;
  mixer.gain(0, m_volume);
}

