// Privacy / clearing
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown.cache", true);
user_pref("privacy.clearOnShutdown.downloads", true);
user_pref("privacy.clearOnShutdown.formdata", true);
user_pref("privacy.clearOnShutdown.history", true);
user_pref("privacy.clearOnShutdown.sessions", true);
user_pref("privacy.clearOnShutdown.cookies", false);
user_pref("privacy.clearOnShutdown.siteSettings", false);
user_pref("privacy.clearOnShutdown.offlineApps", false);

// Permissions
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.desktop-notification", 2);

// Global Privacy Control
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.globalprivacycontrol.functionality.enabled", true);

// Prefetch / speculative connections
user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", false);
user_pref("network.predictor.enable-prefetch", false);
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.places.speculativeConnect.enabled", false);
user_pref("network.dns.disablePrefetch", true);

// Autoplay
user_pref("media.autoplay.default", 0);
user_pref("media.autoplay.blocking_policy", 2);

// Popups
user_pref("dom.disable_open_during_load", true);

// URL bar suggestions
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.bookmark", true);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.topsites", false);

// New Tab
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// Downloads
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.helperApps.alwaysAsk.force", true);

// Fingerprinting
user_pref("privacy.resistFingerprinting", false);
user_pref("privacy.resistFingerprinting.letterboxing", false);

// UI / customization
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("browser.compactmode.show", true);
