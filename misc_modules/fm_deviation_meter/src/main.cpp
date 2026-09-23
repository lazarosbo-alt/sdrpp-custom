#include <gui/gui.h>
#include <module.h>
#include <gui/style.h>
#include "fmdev_dsp.h"

class FMDeviationMeterModule : public Module {
public:
    FMDeviationMeterModule(std::string name) {
        _name = name;
        _dsp.init(48000.0);
    }

    ~FMDeviationMeterModule() {}

    void menu() {
        ImGui::Begin("FM Deviation Meter (SM.1268)");
        
        ImGui::Text("Status: Active");
        ImGui::Separator();

        ImGui::Text("Peak Deviation:   %.2f kHz", _dsp.getPeakDeviationKhz());
        ImGui::Text("MPX Power (BS.412): %.2f dBr", _dsp.getMPXPowerDBr());
        ImGui::Text("Samples > 77kHz:  %.4f %%", _dsp.getExcessPercentage());

        ImGui::Spacing();
        if (ImGui::Button("Reset Statistics")) {
            _dsp.reset();
        }
        ImGui::SameLine();
        if (ImGui::Button("Export to CSV")) {
            _dsp.exportCSV("fm_deviation_report.csv");
        }

        ImGui::End();
    }

private:
    std::string _name;
    FMDeviationMeterDSP _dsp;
};

Info moduleInfo = {
    "fm_deviation_meter",
    "FM Deviation Meter (ITU-R SM.1268)",
    "Author",
    1,
    0
};

MOD_EXPORT void* _INIT(char* path) {
    json::add_type("fm_deviation_meter");
    return new FMDeviationMeterModule(path);
}

MOD_EXPORT void _DEINIT(void* handle) {
    delete (FMDeviationMeterModule*)handle;
}