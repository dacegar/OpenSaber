#ifndef SKETCHER_INCLUDED
#define SKETCHER_INCLUDED

#include <stdint.h>
#include "renderer.h"
#include "DotStar.h"
#include "Grinliz_Util.h"
#include "saberUtil.h"

struct UIRenderData
{
    uint8_t power	= 0;
    uint8_t volume  = 0;
    uint8_t palette = 0;
	uint32_t mVolts = 0;
	uint32_t meditationTimeRemain = 0;
    const char* fontName = 0;
	RGB color;

    UIRenderData() {}
};

class DotStarUI
{
public:
    void Draw(RGB* uiLedStart, UIMode mode, bool bladeIgnited, const UIRenderData& data);

	void SetBrightness(uint16_t v) { m_brightness = v; }
	uint16_t Brightness() const { return m_brightness; }

	static bool Test();

private:
	uint16_t m_brightness = 256;
};

class Sketcher
{
public:
	enum {
		WIDTH = 128,
		HEIGHT = 32,

		TWEAK_X0    = 0, //2,
		TWEAK_X1    = 0,
		X0			= 0 + TWEAK_X0,
		X1			= WIDTH - TWEAK_X1,
		CENTER		= (X0 + X1) / 2,

        DIAL_WIDTH = 28,
		DATA_WIDTH	= WIDTH - DIAL_WIDTH * 2 - 20,
		BAR_WIDTH   = 38 - TWEAK_X0 - TWEAK_X1,
    };

    Sketcher();
    void Draw(Renderer* d, uint32_t time, UIMode mode, bool bladeIgnited, const UIRenderData* data);
    void Push(uint8_t value);

private:
    textureData GetDial(int value);

	void DrawBladeMode(Renderer* d, uint32_t time, bool ignited, const UIRenderData* data);
	void DrawPaletteMode(Renderer* d, uint32_t time, const UIRenderData* data);
	void DrawVolumeMode(Renderer* d, uint32_t time, const UIRenderData* data);
	void DrawMeditationMode(Renderer* d, uint32_t time, const UIRenderData* data);

	void DrawDials(Renderer* d, const UIRenderData* data, bool labels=true);
	void DrawStateDisplay(Renderer* d, const UIRenderData* data);

    uint8_t  line = 0;
    uint8_t  pos = 0;
    uint32_t animTime = 0;
	uint8_t  accelData[DATA_WIDTH];
};

void calcCrystalColor(uint32_t msec, int32_t lowVariation, int32_t highVariation, const RGB& base, RGB* out);

bool TestCrystalColor();

#endif // SKETCHER_INCLUDED
