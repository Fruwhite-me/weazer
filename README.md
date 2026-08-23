# Weazer
##### CLI app that fetches weather from [Open-Meteo](https://open-meteo.com/), written in **Zig**⚡(currently in beta)
#### (*This is my first project*)

### Configuration:
1. Start the app once
2. Go to https://open-meteo.com/en/docs
3. Choose in current: Temperature (2 m), Wind Speed (10 m), Precipitation
4. Choose your city and units
5. Copy API URL 
6. Paste url at ` ~/.config/weazer/config.json ` (or your ` $XDG_CONFIG_HOME `) in the field `"source"`
7. Done!!!
### Build for yourself:
##### Requirements:
- Zig version: 0.13.0

##### Build for development:
```bash
git clone https://github.com/Fruwhite-me/weazer.git
cd weazer
zig build
```

#### Build for daily usage:

```bash
git clone https://github.com/Fruwhite-me/weazer.git
cd weazer
zig build -Doptimize=ReleaseSafe
mv zig-out/bin/weazer ~/.local/bin/
```

If you prefer a shorter command (optional, but why not?)

```bash
mv zig-out/bin/weazer ~/.local/bin/wz
```

