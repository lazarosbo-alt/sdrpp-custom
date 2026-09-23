#pragma once
#include <vector>
#include <cmath>
#include <algorithm>
#include <fstream>

class FMDeviationMeterDSP {
public:
    void init(double sampleRate) {
        m_sampleRate = sampleRate;
        reset();
    }

    void reset() {
        m_totalSamples = 0;
        m_samplesAbove77k = 0;
        m_mpxPowerSum = 0.0;
        m_mpxCount = 0;
        m_maxDeviation = 0.0;
    }

    void process(const float* audioData, int numSamples) {
        for (int i = 0; i < numSamples; ++i) {
            float deviationHz = std::abs(audioData[i]); // Απόκλιση σε Hz από τον αποδημοσιοποιητή

            if (deviationHz > m_maxDeviation) {
                m_maxDeviation = deviationHz;
            }

            m_totalSamples++;
            if (deviationHz > 77000.0f) { // 75 kHz + 2 kHz αβεβαιότητα (SM.1268)
                m_samplesAbove77k++;
            }

            m_mpxPowerSum += (double)deviationHz * (double)deviationHz;
            m_mpxCount++;
        }
    }

    double getPeakDeviationKhz() const {
        return m_maxDeviation / 1000.0;
    }

    double getMPXPowerDBr() const {
        if (m_mpxCount == 0) return 0.0;
        double meanSquare = m_mpxPowerSum / m_mpxCount;
        double refSquare = 75000.0 * 75000.0; // Reference 75 kHz deviation
        return 10.0 * std::log10(meanSquare / refSquare);
    }

    double getExcessPercentage() const {
        if (m_totalSamples == 0) return 0.0;
        return ((double)m_samplesAbove77k / (double)m_totalSamples) * 100.0;
    }

    void exportCSV(const std::string& filename) {
        std::ofstream file(filename);
        if (!file.is_open()) return;
        file << "Metric,Value\n";
        file << "Peak Deviation (kHz)," << getPeakDeviationKhz() << "\n";
        file << "MPX Power (dBr)," << getMPXPowerDBr() << "\n";
        file << "Exceeding 77kHz (%)," << getExcessPercentage() << "\n";
        file.close();
    }

private:
    double m_sampleRate = 0.0;
    long long m_totalSamples = 0;
    long long m_samplesAbove77k = 0;
    double m_mpxPowerSum = 0.0;
    long long m_mpxCount = 0;
    float m_maxDeviation = 0.0;
};