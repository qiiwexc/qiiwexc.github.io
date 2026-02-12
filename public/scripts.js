let systemVersion = "Unknown Operating System";
let systemArchitecture = "32-bit";

if (navigator.userAgentData) {
  const platform = navigator.userAgentData.platform || "";
  if (platform === "Windows") {
    systemVersion = "Windows";
    navigator.userAgentData
      .getHighEntropyValues(["platformVersion", "architecture", "bitness"])
      .then((ua) => {
        const major = parseInt(ua.platformVersion.split(".")[0]);
        if (major >= 13) {
          systemVersion = "Windows 11";
        } else if (major > 0) {
          systemVersion = "Windows 10";
        }
        systemArchitecture =
          ua.architecture === "x86" && ua.bitness === "64"
            ? "64-bit"
            : ua.bitness === "64"
              ? "64-bit"
              : "32-bit";
        updateVersionElement();
      });
  }
} else {
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

  systemArchitecture = ["Win64", "x64", "WOW64"].some((str) =>
    navigator.userAgent.includes(str),
  )
    ? "64-bit"
    : "32-bit";
}

let systemLanguage = navigator.language.split("-").at(0) ?? "en";

function updateVersionElement() {
  let versionElement = document
    .getElementsByTagName("header")
    .item(0)
    ?.getElementsByTagName("p")
    .item(0);

  if (versionElement) {
    versionElement.innerHTML =
      systemVersion + " " + systemArchitecture + " " + systemLanguage;
  }
}

updateVersionElement();
