# MPX Analyzer Module for SDR++

## Overview

The MPX (Multiplex) Analyzer is a powerful tool for analyzing FM broadcast signals in real-time. It provides comprehensive visualization and analysis of the FM multiplex signal, including pilot tone detection, RDS signal analysis, and stereo separation measurement.

## What is MPX?

FM multiplex (MPX) is the composite signal that contains:
- **Left + Right Audio** (L+R) - Mono audio signal
- **Left - Right Audio** (L-R) - Stereo difference signal  
- **Pilot Tone** (19 kHz) - Stereo synchronization signal
- **RDS Data** (57 kHz) - Radio Data System information
- **SCA** (67 kHz) - Subsidiary Communications Authorization

## Features

### 🎯 **Real-time MPX Analysis**
- **Live FFT Spectrum** from SDR++ waterfall
- **Pilot Tone Detection** at 19 kHz
- **RDS Signal Analysis** at 57 kHz
- **Stereo Separation** calculation
- **Configurable FFT Size** (512 to 8192)

### 📊 **Visualization Components**
- **MPX Spectrum Display** - Real-time frequency spectrum
- **MPX Waterfall** - Time-frequency waterfall visualization
- **Pilot Tone Indicator** - Visual pilot tone status
- **RDS Signal Indicator** - Visual RDS detection status

### ⚙️ **User Controls**
- **Show/Hide Components** - Toggle individual displays
- **FFT Size Adjustment** - Optimize for your system
- **Waterfall Height** - Customize visualization size

## Installation

### Building from Source
```bash
# Navigate to SDR++ source directory
cd SDRPlusPlus

# Create build directory
mkdir build && cd build

# Configure with MPX analyzer enabled
cmake .. -DOPT_BUILD_MPX_ANALYZER=ON

# Build the module
make mpx_analyzer

# Copy to modules directory
cp misc_modules/mpx_analyzer/mpx_analyzer.dylib /path/to/sdrpp/modules/
```

### Module Loading
1. **Start SDR++**
2. **Open Module Manager** (Tools → Module Manager)
3. **Add MPX Analyzer** instance
4. **Enable the module**

## Usage Guide

### Basic Operation
1. **Tune to FM Station** - Set your SDR to an FM broadcast frequency
2. **Open MPX Analyzer** - Access via the module menu
3. **Observe Real-time Data** - Watch the spectrum and indicators update

### Understanding the Display

#### MPX Spectrum
- **X-axis**: Frequency (0 Hz to 96 kHz)
- **Y-axis**: Signal magnitude
- **Key Frequencies**:
  - **0-15 kHz**: L+R audio (mono)
  - **19 kHz**: Pilot tone (stereo sync)
  - **23-53 kHz**: L-R audio (stereo)
  - **57 kHz**: RDS data carrier
  - **67+ kHz**: SCA signals

#### Pilot Tone Analysis
- **Green Indicator**: Pilot tone detected (stereo available)
- **Red Indicator**: No pilot tone (mono only)
- **Level Display**: Signal strength in dB

#### RDS Analysis
- **Green Indicator**: RDS signal detected
- **Red Indicator**: No RDS signal
- **Level Display**: RDS carrier strength

#### Stereo Separation
- **Percentage Display**: Stereo separation quality
- **Higher Values**: Better stereo separation
- **Lower Values**: Poor stereo or mono signal

### Advanced Features

#### FFT Size Optimization
- **Smaller FFT (512-1024)**: Faster updates, lower resolution
- **Medium FFT (2048)**: Balanced performance (default)
- **Larger FFT (4096-8192)**: Higher resolution, slower updates

#### Waterfall Visualization
- **Real-time Updates**: 20 Hz refresh rate
- **Frequency Scale**: 0 Hz to 96 kHz display
- **Color Intensity**: Signal strength representation

## Technical Details

### Signal Processing
- **FFT Source**: Uses SDR++ waterfall FFT data
- **Update Rate**: 20 Hz (50ms intervals)
- **Frequency Range**: 0-96 kHz (MPX bandwidth)
- **Threading**: Separate worker thread for processing

### Detection Algorithms
- **Pilot Tone**: Peak detection at 19 kHz
- **RDS Signal**: Peak detection at 57 kHz
- **Stereo Separation**: Pilot tone level analysis

### Performance Characteristics
- **CPU Usage**: Low (uses existing waterfall FFT)
- **Memory Usage**: Minimal (spectrum buffer only)
- **Latency**: <50ms (real-time operation)

## Troubleshooting

### Common Issues

#### No MPX Data Displayed
- **Check SDR Tuning**: Ensure you're tuned to an FM station
- **Verify Module**: Confirm MPX analyzer is enabled
- **Check Waterfall**: Ensure waterfall is active and showing data

#### Poor Signal Quality
- **Antenna**: Check antenna connection and positioning
- **Gain Settings**: Adjust SDR gain for optimal signal
- **Frequency**: Ensure you're on a strong FM station

#### High CPU Usage
- **Reduce FFT Size**: Use smaller FFT sizes
- **Disable Waterfall**: Turn off waterfall if not needed
- **Update Rate**: Module automatically optimizes processing

### Performance Tips
- **Use 2048 FFT** for best balance of performance and resolution
- **Disable unused displays** to reduce rendering overhead
- **Tune to strong stations** for best analysis results

## Applications

### Broadcast Engineering
- **Signal Quality Monitoring** - Real-time FM signal analysis
- **Stereo Separation Testing** - Verify broadcast quality
- **RDS Verification** - Confirm RDS data transmission

### Amateur Radio
- **FM Signal Analysis** - Study FM modulation characteristics
- **Equipment Testing** - Test FM transmitters and receivers
- **Learning Tool** - Understand FM multiplex theory

### Research & Education
- **Signal Processing** - Study real-time FFT analysis
- **FM Technology** - Learn about broadcast FM systems
- **SDR Applications** - Explore software-defined radio capabilities

## Future Enhancements

### Planned Features
- **RDS Decoding** - Actual RDS data extraction
- **Audio Demodulation** - L+R and L-R audio output
- **SCA Detection** - Subsidiary signal analysis
- **Signal Recording** - MPX signal capture and playback

### Potential Improvements
- **Advanced Filtering** - Customizable frequency filters
- **Statistical Analysis** - Signal quality metrics over time
- **Export Functions** - Save analysis data and screenshots
- **Integration** - Better integration with other SDR++ modules

## Support & Development

### Reporting Issues
- **GitHub Issues**: Report bugs and feature requests
- **Community**: Ask questions on SDR++ Discord/forums
- **Documentation**: Check this README for usage information

### Contributing
- **Code Contributions**: Submit pull requests to the enhanced fork
- **Documentation**: Help improve this documentation
- **Testing**: Test on different hardware and signal conditions

## License

The MPX Analyzer module is part of the enhanced SDR++ project and follows the same licensing terms as the main SDR++ project.

---

**Author**: Miguel Gomes  
**Version**: 1.0.0  
**Last Updated**: 22nd August 2025  
**SDR++ Version**: Tested with SDR++ v1.2.1+


