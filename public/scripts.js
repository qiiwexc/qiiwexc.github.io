// Plain ES5 (no arrow functions, "let", "includes", "at", "??" or "?."), so the page
// also works in the older browsers still found on the Windows versions it serves
var systemVersion = "Unknown Operating System";
var systemArchitecture = "32-bit";

function userAgentContains(text) {
  return navigator.userAgent.indexOf(text) !== -1;
}

if (navigator.userAgentData) {
  if (navigator.userAgentData.platform === "Windows") {
    systemVersion = "Windows";
    navigator.userAgentData
      .getHighEntropyValues(["platformVersion", "bitness"])
      .then(function (ua) {
        var major = parseInt(ua.platformVersion.split(".")[0], 10);
        if (major >= 13) {
          systemVersion = "Windows 11";
        } else if (major > 0) {
          systemVersion = "Windows 10";
        }
        systemArchitecture = ua.bitness === "64" ? "64-bit" : "32-bit";
        updateVersionElement();
      });
  }
} else {
  if (userAgentContains("Windows NT 10.0")) {
    systemVersion = "Windows 10/11";
  } else if (userAgentContains("Windows NT 6.4")) {
    systemVersion = "Windows 10";
  } else if (userAgentContains("Windows NT 6.3")) {
    systemVersion = "Windows 8.1";
  } else if (userAgentContains("Windows NT 6.2")) {
    systemVersion = "Windows 8";
  } else if (userAgentContains("Windows NT 6.1")) {
    systemVersion = "Windows 7";
  } else if (userAgentContains("Windows NT 6.0")) {
    systemVersion = "Windows Vista";
  } else if (userAgentContains("Windows NT 5.2")) {
    systemVersion = "Windows XP";
  } else if (userAgentContains("Windows NT 5.1")) {
    systemVersion = "Windows XP";
  } else if (userAgentContains("Windows NT 5.0")) {
    systemVersion = "Windows 2000";
  } else if (userAgentContains("Windows NT 4.0")) {
    systemVersion = "Windows NT";
  }

  // "Win32" is what every Windows browser reports as navigator.platform, 64-bit ones included,
  // so only the user agent tells the two apart
  systemArchitecture =
    userAgentContains("Win64") ||
    userAgentContains("x64") ||
    userAgentContains("WOW64")
      ? "64-bit"
      : "32-bit";
}

var systemLanguage = (navigator.language || navigator.userLanguage || "en").split("-")[0];

function updateVersionElement() {
  var header = document.getElementsByTagName("header")[0];
  var versionElement = header && header.getElementsByTagName("p")[0];

  if (versionElement) {
    versionElement.textContent =
      systemVersion + " " + systemArchitecture + " " + systemLanguage;
  }
}

updateVersionElement();
