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
      "preconnect_to_search_url": true,
      "prefetch_likely_navigations": true
    }
  },
  "enable_do_not_track": true,
  "https_first_balanced_mode_enabled": false,
  "https_only_mode_auto_enabled": false,
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
      "consent_decision_made": true,
      "eea_notice_acknowledged": true,
      "fledge_enabled": false,
      "topics_enabled": true
    }
  },
  "safebrowsing": {
    "enabled": true,
    "enhanced": true
  },
  "spellcheck": {
    "dictionaries": ["lv", "ru", "en-GB"],
    "use_spelling_service": true
  }
}
'
