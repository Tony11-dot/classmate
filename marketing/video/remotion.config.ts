import { Config } from "@remotion/cli/config";

// H.264 MP4 output, high quality.
Config.setVideoImageFormat("jpeg");
Config.setCodec("h264");
Config.setPixelFormat("yuv420p");
// CRF: lower = higher quality / bigger file. 18 is visually lossless-ish.
Config.setCrf(18);
Config.setChromiumOpenGlRenderer("angle");
// Concurrency left on auto. Override per-machine with --concurrency if needed.
Config.setOverwriteOutput(true);
