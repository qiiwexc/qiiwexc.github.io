Set-Variable -Option Constant CONFIG_CHROME_PREFERENCES '{
  "browser": {
    "enable_spellchecking": true,
    "window_placement": {
      "maximized": true,
      "work_area_left": 0,
      "work_area_top": 0
    }
  },
  "default_search_provider_data": {
    "mirrored_template_url_data": {
      "keyword": "google.lv",
      "preconnect_to_search_url": true,
      "prefetch_likely_navigations": true
    }
  },
  "enable_do_not_track": true,
  "https_only_mode_enabled": true,
  "intl": {
    "accept_languages": "lv,ru,en-GB",
    "selected_languages": "lv,ru,en-GB"
  },
  "net": {
    "network_prediction_options": 3
  },
  "privacy_sandbox": {
    "m1": {
      "ad_measurement_enabled": false,
      "fledge_enabled": false
    },
  },
  "safebrowsing": {
    "enabled": true,
    "enhanced": true,
    "esb_enabled_via_tailored_security": true
  },
  "spellcheck": {
    "dictionaries": ["lv", "ru", "en-GB"],
    "use_spelling_service": true
  }
}
'
