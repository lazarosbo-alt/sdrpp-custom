# Contributing to SDR++ Community Edition 🚀

**Code contributions ARE ENTHUSIASTICALLY WELCOME!** 🎉

SDR++ Community Edition thrives on community contributions. Whether you're fixing bugs, adding features, improving documentation, or enhancing the user experience - **your contribution matters**.

## 🤝 How to Contribute

### Code Contributions
We actively encourage all types of code contributions:

- **🐛 Bug fixes** - Help make SDR++ more stable
- **✨ New features** - Implement user-requested functionality  
- **🔧 Performance improvements** - Optimize existing code
- **📚 Documentation** - Improve guides and code comments
- **🎨 UI/UX enhancements** - Make the interface better
- **🔌 New modules** - Extend SDR++ capabilities
- **🧪 Tests** - Improve code reliability

### Contribution Process

1. **Fork the repository** to your GitHub account
2. **Create a feature branch** with a descriptive name:
   ```bash
   git checkout -b feature/mpx-analysis
   git checkout -b fix/audio-crash
   git checkout -b docs/contributing-guide
   ```
3. **Make your changes** with clear, documented code
4. **Test thoroughly** to ensure nothing breaks
5. **Submit a pull request** with:
   - Clear description of what the PR does
   - Why the change is needed
   - How to test the changes
   - Any breaking changes (if applicable)

### 🌟 What We Look For

**Quality over perfection** - We welcome contributions from beginners to experts:

- **Clean, readable code** following existing style
- **Proper error handling** where appropriate
- **Documentation** for new features
- **Backward compatibility** when possible
- **Testing** for critical functionality

### 💡 Getting Started

**New to SDR++ development?** Great! Here are some ways to start:

- **Fix typos** in documentation or comments
- **Improve error messages** to be more helpful
- **Add missing tooltips** to UI elements
- **Enhance existing modules** with small improvements
- **Write tests** for existing functionality

**Experienced developer?** We'd love your help with:

- **New DSP algorithms** and demodulators
- **Performance optimizations** for heavy processing
- **Cross-platform compatibility** improvements
- **New hardware support** through source modules
- **Advanced features** like the MPX analysis system

### 🎯 Areas of Interest

Current community priorities include:

- **Audio processing improvements**
- **Enhanced demodulators** for various protocols
- **Better visualization tools** for signal analysis
- **Mobile/tablet UI optimizations**
- **Plugin architecture enhancements**
- **Hardware integration** for new SDR devices
- **Protocol decoders** for digital modes

### 🔄 Review Process

All contributions go through a **fair and transparent** review process:

1. **Automated checks** - CI/CD pipeline runs tests
2. **Code review** - Maintainers and community members review
3. **Discussion** - Open dialogue about improvements
4. **Iteration** - Collaborative refinement
5. **Merge** - Integration into the main codebase

**We believe in:**
- ✅ **Constructive feedback** rather than rejection
- ✅ **Helping contributors improve** their submissions
- ✅ **Recognizing all contributions** regardless of size
- ✅ **Fast response times** to PRs and issues

---

## 📚 Technical Documentation

### Band Frequency Allocation 

Please follow this guide to properly format the JSON files for custom radio band allocation identifiers.

```json
{
    "name": "Short name (has to fit in the menu)",
    "country_name": "Name of country or area, if applicable (Use '--' otherwise)",
    "country_code": "Two letter country code, if applicable (Use '--' otherwise)",
    "author_name": "Name of the original/main creator of the JSON file",
    "author_url": "URL the author wishes to be associated with the file (personal website, GitHub, Twitter, etc)",
    "bands": [ 
        // Bands in this array must be sorted by their starting frequency
        {
            "name": "Name of the band",
            "type": "Type name ('amateur', 'broadcast', 'marine', 'military', or any type declared in config.json)",
            "start": 148500, //In Hz, must be an integer
            "end": 283500 //In Hz, must be an integer
        },
        {
            "name": "Name of the band",
            "type": "Type name ('amateur', 'broadcast', 'marine', 'military', or any type declared in config.json)",
            "start": 526500, //In Hz, must be an integer
            "end": 1606500 //In Hz, must be an integer
        }    
    ]
}
```

### Color Maps

Please follow this guide to properly format the JSON files for custom color maps.

```json
{
    "name": "Short name (has to fit in the menu)",
    "author": "Name of the original/main creator of the color map",
    "map": [
        // These are the color codes, in hexadecimal (#RRGGBB) format, for the custom color scales for the waterfall. They must be entered as strings, not integers, with the hashtag/pound-symbol proceeding the 6 digit number. 
        "#000020",
        "#000030",
        "#000050",
        "#000091",
        "#1E90FF",
        "#FFFFFF",
        "#FFFF00",
        "#FE6D16",
        "#FE6D16",
        "#FF0000",
        "#FF0000",
        "#C60000",
        "#9F0000",
        "#750000",
        "#4A0000"
    ]
}
```

### JSON Formatting

The ability to add new radio band allocation identifiers and color maps relies on JSON files. Proper formatting of these JSON files is important for reference and readability. The following guides will show you how to properly format the JSON files for their respective uses.

**IMPORTANT: JSON File cannot contain comments, they are only in this example for clarity**

---

## 🚀 Recent Community Contributions

### Scanner Module Enhancements

The Scanner module has been enhanced with several new features including frequency blacklisting, settings persistence, and improved frequency wrapping. These enhancements improve the user experience and make the scanner more robust for real-world usage scenarios.

**Recent Scanner Features Added:**
- **Frequency Blacklist**: Skip unwanted frequencies with configurable tolerance
- **Settings Persistence**: Automatic saving/loading of all scanner configuration
- **Reset Functionality**: Return to start frequency at any time
- **Improved Frequency Wrapping**: Better handling of frequency range boundaries
- **Enhanced UI**: Better user interface with status information

### MPX Analysis System

Community-contributed comprehensive MPX analysis for FM broadcasting:
- **Real-time frequency spectrum analysis** (0-100 kHz)
- **Configurable visualization settings** (line width, smoothing, refresh rate)
- **Professional frequency band markers** for MONO, STEREO, RDS, SCA signals
- **Thread-safe implementation** that doesn't block audio processing
- **Persistent configuration** with proper schema integration

---

## 💬 Community & Support

**Need help getting started?**
- 📖 Check existing code for examples and patterns
- 💬 Open a discussion for questions about architecture
- 🐛 File an issue for bugs or feature requests
- 🤝 Join the community conversations in pull requests

**Remember:** Every expert was once a beginner. We're here to help you grow as a contributor!

---

## 🎉 Recognition

All contributors are recognized in our project documentation. Whether you fix a typo or implement a major feature, **your contribution matters** and will be acknowledged.

**Thank you for making SDR++ Community Edition better for everyone!** 🌟

---

*This Community Edition exists because we believe in the power of open collaboration. Together, we can build amazing software that serves the entire SDR community.*