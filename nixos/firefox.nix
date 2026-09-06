{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr;

    policies = {
      DisableAccounts = true;
      DisableFirefoxStudies = true;
      DisableFirefoxScreenshots = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFeedbackCommands = true;

      DisableProfileImport = true;
      DisableProfileRefresh = true;
      NoDefaultBookmarks = true;

      DisableFormHistory = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      DisablePasswordReveal = true;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;

      DisableDeveloperTools = true;
      BlockAboutConfig = false;
      BlockAboutProfiles = false;
      BlockAboutSupport = true;

      HttpsOnlyMode = "enabled";

      PDFjs = {
        Enabled = false;
      };

      AIControls = {
        Default = {
          Value = "blocked";
          Locked = true;
        };
        Translations = {
          Value = "blocked";
          Locked = true;
        };
        PDFAltText = {
          Value = "blocked";
          Locked = true;
        };
        SmartTabGroups = {
          Value = "blocked";
          Locked = true;
        };
        LinkPreviewKeyPoints = {
          Value = "blocked";
          Locked = true;
        };
        SidebarChatbot = {
          Value = "blocked";
          Locked = true;
        };
        SmartWindow = {
          Value = "blocked";
          Locked = true;
        };
      };

      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        SuspectedFingerprinting = true;
        Category = "strict";
      };

      Cookies = {
        Behavior = "partition-foreign";
        BehaviorPrivateBrowsing = "partition-foreign";
      };

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };

      SearchSuggestEnabled = false;

      SearchEngines = {
        PreventInstalls = true;
      };

      InstallAddonsPermission = {
        Default = true;
      };

      IPProtectionAvailable = false;
      VisualSearchEnabled = false;
      DefaultSerialGuardSetting = 2;
    };

    profiles = {
      "Profile-A" = {
        id = 0;
        name = "Ephemeral";
        isDefault = true;

        settings = {
          "privacy.sanitize.sanitizeOnShutdown" = true;
          "privacy.clearOnShutdown.cache" = true;
          "privacy.clearOnShutdown.cookies" = true;
          "privacy.clearOnShutdown.downloads" = true;
          "privacy.clearOnShutdown.formdata" = true;
          "privacy.clearOnShutdown.history" = true;
          "privacy.clearOnShutdown.sessions" = true;
          "privacy.clearOnShutdown.siteSettings" = true;
          "privacy.clearOnShutdown.offlineApps" = true;

          "permissions.default.camera" = 2;
          "permissions.default.microphone" = 2;
          "permissions.default.geo" = 2;
          "permissions.default.desktop-notification" = 2;

          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.globalprivacycontrol.functionality.enabled" = true;

          "network.http.referer.XOriginPolicy" = 2;
          "network.http.referer.XOriginTrimmingPolicy" = 2;

          "network.prefetch-next" = false;
          "network.predictor.enabled" = false;
          "network.predictor.enable-prefetch" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;
          "browser.places.speculativeConnect.enabled" = false;

          "network.dns.disablePrefetch" = true;

          "media.peerconnection.ice.no_host" = true;

          "geo.enabled" = false;

          "media.autoplay.default" = 1;
          "media.autoplay.blocking_policy" = 2;

          "dom.disable_open_during_load" = true;

          "browser.urlbar.suggest.searches" = false;
          "browser.search.suggest.enabled" = false;
          "browser.urlbar.suggest.history" = false;
          "browser.urlbar.suggest.bookmark" = false;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.maxRichResults" = 0;

          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

          "privacy.resistFingerprinting" = false;
          "privacy.resistFingerprinting.letterboxing" = false;

          "browser.sessionstore.resume_from_crash" = false;

          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.preferences.moreFromMozilla" = false;
        };
      };

      "Profile-B" = {
        id = 1;
        name = "Persistent";
        isDefault = false;

        settings = {
          "privacy.sanitize.sanitizeOnShutdown" = true;
          "privacy.clearOnShutdown.cache" = true;
          "privacy.clearOnShutdown.downloads" = true;
          "privacy.clearOnShutdown.formdata" = true;
          "privacy.clearOnShutdown.history" = true;
          "privacy.clearOnShutdown.sessions" = true;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.siteSettings" = false;
          "privacy.clearOnShutdown.offlineApps" = false;

          "permissions.default.camera" = 2;
          "permissions.default.microphone" = 2;
          "permissions.default.geo" = 2;
          "permissions.default.desktop-notification" = 2;

          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.globalprivacycontrol.functionality.enabled" = true;

          "network.prefetch-next" = false;
          "network.predictor.enabled" = false;
          "network.predictor.enable-prefetch" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;
          "browser.places.speculativeConnect.enabled" = false;

          "network.dns.disablePrefetch" = true;

          "media.autoplay.default" = 0;
          "media.autoplay.blocking_policy" = 2;

          "dom.disable_open_during_load" = true;

          "browser.urlbar.suggest.searches" = false;
          "browser.search.suggest.enabled" = false;
          "browser.urlbar.suggest.history" = false;
          "browser.urlbar.suggest.bookmark" = true;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.topsites" = false;

          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

          "browser.download.manager.addToRecentDocs" = false;
          "browser.helperApps.alwaysAsk.force" = true;

          "privacy.resistFingerprinting" = false;
          "privacy.resistFingerprinting.letterboxing" = false;

          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.preferences.moreFromMozilla" = false;
        };
      };
    };
  };
}
