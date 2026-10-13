import type { CapacitorConfig } from "@capacitor/cli";
import { KeyboardResize } from "@capacitor/keyboard";
const config: CapacitorConfig = {
  appId: "com.vehiclecare.app",
  appName: "VehicleCare",
  webDir: "dist",
  server: {
    hostname: "localhost",
    androidScheme: "https",
    iosScheme: "capacitor",
    cleartext: false,
  },
  android: { allowMixedContent: false, webContentsDebuggingEnabled: false },
  ios: { contentInset: "never" },
  plugins: {
    SplashScreen: {
      launchAutoHide: false,
      launchShowDuration: 0,
      backgroundColor: "#F8FAFC",
      androidScaleType: "CENTER_INSIDE",
      showSpinner: false,
    },
    Keyboard: { resize: KeyboardResize.Native, resizeOnFullScreen: true },
    StatusBar: { overlaysWebView: true },
    SystemBars: { insetsHandling: "css" },
    LocalNotifications: {
      smallIcon: "ic_stat_vehiclecare",
      iconColor: "#0D9488",
      presentationOptions: ["badge", "sound", "banner", "list"],
    },
  },
};
export default config;
