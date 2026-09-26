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

// GitHub Pages cannot send the header that makes a browser download a file
// it can display, so an answer file's link would show the XML when opened in
// a new tab. Its link points back at this page instead, with the file in the
// query string: the page opened that way downloads the file, and a click on
// the link downloads it without leaving the page
var answerFilePattern = /^autounattend-[A-Za-z]+\.xml$/;

// Only an answer file's name, never a path or an address, so the page cannot
// be made to download anything else
function getAnswerFileParameter(search) {
  var match = /[?&]download=([^&#]*)/.exec(search || "");
  var fileName;

  if (!match) {
    return null;
  }

  try {
    fileName = decodeURIComponent(match[1]);
  } catch (e) {
    return null;
  }

  return answerFilePattern.test(fileName) ? fileName : null;
}

function downloadAnswerFile(fileName) {
  var link = document.createElement("a");

  // Browsers that ignore the download attribute show the file, as they did
  if (!("download" in link)) {
    window.location.href = fileName;
    return;
  }

  link.href = fileName;
  link.download = "autounattend.xml";
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

function onAnswerFileClick(event) {
  var fileName = getAnswerFileParameter(this.search);
  var opensElsewhere = event.ctrlKey || event.shiftKey || event.metaKey;

  // Other buttons, Ctrl, Shift and Cmd open the link in a new tab or window,
  // which downloads the file on load. Alt is Chrome's "download the link",
  // which would save this page
  if (!fileName || event.button !== 0 || opensElsewhere) {
    return;
  }

  event.preventDefault();
  downloadAnswerFile(fileName);
}

function downloadRequestedAnswerFile() {
  var fileName = getAnswerFileParameter(window.location.search);
  var address = window.location.pathname + window.location.hash;

  if (!fileName) {
    return;
  }

  // So that reloading the page does not download the file again
  if (window.history && window.history.replaceState) {
    window.history.replaceState(null, "", address);
  }

  downloadAnswerFile(fileName);
}

function addAnswerFileClickHandlers() {
  var links = document.getElementsByTagName("a");
  var i;

  if (!document.addEventListener) {
    return;
  }

  for (i = 0; i < links.length; i++) {
    if (getAnswerFileParameter(links[i].search)) {
      links[i].addEventListener("click", onAnswerFileClick, false);
    }
  }
}

downloadRequestedAnswerFile();
addAnswerFileClickHandlers();
