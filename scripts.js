if (navigator.appVersion.indexOf('Windows NT 10.0') !== -1) {
  var systemVersion = 'Windows 10';
} else if (navigator.appVersion.indexOf('Windows NT 6.4') !== -1) {
  var systemVersion = 'Windows 10';
} else if (navigator.appVersion.indexOf('Windows NT 6.3') !== -1) {
  var systemVersion = 'Windows 8.1';
} else if (navigator.appVersion.indexOf('Windows NT 6.2') !== -1) {
  var systemVersion = 'Windows 8';
} else if (navigator.appVersion.indexOf('Windows NT 6.1') !== -1) {
  var systemVersion = 'Windows 7';
} else if (navigator.appVersion.indexOf('Windows NT 6.0') !== -1) {
  var systemVersion = 'Windows Vista';
} else if (navigator.appVersion.indexOf('Windows NT 5.2') !== -1) {
  var systemVersion = 'Windows XP';
} else if (navigator.appVersion.indexOf('Windows NT 5.1') !== -1) {
  var systemVersion = 'Windows XP';
} else if (navigator.appVersion.indexOf('Windows NT 5.0') !== -1) {
  var systemVersion = 'Windows 2000';
} else if (navigator.appVersion.indexOf('Windows NT 4.0') !== -1) {
  var systemVersion = 'Windows NT';
} else {
  var systemVersion = 'Unknown Operating System';
}

var systemArchitecture = navigator.userAgent.indexOf('WOW64') !== -1 || navigator.userAgent.indexOf('Win64') !== -1 ? ' x64 ' : ' x86 ';
var systemLanguage = (navigator.browserLanguage ? navigator.browserLanguage : navigator.language).indexOf('ru') !== -1 ? 'RU' : 'EN';

document.getElementsByTagName('p')[0].innerHTML = (systemVersion + systemArchitecture + systemLanguage);
