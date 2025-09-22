Set-Variable -Option Constant CONFIG_EDGE_PREFERENCES '{
  "browser": {
    "editor_proofing_languages": {
      "en-GB": {
        "Grammar": true,
        "Spelling": true
      },
      "lv": {
        "Grammar": true,
        "Spelling": true
      },
      "ru": {
        "Grammar": true,
        "Spelling": true
      }
    },
    "enable_editor_proofing": true,
    "enable_text_prediction_v2": true,
    "show_hubapps_personalization": false,
    "show_prompt_before_closing_tabs": true,
    "window_placement": {
      "maximized": true,
      "work_area_left": 0,
      "work_area_top": 0
    }
  },
  "edge": {
    "sleeping_tabs": {
      "enabled": false,
      "fade_tabs": false,
      "threshold": 43200
    },
    "super_duper_secure_mode": {
      "enabled": true,
      "state": 1,
      "strict_inprivate": true
    }
  },
  "enhanced_tracking_prevention": {
    "user_pref": 3
  },
  "https_only_mode_auto_enabled": false,
  "https_only_mode_enabled": true,
  "instrumentation": {
    "ntp": {
      "layout_mode": "updateLayout;3;1758293358211",
      "news_feed_display": "updateFeeds;off;1758293358217"
    }
  },
  "intl": {
    "accept_languages": "lv,ru,en-GB",
    "selected_languages": "lv,ru,en-GB"
  },
  "local_browser_data_share": {
    "pin_recommendations_eligible": false
  },
  "ntp": {
    "hide_default_top_sites": true,
    "layout_mode": 3,
    "news_feed_display": "off",
    "next_site_suggestions_available": false,
    "quick_links_options": 0,
    "record_user_choices": [
      {
        "setting": "layout_mode",
        "source": "ntp",
        "value": 3
      },
      {
        "setting": "ntp.news_feed_display",
        "source": "ntp",
        "value": "off"
      },
      {
        "setting": "tscollapsed",
        "source": "updatePrefTSCollapsed",
        "value": 0
      },
      {
        "setting": "quick_links_options",
        "source": "ntp",
        "value": "off"
      }
    ]
  },
  "spellcheck": {
    "dictionaries": ["lv", "ru", "en-GB"]
  },
  "video_enhancement": {
    "enabled": true
  }
}
'
