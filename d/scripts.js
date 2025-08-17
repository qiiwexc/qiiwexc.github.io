let systemVersion = "Unknown Operating System";

if (navigator.userAgent.includes("Windows NT 10.0")) {
  systemVersion = "Windows 10/11";
} else if (navigator.userAgent.includes("Windows NT 6.4")) {
  systemVersion = "Windows 10";
} else if (navigator.userAgent.includes("Windows NT 6.3")) {
  systemVersion = "Windows 8.1";
} else if (navigator.userAgent.includes("Windows NT 6.2")) {
  systemVersion = "Windows 8";
} else if (navigator.userAgent.includes("Windows NT 6.1")) {
  systemVersion = "Windows 7";
} else if (navigator.userAgent.includes("Windows NT 6.0")) {
  systemVersion = "Windows Vista";
} else if (navigator.userAgent.includes("Windows NT 5.2")) {
  systemVersion = "Windows XP";
} else if (navigator.userAgent.includes("Windows NT 5.1")) {
  systemVersion = "Windows XP";
} else if (navigator.userAgent.includes("Windows NT 5.0")) {
  systemVersion = "Windows 2000";
} else if (navigator.userAgent.includes("Windows NT 4.0")) {
  systemVersion = "Windows NT";
}

let systemArchitecture = ["Win64", "x64", "WOW64"].some((str) =>
  navigator.userAgent.includes(str)
)
  ? "64-bit"
  : "32-bit";

let systemLanguage = navigator.language.split("-").at(0) ?? "en";

let versionElement = document
  .getElementsByTagName("header")
  .item(0)
  ?.getElementsByTagName("p")
  .item(0);

if (versionElement) {
  versionElement.innerHTML =
    systemVersion + " " + systemArchitecture + " " + systemLanguage;
}
